# OMOP Database Partitioner

A comprehensive Python-based tool for partitioning OMOP (Observational Medical Outcomes Partnership) databases by generating SQL files that can be imported into PostgreSQL containers.

## 🚀 Features

### 📦 **Installable Package Benefits**
- **Easy Installation**: Simple `pip install` command
- **Command Line Interface**: Professional CLI with help, version, and verbose options
- **Python API**: Clean, importable Python module for programmatic use
- **Multiple Entry Points**: Various CLI tools for different tasks
- **Professional Structure**: Proper package organization with dependencies
- **Cross-Platform**: Works on macOS, Linux, and Windows

### 🔧 **Core Functionality**
- **Automated Schema Analysis**: Intelligently analyzes database schema and relationships using dependency graphs
- **Flexible Distribution Strategies**: Supports uniform, hash-based, and round-robin data distribution
- **Data Integrity Validation**: Comprehensive validation ensuring data consistency across partitions
- **SQL File Generation**: Generates pgdump-style SQL files for manual import
- **Complete Schema Export**: Includes all tables, constraints, indexes, and data

### 🎯 **Advanced Capabilities**
- **Dependency Graph Visualization**: Generates DOT files and PNG images showing table relationships
- **Patient-Centric Partitioning**: Distributes patient records and all related data across partitions
- **Schema Compliance**: Maintains all constraints, primary keys, and foreign key relationships
- **Import Script Generation**: Auto-generates scripts for easy container import
- **Comprehensive Validation**: Detailed validation and reporting of partition integrity

### 📊 **Monitoring & Analysis**
- **Partition Analysis**: Detailed analysis of data distribution across partitions
- **Validation Reports**: Comprehensive validation of data integrity and record counts
- **Configuration Management**: Environment-based configuration with .env support
- **Logging & Debugging**: Extensive logging for troubleshooting and monitoring

## 📋 Prerequisites

### System Requirements
- **Python**: 3.12+ (recommended) or 3.8+
- **PostgreSQL**: Version 16+ (for source database)
- **PostgreSQL Client Tools**: `pg_dump` and `psql` must be available in PATH
- **Operating System**: macOS, Linux, or Windows
- **Memory**: Minimum 8GB RAM (16GB+ recommended for large datasets)
- **Storage**: 2-3x the size of your source database for SQL files

## 🛠️ Installation & Setup

### 📦 Installable Package (Recommended)

The OMOP Partitioner is now available as an installable Python package with multiple installation methods:

#### **Method 1: Development Installation (From Source)**
```bash
# Clone the repository
git clone <repository-url>
cd omop-partitioner

# Create virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install as editable package
pip install -e .
```

#### **Method 2: Local Installation**
```bash
# From the repository directory
pip install .
```

#### **Method 3: From PyPI (Future)**
```bash
# When published to PyPI
pip install omop-partitioner
```

### 🔧 Manual Setup (Alternative)

If you prefer manual setup without the package:

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd omop-partitioner
   ```

2. **Set up Python environment**:
   ```bash
   # Create virtual environment
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   
   # Install dependencies
   pip install -r requirements.txt
   ```

3. **Configure environment**:
   ```bash
   # Copy and edit environment file
   cp .env.example .env
   nano .env  # Edit with your database details
   ```

### 📋 Prerequisites Installation

#### **Install PostgreSQL Client Tools**
```bash
# macOS
brew install postgresql

# Ubuntu/Debian
sudo apt-get install postgresql-client

# Windows
# Download from https://www.postgresql.org/download/windows/
```

#### **Verify Installation**
```bash
# Check if tools are available
which pg_dump
which psql

# Check versions
pg_dump --version
psql --version
```

### 📦 **Package Structure**

After installation, the following tools are available:

#### **Main CLI Tools**
```bash
omop-partitioner          # Main partitioning tool
omop-sql-partitioner      # Alternative entry point
omop-healthcheck          # Database health check utility
omop-cleanup              # Clean up generated files
```

#### **Python API Components**
```python
from omop_partitioner import (
    OMOPSQLPartitioner,           # Main partitioner class
    SQLExporter,                  # SQL export functionality
    DistributionStrategy,         # Base distribution strategy
    UniformDistributionStrategy,  # Uniform distribution
    HashDistributionStrategy,     # Hash-based distribution
    RoundRobinDistributionStrategy, # Round-robin distribution
    OMOPCleanup                   # Cleanup utility
)
```

#### **Package Contents**
```
omop_partitioner/
├── __init__.py              # Package initialization and exports
├── cli.py                   # Command line interface
├── sql_partitioner.py       # Main SQL partitioner
├── sql_export.py            # SQL export functionality
├── distribution_strategies.py # Data distribution logic
├── import_partitions.py     # Import helper
├── validate_partitions.py   # Validation
├── test_sql_export.py       # Testing
└── cleanup.py               # Cleanup utility
```

## ⚙️ Configuration

### Environment Variables (.env file)

```bash
# Database Configuration
SOURCE_DB_URL=postgresql://username:password@host:port/database_name
POSTGRES_VERSION=16
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=omop_db

# Partitioning Configuration
NUM_PARTITIONS=2
DISTRIBUTION_STRATEGY=uniform  # Options: uniform, hash, round_robin

# Output Configuration
OUTPUT_DIR=sql_exports
```

### Source Database Assumptions

The partitioner makes the following assumptions about your source database:

#### ✅ **Required Schema Structure**
- **Schema Name**: `omopcdm` (Observational Medical Outcomes Partnership Common Data Model)
- **Main Table**: `omopcdm.person` (must exist and contain patient data)
- **Person ID Column**: All person-dependent tables must have a `person_id` column
- **Standard OMOP Tables**: All standard OMOP CDM tables should be present

#### ✅ **Required Data Structure**
- **Person Table**: Must contain patient records with unique `person_id` values
- **Foreign Key Relationships**: All foreign key constraints should be properly defined
- **Data Integrity**: Source data should be consistent and validated
- **Character Encoding**: UTF-8 encoding recommended

#### ✅ **Database Access Requirements**
- **Read Access**: User must have SELECT permissions on all tables
- **Schema Access**: User must be able to query `information_schema` tables
- **Connection**: Database must be accessible via the provided connection string
- **PostgreSQL Version**: Source database should be PostgreSQL 9.6+ (16+ recommended)

#### ✅ **Table Categories**
The partitioner automatically categorizes tables into:

1. **Person-Dependent Tables**: Tables with `person_id` column
   - Split across partitions using modulus operation
   - Examples: `person`, `condition_occurrence`, `drug_exposure`, `measurement`

2. **Lookup/Reference Tables**: Standard OMOP vocabulary tables
   - Duplicated to all partitions
   - Examples: `concept`, `vocabulary`, `concept_ancestor`, `domain`

3. **Special Tables**: Tables with complex relationships
   - `episode_event`: Partitioned based on parent `episode.person_id`

#### ⚠️ **Known Limitations**
- **Non-Standard Schemas**: Only `omopcdm` schema is supported
- **Custom Tables**: Non-OMOP tables may not be handled correctly
- **Complex Relationships**: Very complex foreign key relationships may need manual review
- **Large Objects**: BLOB/CLOB data types may not be fully supported

## 🚀 Usage

### 🎯 Command Line Interface (CLI)

The installable package provides a powerful command-line interface:

#### **Basic Usage**
```bash
# Activate virtual environment (if using development installation)d 
source .venv/bin/activate

# Basic partitioning with .env configuration
omop-partitioner

# Show help
omop-partitioner --help

# Show version
omop-partitioner --version
```

#### **Advanced CLI Usage**
```bash
# Specify database URL directly
omop-partitioner --db-url postgresql://user:pass@host:port/db --partitions 4

# Use different distribution strategy
omop-partitioner --strategy hash --partitions 8

# Custom output directory
omop-partitioner --output-dir my_partitions

# Verbose output for debugging
omop-partitioner --verbose

# Combine multiple options
omop-partitioner --db-url postgresql://user:pass@host:port/db \
                 --partitions 4 \
                 --strategy uniform \
                 --output-dir partitions_4 \
                 --verbose

# Use COPY statements for maximum performance (fastest import)
omop-partitioner --db-url postgresql://user:pass@host:port/db \
                 --partitions 4 \
                 --use-copy
```

### 🐍 Python API Usage

#### **Basic Python Usage**
```python
from omop_partitioner import OMOPSQLPartitioner

# Initialize partitioner
partitioner = OMOPSQLPartitioner(
    source_db_url="postgresql://user:pass@host:port/db",
    num_partitions=2,
    output_dir="sql_exports"
)

# Run partitioning
partition_files = partitioner.partition_database()
print(f"Generated {len(partition_files)} partition files")
```

### 🚀 Data Export Variants

The OMOP partitioner supports three different data export methods, each optimized for different use cases:

#### **1. Individual INSERT Statements (Legacy)**
```bash
# Not recommended for large datasets
omop-partitioner --db-url postgresql://user:pass@host:port/db --partitions 2
```
- **Format**: `INSERT INTO table VALUES (row1); INSERT INTO table VALUES (row2); ...`
- **Performance**: Slowest (2-6 hours for large datasets)
- **Use Case**: Small datasets or debugging
- **Output**: `INSERT 0 1` for each row

#### **2. Bulk INSERT Statements (Default)**
```bash
# Recommended for most use cases
omop-partitioner --db-url postgresql://user:pass@host:port/db --partitions 2
```
- **Format**: `INSERT INTO table VALUES (row1), (row2), ..., (row1000);`
- **Performance**: 10-50x faster than individual INSERTs (15-45 minutes)
- **Use Case**: Production environments, balanced performance
- **Batch Size**: 1000 rows per statement

#### **3. COPY Statements (Maximum Performance)**
```bash
# Fastest import method
omop-partitioner --db-url postgresql://user:pass@host:port/db --partitions 2 --use-copy
```
- **Format**: `COPY table FROM STDIN WITH CSV; [data] \.`
- **Performance**: 100-500x faster than individual INSERTs (5-10 minutes)
- **Use Case**: Large datasets, maximum performance requirements
- **Note**: Uses CSV format for optimal PostgreSQL performance

#### **Performance Comparison**

| Method | Rows per Statement | Import Time (8.5M rows) | Use Case |
|--------|-------------------|-------------------------|----------|
| Individual INSERT | 1 | 2-6 hours | Debugging only |
| Bulk INSERT | 1000 | 15-45 minutes | Production (default) |
| COPY | All rows | 5-10 minutes | High-performance |

#### **Python API for Different Variants**

```python
from omop_partitioner import OMOPSQLPartitioner

# Default: Bulk INSERT (recommended)
partitioner = OMOPSQLPartitioner(
    source_db_url="postgresql://user:pass@host:port/db",
    num_partitions=2,
    output_dir="sql_exports"
)

# Maximum performance: COPY statements
partitioner = OMOPSQLPartitioner(
    source_db_url="postgresql://user:pass@host:port/db",
    num_partitions=2,
    output_dir="sql_exports",
    use_copy=True
)
```

#### **Advanced Python Usage**
```python
from omop_partitioner import OMOPSQLPartitioner, SQLExporter
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Initialize with environment variables
partitioner = OMOPSQLPartitioner(
    source_db_url=os.getenv('SOURCE_DB_URL'),
    num_partitions=int(os.getenv('NUM_PARTITIONS', '2')),
    output_dir=os.getenv('OUTPUT_DIR', 'sql_exports')
)

# Run partitioning with error handling
try:
    partition_files = partitioner.partition_database()
    print("✅ Partitioning completed successfully!")
    for i, file_path in enumerate(partition_files):
        print(f"  Partition {i}: {os.path.basename(file_path)}")
except Exception as e:
    print(f"❌ Error: {str(e)}")
```

### 📋 Step-by-Step SQL File Generation

This approach generates SQL files that you can manually import into PostgreSQL containers.

#### Step 1: Generate SQL Files

```bash
# Method 1: Using CLI (Recommended)
omop-partitioner

# Method 2: Using Python script (Legacy)
python omop_sql_partitioner.py

# Method 3: Using Python API
python -c "from omop_partitioner import OMOPSQLPartitioner; OMOPSQLPartitioner('postgresql://user:pass@host:port/db', 2, 'sql_exports').partition_database()"
```

#### Step 2: Review Generated Files

```bash
# Check generated files
ls -la sql_exports/
# Output:
# schema.sql                    # Complete schema
# partition_0_complete.sql      # Partition 0 (schema + data)
# partition_1_complete.sql      # Partition 1 (schema + data)
# partitioning_report.txt       # Summary report
```

#### Step 3: Create PostgreSQL Containers

```bash
# Create containers for each partition
docker run -d --name omop_partition_0 \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=omop \
  -p 5432:5432 \
  postgres:16

docker run -d --name omop_partition_1 \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=omop \
  -p 5433:5432 \
  postgres:16
```

#### Step 4: Import SQL Files

```bash
# Wait for containers to be ready
sleep 10

# Import partition 0
psql -h localhost -p 5432 -U postgres -d omop -f sql_exports/partition_0_complete.sql

# Import partition 1
psql -h localhost -p 5433 -U postgres -d omop -f sql_exports/partition_1_complete.sql
```

#### Step 5: Verify Partitions

```bash
# Check partition 0
psql -h localhost -p 5432 -U postgres -d omop -c "SELECT COUNT(*) FROM omopcdm.person;"

# Check partition 1
psql -h localhost -p 5433 -U postgres -d omop -c "SELECT COUNT(*) FROM omopcdm.person;"
```

### 🔧 Advanced Usage

#### **Custom Partition Count**
```bash
# Method 1: CLI parameter
omop-partitioner --partitions 4

# Method 2: Environment variable
export NUM_PARTITIONS=4
omop-partitioner

# Method 3: .env file
echo "NUM_PARTITIONS=4" >> .env
omop-partitioner
```

#### **Different Distribution Strategy**
```bash
# Method 1: CLI parameter
omop-partitioner --strategy hash

# Method 2: Environment variable
export DISTRIBUTION_STRATEGY=hash
omop-partitioner

# Method 3: .env file
echo "DISTRIBUTION_STRATEGY=hash" >> .env
omop-partitioner

# Available strategies: uniform, hash, round_robin
```

#### **Custom Output Directory**
```bash
# Method 1: CLI parameter
omop-partitioner --output-dir my_custom_partitions

# Method 2: Environment variable
export OUTPUT_DIR=my_custom_partitions
omop-partitioner
```

#### **Verbose Debugging**
```bash
# Enable detailed logging
omop-partitioner --verbose

# Or set environment variable
export LOG_LEVEL=DEBUG
omop-partitioner
```

### 🛠️ Additional CLI Tools

The package provides several specialized command-line tools:

```bash
# Alternative main entry point
omop-sql-partitioner --help

# Health check utility
omop-healthcheck --help

# Clean up generated files
omop-cleanup --help
```

### 🏥 **Health Check Utility**

The `omop-healthcheck` tool verifies that your OMOP database is accessible and functioning correctly:

```bash
# Basic health check
omop-healthcheck

# Check specific database
omop-healthcheck --db-url postgresql://user:pass@host:port/db

# Verbose output
omop-healthcheck --verbose

# Help
omop-healthcheck --help
```

**Health Check Features:**
- ✅ **Schema Validation**: Verifies OMOP schema exists and is complete
- ✅ **Table Count Check**: Ensures all required tables are present
- ✅ **Connection Test**: Validates database connectivity
- ✅ **Replication Role Check**: Verifies PostgreSQL replication settings
- ✅ **Data Integrity**: Basic data validation checks

### 🚀 **Deployment Script**

The `spin_and_import.py` script automates the deployment of generated SQL partitions into Dockerized PostgreSQL instances:

```bash
# Deploy partitions to Docker containers
python omop_partitioner/spin_and_import.py /path/to/partition1.sql.gz /path/to/partition2.sql.gz

# With custom configuration
PG_IMAGE=postgres:17 DB_NAME=omop START_PORT=5433 python omop_partitioner/spin_and_import.py *.sql.gz
```

**Deployment Features:**
- 🐳 **Auto-Container Management**: Spins up PostgreSQL containers automatically
- ⚡ **Optimized Import**: Tunes PostgreSQL for faster data loading
- 🔄 **Auto-Retry**: Handles port conflicts automatically
- 📊 **Health Verification**: Validates schema and data after import
- 🗜️ **Gzip Support**: Handles both `.sql` and `.sql.gz` files
- 🎯 **Flexible Configuration**: Environment variable customization

**Environment Variables:**
```bash
PG_IMAGE=postgres:17          # PostgreSQL Docker image
DB_NAME=omop                  # Database name
PG_USER=postgres              # Database user
START_PORT=5433               # Starting port for containers
PASS_PREFIX=secret            # Password prefix for containers
RECREATE=true                 # Recreate existing containers
```

### 🧹 **Cleanup Functionality**

The cleanup tool helps manage disk space by removing generated files:

#### **List Files to Clean**
```bash
# See what files would be cleaned (standard scan)
omop-cleanup --list

# Comprehensive scan for all OMOP-related files
omop-cleanup --list --comprehensive

# Show detailed breakdown
omop-cleanup --list --verbose
```

#### **Dry Run (Safe Preview)**
```bash
# See what would be cleaned without actually deleting
omop-cleanup --dry-run

# Dry run with verbose output
omop-cleanup --dry-run --verbose
```

#### **Clean Up All Generated Files**
```bash
# Interactive cleanup (asks for confirmation)
omop-cleanup

# Automatic cleanup (no confirmation prompt)
omop-cleanup --confirm

# Clean specific directory
omop-cleanup --directory sql_exports

# Clean custom output directory
omop-cleanup --output-dir my_partitions
```

#### **Cleanup Examples**
```bash
# List current files (standard scan)
omop-cleanup --list
# Output: Found 7 files, Total size: 1.9 MB

# Comprehensive scan for all OMOP files
omop-cleanup --list --comprehensive
# Output: Found 13 files, Total size: 55.9 GB

# Preview cleanup
omop-cleanup --dry-run
# Shows what would be deleted

# Clean up everything
omop-cleanup --confirm
# Removes all generated files and directories

# Clean only SQL exports
omop-cleanup --directory sql_exports --confirm

# Clean specific output directory
omop-cleanup --output-dir my_partitions --confirm
```

#### **Python API for Cleanup**
```python
from omop_partitioner import OMOPCleanup

# Initialize cleanup utility
cleanup = OMOPCleanup()

# List files
files = cleanup.list_generated_files()
print(f"Found {len(files)} files to clean")

# Get directory sizes
sizes = cleanup.get_directory_sizes()
for dir_path, size in sizes.items():
    print(f"{dir_path}: {cleanup.format_size(size)}")

# Comprehensive scan
results = cleanup.comprehensive_scan()
print(f"Found {len(results['all_files'])} files, total size: {cleanup.format_size(results['total_size'])}")

# Clean up files
result = cleanup.cleanup_files(dry_run=True)  # Safe preview
print(f"Would remove {result['files_removed']} files")

# Actually clean up
result = cleanup.cleanup_files(confirm=True)
print(f"Removed {result['files_removed']} files, freed {cleanup.format_size(result['space_freed'])}")
```

### 📊 Validation and Analysis

```bash
# Analyze existing partitions
python analyze_partitions.py

# Validate partition integrity
python validate_partitions.py

# Test SQL export functionality
python test_sql_export.py

# Show what's included in SQL files
python test_schema_components.py

# Example usage demonstration
python example_usage.py
```

## 📊 Output & Results

### Generated Files

```
sql_exports/
├── schema.sql                           # Complete schema (all tables, constraints, indexes)
├── partition_0_complete.sql             # Partition 0 (schema + data)
├── partition_1_complete.sql             # Partition 1 (schema + data)
├── partition_N_complete.sql             # Additional partitions
├── partitioning_report.txt              # Summary and validation report
└── import_partitions.sh                 # Auto-generated import script
```

### Visualization Files (Optional)

```
output/
├── source_graph.dot                     # Main source graph
├── source_graph.png                     # Visual representation
├── partition_0_graph.dot                # Partition 0 dependency graph
├── partition_0_graph.png                # Partition 0 visualization
├── partition_1_graph.dot                # Partition 1 dependency graph
├── partition_1_graph.png                # Partition 1 visualization
└── ...
```

### Schema Components Included

The generated SQL files include **complete database schema**:

✅ **Table Definitions**: All tables with complete column specifications  
✅ **Primary Key Constraints**: All primary keys  
✅ **Foreign Key Constraints**: All 176+ foreign key relationships  
✅ **Indexes**: All 70+ indexes for performance  
✅ **Data Types**: Complete column type definitions  
✅ **NOT NULL Constraints**: All non-nullable columns  
✅ **Default Values**: Column default specifications  
✅ **Sequences**: Auto-incrementing ID sequences  
✅ **Functions**: Custom database functions  
✅ **Triggers**: Database triggers  

### Data Components Included

✅ **All Table Data**: Complete data in INSERT format  
✅ **Empty Tables**: Tables with no data included with structure  
✅ **Partitioned Data**: Data intelligently distributed across partitions  
✅ **Lookup Tables**: Reference tables duplicated to all partitions  
✅ **Person-Dependent Data**: Patient data split by person_id  
✅ **Referential Integrity**: All foreign key relationships maintained  

## 🔍 Validation & Monitoring

### Data Integrity Checks

The partitioner performs comprehensive validation:

- **Record Count Validation**: Ensures total records match source
- **Schema Compliance**: Validates table structures and constraints
- **Data Sampling**: Compares sample data across partitions
- **Relationship Integrity**: Verifies foreign key relationships
- **Performance Metrics**: Monitors distribution efficiency

### Monitoring Commands

```bash
# Check SQL file sizes
ls -lh sql_exports/

# Validate partition data
python validate_partitions.py

# Test SQL export functionality
python test_sql_export.py

# Analyze partition structure
python analyze_partitions.py
```

## 🛡️ Security Features

- **Secure SQL Export**: Uses pg_dump for secure data export
- **Portable Files**: SQL files can be imported into any PostgreSQL environment
- **No Hardcoded Credentials**: Database credentials managed via environment variables
- **SSL Support**: Supports SSL connections for source database
- **Validation**: Comprehensive validation of exported data integrity

## 🔧 Troubleshooting

### Common Issues

#### 1. **Database Connection Issues**
```bash
# Test database connection
psql "postgresql://username:password@host:port/database_name" -c "SELECT 1;"

# Check PostgreSQL status
brew services list | grep postgresql  # macOS
sudo systemctl status postgresql     # Linux
```

#### 2. **Port Conflicts**
```bash
# Check port usage
lsof -i :5432
netstat -tulpn | grep :5432

# Kill conflicting processes
sudo pkill -f postgres
```

#### 3. **PostgreSQL Client Tools Issues**
```bash
# Check if pg_dump is available
which pg_dump
pg_dump --version

# Check if psql is available
which psql
psql --version

# Install PostgreSQL client tools if missing
# macOS
brew install postgresql

# Ubuntu/Debian
sudo apt-get install postgresql-client
```

#### 4. **Disk Space Issues**
```bash
# Check disk space
df -h

# Clean up old files
rm -rf sql_exports/old_*
rm -rf output/old_*
```

#### 5. **Permission Issues**
```bash
# Check file permissions
ls -la sql_exports/

# Fix permissions
chmod 755 sql_exports/
chmod 644 sql_exports/*.sql
```

### Debug Mode

Enable detailed logging:

```bash
# Set debug logging
export LOG_LEVEL=DEBUG
python omop_sql_partitioner.py

# Or edit .env file
echo "LOG_LEVEL=DEBUG" >> .env
```

### Validation Failures

If validation fails:

1. **Check source database integrity**:
   ```bash
   psql "your_connection_string" -c "SELECT COUNT(*) FROM omopcdm.person;"
   ```

2. **Verify schema structure**:
   ```bash
   psql "your_connection_string" -c "\dt omopcdm.*"
   ```

3. **Check foreign key relationships**:
   ```bash
   psql "your_connection_string" -c "SELECT * FROM information_schema.table_constraints WHERE constraint_type = 'FOREIGN KEY' AND table_schema = 'omopcdm';"
   ```

## 📈 Performance Considerations

### Data Export Method Selection

Choose the appropriate export method based on your requirements:

- **COPY Statements (`--use-copy`)**: Best for large datasets, maximum performance
- **Bulk INSERT (default)**: Balanced performance, good for most use cases
- **Individual INSERT**: Only for debugging small datasets

### Optimization Tips

- **Memory**: Allocate sufficient RAM for large datasets (16GB+ recommended)
- **Storage**: Use SSD storage for better I/O performance
- **Network**: Ensure stable network for database operations
- **Partition Count**: Balance between parallelism and resource usage
- **Export Method**: Use `--use-copy` for datasets > 1M rows

### Scaling Guidelines

- **Small Datasets** (< 1GB): 2-4 partitions
- **Medium Datasets** (1-10GB): 4-8 partitions
- **Large Datasets** (> 10GB): 8-16 partitions

### Resource Requirements

| Dataset Size | RAM Required | Disk Space | Recommended Partitions |
|--------------|--------------|------------|------------------------|
| < 1GB        | 8GB          | 5GB        | 2-4                    |
| 1-10GB       | 16GB         | 30GB       | 4-8                    |
| 10-100GB     | 32GB         | 300GB      | 8-16                   |
| > 100GB      | 64GB+        | 1TB+       | 16+                    |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:

1. Check the troubleshooting section
2. Review the logs in the `output/` or `sql_exports/` directory
3. Open an issue on GitHub
4. Check the configuration files for errors

## 🔄 Version History

- **v1.0.0**: Initial release with SQL file export approach
- **v1.1.0**: Added distribution strategies and validation
- **v1.2.0**: Enhanced setup automation and PostgreSQL 16 support
- **v1.3.0**: Added visualization and monitoring capabilities
- **v2.0.0**: Streamlined to focus on SQL file export approach

---

**Note**: This tool is designed for research and development purposes. Always backup your data before running the partitioner on production databases.

## 📚 Additional Resources

- [SQL Partitioning Guide](SQL_PARTITIONING_GUIDE.md) - Detailed guide for SQL-based partitioning
- [Download Guide](DOWNLOAD_GUIDE.md) - Instructions for downloading and using partitioned data
- [Private Access Guide](PRIVATE_ACCESS_GUIDE.md) - Guide for accessing private partitioned data

### 🚀 Quick Reference Commands

#### **Package Installation & Setup**
```bash
# Install package
pip install -e .

# Verify installation
omop-partitioner --version
omop-partitioner --help
```

#### **Main Partitioning Commands**
```bash
# Basic partitioning
omop-partitioner

# Advanced partitioning
omop-partitioner --db-url postgresql://user:pass@host:port/db --partitions 4 --verbose

# Alternative entry point
omop-sql-partitioner
```

#### **Import & Validation Commands**
```bash
# Import helpers
omop-import-partitions --list
omop-import-partitions --generate-script

# Validation
omop-validate-partitions
omop-test-export

# Cleanup
omop-cleanup --list
omop-cleanup --list --comprehensive
omop-cleanup --dry-run
omop-cleanup --confirm
```

#### **Legacy Script Commands (Still Available)**
```bash
# Direct script execution
python omop_sql_partitioner.py                    # Generate SQL files
python import_partitions.py --list                # List available files
python import_partitions.py --generate-script     # Generate import script

# Validation & Testing
python validate_partitions.py                     # Validate partitions
python test_sql_export.py                         # Test SQL export
python analyze_partitions.py                      # Analyze partitions

# Helper Scripts
python test_schema_components.py                  # Show what's included in SQL files
python example_usage.py                           # Example usage demonstration
```

#### **Python API Examples**
```python
# Basic usage
from omop_partitioner import OMOPSQLPartitioner
partitioner = OMOPSQLPartitioner("postgresql://user:pass@host:port/db", 2, "sql_exports")
files = partitioner.partition_database()

# Advanced usage with error handling
from omop_partitioner import OMOPSQLPartitioner
import os
from dotenv import load_dotenv

load_dotenv()
partitioner = OMOPSQLPartitioner(
    source_db_url=os.getenv('SOURCE_DB_URL'),
    num_partitions=int(os.getenv('NUM_PARTITIONS', '2')),
    output_dir=os.getenv('OUTPUT_DIR', 'sql_exports')
)
try:
    files = partitioner.partition_database()
    print(f"✅ Generated {len(files)} partition files")
except Exception as e:
    print(f"❌ Error: {str(e)}")
```