#!/usr/bin/env python3
"""
OMOP Health Check Utility

This script provides health check functionality for OMOP partitions,
verifying that the database is accessible and functioning correctly.

Author: Narasimha Raghavan
"""

import argparse
import subprocess
from dataclasses import dataclass
from typing import List

SQL_HEALTH = """
SELECT 'schema_exists', CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.schemata WHERE schema_name='omopcdm'
) THEN 'OK' ELSE 'FAIL' END, 'schema check';

SELECT 'required_tables', CASE WHEN COUNT(*)>0 THEN 'OK' ELSE 'FAIL' END, COUNT(*)
FROM information_schema.tables WHERE table_schema='omopcdm';

SELECT 'replication_role', setting, 'replication role'
FROM pg_settings WHERE name='session_replication_role';

SELECT 'count_concept', 'OK', COUNT(*)::text FROM omopcdm.concept;
SELECT 'count_person', 'OK', COUNT(*)::text FROM omopcdm.person;
"""

@dataclass
class CheckResult:
    check: str
    status: str
    details: str

@dataclass
class ContainerReport:
    container: str
    ready: bool
    checks: List[CheckResult]

def run_cmd(cmd: List[str]) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, capture_output=True, text=True)

def pg_isready(container: str, user: str, db: str) -> bool:
    print(f"[INFO] Checking if PostgreSQL in container '{container}' is ready...")
    try:
        result = run_cmd(["docker", "exec", container, "pg_isready", "-U", user, "-d", db])
        if result.returncode == 0:
            print(f"[INFO] Container '{container}' is accepting connections.")
            return True
        else:
            print(f"[WARN] Container '{container}' not ready: {result.stdout.strip()} {result.stderr.strip()}")
            return False
    except Exception as e:
        print(f"[ERROR] Failed to run pg_isready in {container}: {e}")
        return False

def exec_health_sql(container: str, user: str, db: str) -> List[CheckResult]:
    print(f"[INFO] Running health check SQL inside '{container}'...")
    cmd = ["docker", "exec", "-i", container, "psql",
           "-v", "ON_ERROR_STOP=1", "-U", user, "-d", db, "-At", "-F", "|"]
    p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE, text=True)
    out, err = p.communicate(SQL_HEALTH)
    if p.returncode != 0:
        print(f"[ERROR] psql failed in {container}: {err or out}")
        return []

    checks: List[CheckResult] = []
    for line in out.splitlines():
        parts = line.split("|", 2)
        if len(parts) != 3:
            continue
        checks.append(CheckResult(check=parts[0], status=parts[1], details=parts[2]))
    return checks

def main():
    parser = argparse.ArgumentParser(description="OMOP container healthcheck")
    parser.add_argument("--containers", nargs="+", required=True,
                        help="List of container names to check")
    parser.add_argument("--user", default="postgres")
    parser.add_argument("--db", default="omop")
    args = parser.parse_args()

    for c in args.containers:
        print("=" * 50)
        print(f"[INFO] Starting health check for container: {c}")
        ready = pg_isready(c, args.user, args.db)
        if not ready:
            print(f"[FAIL] Skipping SQL checks for {c} (server not ready)\n")
            continue

        checks = exec_health_sql(c, args.user, args.db)
        if not checks:
            print(f"[FAIL] No results returned from health checks in {c}\n")
            continue

        ok = sum(1 for x in checks if x.status == "OK")
        fail = sum(1 for x in checks if x.status == "FAIL")

        for chk in checks:
            print(f"[CHECK] {chk.check:20} {chk.status:5} {chk.details}")

        print(f"[SUMMARY] {c}: {ok} OK, {fail} FAIL\n")

if __name__ == "__main__":
    main()
