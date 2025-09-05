# OMOP SQL Partitioner

A Python tool for partitioning OMOP databases into SQL files for distributed PostgreSQL deployment.

## 🚀 Features

- **SQL File Generation**: Creates pgdump-style SQL files for each partition
- **Multiple Distribution Strategies**: Uniform, hash-based, and round-robin data distribution
- **Schema Analysis**: Automatically analyzes database relationships and dependencies
- **Patient-Centric Partitioning**: Distributes patient records and related data across partitions
- **High Performance Export**: Supports bulk INSERT and COPY statements for fast data loading
- **Command Line Interface**: Easy-to-use CLI with comprehensive options
- **Health Check Utility**: Validates Docker containers running loaded OMOP data
- **Cleanup Tools**: Manages generated files and disk space

## 📋 Prerequisites

- **Python**: 3.8+ (3.12+ recommended)
- **PostgreSQL**: Version 16+ (for source database)
- **PostgreSQL Client Tools**: `pg_dump` and `psql` must be available in PATH

## 🛠️ Installation

### From Source
```bash
# Clone the repository
git clone https://github.com/your-username/omop-sql-partitioner.git
cd omop-sql-partitioner

# Create virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install package
pip install -e .
```

### From PyPI (Future)
```bash
pip install omop-partitioner
```

## ⚙️ Configuration

Create a `.env` file in the project directory:

```bash
# Database connection
SOURCE_DB_URL=postgresql://username:password@host:port/database_name

# Partitioning settings
NUM_PARTITIONS=2
DISTRIBUTION_STRATEGY=uniform
OUTPUT_DIR=sql_exports

# Optional settings
LOG_LEVEL=INFO
```

## 🚀 Usage

### Complete Command Reference

```bash
# Basic usage with .env file
omop-partitioner

# Specify all parameters directly
omop-partitioner --db-url postgresql://user:pass@host:port/db --partitions 4 --output-dir my_partitions

# Use different distribution strategies
omop-partitioner --strategy uniform --partitions 2
omop-partitioner --strategy hash --partitions 4
omop-partitioner --strategy round_robin --partitions 8

# Performance optimization options
omop-partitioner --use-copy --partitions 2
omop-partitioner --use-copy --strategy hash --partitions 4

# Verbose output for debugging
omop-partitioner --verbose --partitions 2
omop-partitioner --verbose --use-copy --strategy uniform

# Help and version information
omop-partitioner --help
omop-partitioner --version
```

### Command Options

| Option | Description | Default |
|--------|-------------|---------|
| `--db-url` | PostgreSQL connection string | From .env file |
| `--partitions` | Number of partitions to create | 2 |
| `--strategy` | Distribution strategy (uniform, hash, round_robin) | uniform |
| `--output-dir` | Output directory for SQL files | sql_exports |
| `--use-copy` | Use COPY statements for faster import | False |
| `--verbose` | Enable verbose logging | False |
| `--help` | Show help message | - |
| `--version` | Show version information | - |

## 🛠️ Additional Tools
### Deployment Script
```bash
# Deploy partitions to Docker containers
python omop_partitioner/spin_and_import.py /path/to/partition1.sql.gz /path/to/partition2.sql.gz
```

## 📊 Output Files

The tool generates SQL files in the specified output directory:

```
sql_exports/
├── schema.sql                    # Complete database schema
├── partition_0_complete.sql      # Partition 0 (schema + data)
├── partition_1_complete.sql      # Partition 1 (schema + data)
└── partitioning_report.txt       # Summary report
```

### Health Check
```bash
# Check single container
omop-healthcheck --containers omop_partition_0

# Check multiple containers
omop-healthcheck --containers omop_partition_0 omop_partition_1

# Check any number of containers
omop-healthcheck --containers omop_partition_0 omop_partition_1 omop_partition_2 omop_partition_3

# Check with custom database settings
omop-healthcheck --containers omop_partition_0 omop_partition_1 --user postgres --db omop
```

**Health Check Validates:**
- ✅ **Container Readiness**: PostgreSQL server accepting connections
- ✅ **Schema Existence**: OMOP schema is present and accessible
- ✅ **Table Count**: Required tables are present
- ✅ **Data Integrity**: Sample data counts (concept, person tables)
- ✅ **Replication Settings**: PostgreSQL replication role configuration

### Cleanup
```bash
# List files to clean
omop-cleanup --list

# Clean up generated files
omop-cleanup --confirm
```


## 🔧 Troubleshooting

### Common Issues

1. **Database Connection Issues**
   - Verify database URL format
   - Check network connectivity
   - Ensure database is running

2. **PostgreSQL Client Tools Not Found**
   ```bash
   # macOS
   brew install postgresql
   
   # Ubuntu/Debian
   sudo apt-get install postgresql-client
   ```

3. **Permission Issues**
   - Ensure write permissions for output directory
   - Check database user permissions

### Debug Mode
```bash
# Enable verbose logging
omop-partitioner --verbose

# Or set environment variable
export LOG_LEVEL=DEBUG
omop-partitioner
```

## 📈 Performance Tips

- **Use COPY statements** for large datasets: `--use-copy`
- **Increase batch size** for bulk INSERT operations
- **Ensure adequate disk space** (2-3x database size)
- **Use SSD storage** for better I/O performance

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


---

**Author**: Narasimha Raghavan  
**Version**: 1.0.0
