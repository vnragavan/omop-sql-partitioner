#!/usr/bin/env python3
"""
OMOP SQL Partitioner - Generates SQL files for each partition. 

This script partitions an OMOP database and generates SQL files for each partition
that can be imported into separate PostgreSQL containers manually.

Author: Narasimha Raghavan
"""

import os
import logging
import networkx as nx
from dotenv import load_dotenv
from urllib.parse import urlparse
from .sql_export import SQLExporter

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class OMOPSQLPartitioner:
    """Main class for SQL-based OMOP partitioning"""
    
    def __init__(self, source_db_url: str, num_partitions: int, output_dir: str = "sql_exports", use_copy: bool = False):
        """
        Initialize the SQL partitioner
        
        Args:
            source_db_url: Connection string for the source database
            num_partitions: Number of partitions to create
            output_dir: Directory to save SQL files
            use_copy: Use COPY statements for faster import
        """
        self.source_db_url = source_db_url
        self.num_partitions = num_partitions
        self.output_dir = output_dir
        self.sql_exporter = SQLExporter(source_db_url, num_partitions, output_dir, use_copy)
        
        # Parse source database URL to get connection details
        parsed_url = urlparse(source_db_url)
        self.db_host = parsed_url.hostname or 'localhost'
        self.db_port = parsed_url.port or 5432
        self.db_name = parsed_url.path.lstrip('/')
        self.db_user = parsed_url.username
        self.db_password = parsed_url.password
    
    def partition_database(self):
        """
        Main method to partition the database and generate SQL files
        """
        try:
            logger.info("Starting OMOP SQL partitioning process...")
            logger.info(f"Source database: {self.db_name} on {self.db_host}:{self.db_port}")
            logger.info(f"Number of partitions: {self.num_partitions}")
            logger.info(f"Output directory: {self.output_dir}")
            
            # Step 1: Analyze schema and create dependency graph
            logger.info("Step 1: Analyzing database schema...")
            graph = self.sql_exporter.analyze_schema()
            logger.info(f"Found {len(graph.nodes())} tables with {len(graph.edges())} relationships")
            
            # Step 2: Export schema and data for all partitions
            logger.info("Step 2: Exporting schema and partition data...")
            combined_files = self.sql_exporter.create_combined_partition_files(graph)
            
            # Step 3: Validate the export
            logger.info("Step 3: Validating exported data...")
            self.sql_exporter.validate_export(graph)
            
            # Step 4: Generate summary report
            self._generate_summary_report(combined_files, graph)
            
            logger.info("SQL partitioning completed successfully!")
            logger.info(f"Generated {len(combined_files)} partition files in {self.output_dir}")
            
            return combined_files
            
        except Exception as e:
            logger.error(f"Error during partitioning: {str(e)}")
            raise
    
    def _generate_summary_report(self, combined_files: list, graph: nx.DiGraph):
        """Generate a summary report of the partitioning process"""
        report_file = os.path.join(self.output_dir, "partitioning_report.txt")
        
        with open(report_file, 'w') as f:
            f.write("OMOP Database Partitioning Report\n")
            f.write("=" * 50 + "\n\n")
            
            f.write(f"Source Database: {self.db_name}\n")
            f.write(f"Host: {self.db_host}:{self.db_port}\n")
            f.write(f"Number of Partitions: {self.num_partitions}\n")
            f.write(f"Generated Files: {len(combined_files)}\n\n")
            
            f.write("Generated Files:\n")
            f.write("-" * 20 + "\n")
            for i, file_path in enumerate(combined_files):
                f.write(f"Partition {i}: {os.path.basename(file_path)}\n")
            
            f.write(f"\nSchema Information:\n")
            f.write("-" * 20 + "\n")
            f.write(f"Total Tables: {len(graph.nodes())}\n")
            f.write(f"Total Relationships: {len(graph.edges())}\n")
            
            # Get table information
            with self.sql_exporter.source_engine.connect() as conn:
                # get_table_names returns a list directly, not a SQL statement
                table_names = self.sql_exporter.source_engine.dialect.get_table_names(conn)
                tables = [name for name in table_names if name.startswith('omopcdm.')]
                
                f.write(f"\nTable Details:\n")
                f.write("-" * 20 + "\n")
                for table in sorted(tables):
                    schema, table_name = table.split('.')
                    count_result = conn.execute(f"SELECT COUNT(*) FROM {table}")
                    count = count_result.scalar()
                    f.write(f"{table_name}: {count:,} rows\n")
            
            f.write(f"\nImport Instructions:\n")
            f.write("-" * 20 + "\n")
            f.write("1. Create PostgreSQL containers for each partition\n")
            f.write("2. Import each partition file using:\n")
            f.write("   psql -U postgres -d <database_name> -f partition_X_complete.sql\n")
            f.write("3. Verify data integrity in each partition\n")
        
        logger.info(f"Summary report generated: {report_file}")

def main():
    """Main function to run the SQL partitioner"""
    try:
        load_dotenv()
        
        # Get database connection details from environment variables
        source_db_url = os.getenv('SOURCE_DB_URL')
        num_partitions = int(os.getenv('NUM_PARTITIONS', '2'))
        output_dir = os.getenv('OUTPUT_DIR', 'sql_exports')
        
        if not source_db_url:
            raise ValueError("SOURCE_DB_URL environment variable is required")
        
        # Parse the source database URL to get the port
        parsed_url = urlparse(source_db_url)
        source_port = parsed_url.port or 5432
        logger.info(f"Using source database port: {source_port}")
        
        # Initialize partitioner
        partitioner = OMOPSQLPartitioner(source_db_url, num_partitions, output_dir)
        
        # Run partitioning
        partition_files = partitioner.partition_database()
        
        # Print summary
        print("\n" + "=" * 60)
        print("PARTITIONING COMPLETED SUCCESSFULLY!")
        print("=" * 60)
        print(f"Generated {len(partition_files)} partition files:")
        for i, file_path in enumerate(partition_files):
            print(f"  Partition {i}: {os.path.basename(file_path)}")
        print(f"\nFiles saved in: {output_dir}")
        print(f"Summary report: {os.path.join(output_dir, 'partitioning_report.txt')}")
        print("\nTo import into PostgreSQL containers:")
        print("  psql -U postgres -d <database_name> -f partition_X_complete.sql")
        print("=" * 60)
        
    except Exception as e:
        logger.error(f"Error in main: {str(e)}")
        raise

if __name__ == "__main__":
    main()
