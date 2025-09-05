
#!/usr/bin/env python3
# Spin up one Postgres container per provided dump (.sql or .sql.gz),
# auto-run the dump via /docker-entrypoint-initdb.d or stream it in,
# tune Postgres for faster imports, and verify basic schema/data.
# AUTO-RETRY on host port conflicts.
#
# Usage:
#   python spin_and_import.py /abs/path/part1.sql.gz /abs/path/part2.sql.gz ...
#
# Env overrides (optional):
#   PG_IMAGE=postgres:17 DB_NAME=omop PG_USER=postgres START_PORT=5433 PASS_PREFIX=secret RECREATE=true

# Author: Narasimha Raghavan 
import argparse
import os
import shlex
import subprocess
import sys
import time
import socket
from pathlib import Path
from typing import List
import shutil

DEFAULTS = {
    "PG_IMAGE": os.environ.get("PG_IMAGE", "postgres:17"),
    "DB_NAME": os.environ.get("DB_NAME", "omop"),
    "PG_USER": os.environ.get("PG_USER", "postgres"),
    "START_PORT": int(os.environ.get("START_PORT", "5433")),
    "PASS_PREFIX": os.environ.get("PASS_PREFIX", "secret"),
    "RECREATE": os.environ.get("RECREATE", "true").lower() in {"1","true","yes","y"},
    # Tuning flags for big imports
    "MAX_WAL_SIZE": os.environ.get("MAX_WAL_SIZE", "8GB"),
    "CHECKPOINT_TIMEOUT": os.environ.get("CHECKPOINT_TIMEOUT", "15min"),
    "CHECKPOINT_COMPLETION_TARGET": os.environ.get("CHECKPOINT_COMPLETION_TARGET", "0.9"),
    "WAL_COMPRESSION": os.environ.get("WAL_COMPRESSION", "on"),
    "SYNCHRONOUS_COMMIT": os.environ.get("SYNCHRONOUS_COMMIT", "off"),
    "AUTOVACUUM": os.environ.get("AUTOVACUUM", "off"),
    "MAINTENANCE_WORK_MEM": os.environ.get("MAINTENANCE_WORK_MEM", "2GB"),
    "WAIT_TIMEOUT": int(os.environ.get("WAIT_TIMEOUT", "240")),  # seconds
}

def log(msg: str) -> None:
    print(f"[{time.strftime('%H:%M:%S')}] {msg}")

def run(cmd: List[str], check=True, capture_output=False, text=True, env=None):
    """Run a shell command safely; returns CompletedProcess."""
    log("$ " + " ".join(shlex.quote(c) for c in cmd))
    return subprocess.run(cmd, check=check, capture_output=capture_output, text=text, env=env)

def require(cmd_name: str):
    if not shutil.which(cmd_name):
        sys.exit(f"ERROR: Missing '{cmd_name}' on PATH")

def sanitize_name(path: Path) -> str:
    """Make a Docker-safe name from filename (lowercase, alnum, dash, underscore)."""
    base = path.name.lower()
    if base.endswith(".sql.gz"):
        base = base[:-7]
    elif base.endswith(".sql"):
        base = base[:-4]
    safe = []
    for ch in base:
        if ch.isalnum() or ch in "-_":
            safe.append(ch)
        else:
            safe.append("_")
    return "".join(safe)

def ensure_abs_existing_file(p: str) -> Path:
    path = Path(p)
    if not path.is_absolute():
        sys.exit(f"ERROR: Path must be absolute: {p}")
    if not path.is_file():
        sys.exit(f"ERROR: File not found: {p}")
    return path

def docker_logs_head(container: str, lines: int = 200):
    try:
        out = run(["docker", "logs", container], capture_output=True).stdout
        head = "\n".join(out.splitlines()[:lines])
        print(head)
    except subprocess.CalledProcessError:
        pass

def docker_exec_psql(container: str, user: str, db: str, sql: str) -> None:
    run(["docker", "exec", "-i", container, "psql", "-U", user, "-d", db, "-v", "ON_ERROR_STOP=1", "-c", sql])

def wait_ready(container: str, user: str, db: str, timeout: int) -> None:
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            run(["docker", "exec", container, "pg_isready", "-U", user, "-d", db], check=True)
            return
        except subprocess.CalledProcessError:
            time.sleep(2)
    sys.exit(f"ERROR: Timeout waiting for {container} to become ready")

def import_stream(container: str, file_in_container: str, is_gzip: bool, user: str, db: str):
    """Stream a dump into psql (gunzip if needed)."""
    if is_gzip:
        run(["docker", "exec", "-i", container, "bash", "-lc",
             f"gunzip -c {shlex.quote(file_in_container)} | psql -v ON_ERROR_STOP=1 -1 -U {shlex.quote(user)} -d {shlex.quote(db)}"])
    else:
        run(["docker", "exec", "-i", container, "bash", "-lc",
             f"psql -v ON_ERROR_STOP=1 -1 -U {shlex.quote(user)} -d {shlex.quote(db)} -f {shlex.quote(file_in_container)}"])

def next_free_port(start: int, limit: int = 200) -> int:
    """Find a free TCP port >= start on localhost."""
    for p in range(start, start + limit):
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            try:
                s.bind(("127.0.0.1", p))
                return p
            except OSError:
                continue
    raise RuntimeError(f"No free port found in range {start}..{start+limit-1}")

def main():
    parser = argparse.ArgumentParser(description="Spin up tuned Postgres containers and import big SQL dumps (auto-retry ports).")
    parser.add_argument("dumps", nargs="+", help="Absolute paths to .sql.gz or .sql files (one container per file)")
    parser.add_argument("--no-recreate", action="store_true", help="Do not delete existing containers/volumes")
    parser.add_argument("--stream", action="store_true",
                        help="Stream into psql instead of auto-init (works even if volume is not fresh)")
    args = parser.parse_args()

    # Ensure prerequisites
    require("docker")
    require("sed")

    recreate = DEFAULTS["RECREATE"] and not args.no_recreate

    for idx, dump in enumerate(args.dumps):
        dump_path = ensure_abs_existing_file(dump)
        suffix = sanitize_name(dump_path)
        c_name = f"pg_{suffix}"
        v_name = f"pgdata_{suffix}"
        requested_port = DEFAULTS["START_PORT"] + idx
        host_port = next_free_port(requested_port)
        password = f"{DEFAULTS['PASS_PREFIX']}{idx}"
        init_dir = Path.home() / "pg" / f"{c_name}_init"
        init_dir.mkdir(parents=True, exist_ok=True)

        # Determine target filename inside init dir
        is_gzip = dump_path.name.endswith(".sql.gz")
        target = init_dir / ("partition.sql.gz" if is_gzip else "partition.sql")
        shutil.copyfile(dump_path, target)

        log(f"=== {dump_path} -> container={c_name} volume={v_name} port={host_port}")
        if recreate:
            log("Removing any existing container/volume ...")
            run(["docker", "rm", "-f", c_name], check=False)
            run(["docker", "volume", "rm", v_name], check=False)

        # Try to run container on chosen port; if race occurs, retry once with next free port
        def try_run(port: int):
            return run([
                "docker","run","-d","--name",c_name,
                "-e", f"POSTGRES_USER={DEFAULTS['PG_USER']}",
                "-e", f"POSTGRES_PASSWORD={password}",
                "-e", f"POSTGRES_DB={DEFAULTS['DB_NAME']}",
                "-p", f"{port}:5432",
                "-v", f"{v_name}:/var/lib/postgresql/data",
                "-v", f"{str(init_dir)}:/docker-entrypoint-initdb.d:ro",
                DEFAULTS["PG_IMAGE"],
                "-c", f"max_wal_size={DEFAULTS['MAX_WAL_SIZE']}",
                "-c", f"checkpoint_timeout={DEFAULTS['CHECKPOINT_TIMEOUT']}",
                "-c", f"checkpoint_completion_target={DEFAULTS['CHECKPOINT_COMPLETION_TARGET']}",
                "-c", f"wal_compression={DEFAULTS['WAL_COMPRESSION']}",
                "-c", f"synchronous_commit={DEFAULTS['SYNCHRONOUS_COMMIT']}",
                "-c", f"autovacuum={DEFAULTS['AUTOVACUUM']}",
                "-c", f"maintenance_work_mem={DEFAULTS['MAINTENANCE_WORK_MEM']}",
            ], check=True, capture_output=False)

        try:
            try_run(host_port)
        except subprocess.CalledProcessError as e:
            if "port is already allocated" in str(e):
                new_port = next_free_port(host_port + 1)
                log(f"Port {host_port} busy; retrying on {new_port} ...")
                host_port = new_port
                try_run(host_port)
            else:
                raise

        # Show first log lines
        docker_logs_head(c_name, 200)

        # Wait ready
        wait_ready(c_name, DEFAULTS["PG_USER"], DEFAULTS["DB_NAME"], DEFAULTS["WAIT_TIMEOUT"])

        # If streaming requested (volume not fresh), copy into /tmp and import manually
        if args.stream:
            in_container = f"/tmp/{target.name}"
            run(["docker", "cp", str(target), f"{c_name}:{in_container}"])
            import_stream(c_name, in_container, is_gzip, DEFAULTS["PG_USER"], DEFAULTS["DB_NAME"])

        # Basic verification
        log("Verification: user table count ...")
        try:
            docker_exec_psql(c_name, DEFAULTS["PG_USER"], DEFAULTS["DB_NAME"],
                             "SELECT count(*) AS user_tables "
                             "FROM information_schema.tables "
                             "WHERE table_schema NOT IN ('pg_catalog','information_schema');")
        except subprocess.CalledProcessError:
            log("Verification failed to count tables (psql error)")

        log("Verification: presence of common OMOP objects (if applicable) ...")
        try:
            docker_exec_psql(c_name, DEFAULTS["PG_USER"], DEFAULTS["DB_NAME"],
                             "SELECT "
                             "to_regclass('cdm.concept') AS cdm_concept, "
                             "to_regclass('public.concept') AS public_concept, "
                             "to_regclass('cdm.cdm_source') AS cdm_cdm_source;")
        except subprocess.CalledProcessError:
            pass

        print()
        print("Connection info:")
        print(f"  psql -h 127.0.0.1 -p {host_port} -U {DEFAULTS['PG_USER']} -d {DEFAULTS['DB_NAME']}")
        print(f"  Password: {password}")
        print()

if __name__ == "__main__":
    main()
