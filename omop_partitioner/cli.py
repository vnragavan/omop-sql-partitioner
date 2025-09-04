#!/usr/bin/env python3
"""
Command Line Interface for OMOP Partitioner

Author: Narasimha Raghavan
"""

import argparse
import os
import sys
import logging
from dotenv import load_dotenv
from .sql_partitioner import OMOPSQLPartitioner

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def main():
    """Main CLI entry point"""
    parser = argparse.ArgumentParser(
        description="OMOP Database Partitioner - Generate SQL files for database partitioning",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Basic usage with .env file
  omop-partitioner

  # Specify database URL directly
  omop-partitioner --db-url postgresql://user:pass@host:port/db --partitions 4

  # Use different output directory
  omop-partitioner --output-dir my_partitions

  # Use hash distribution strategy
  omop-partitioner --strategy hash --partitions 8
        """
    )
    
    parser.add_argument(
        "--db-url",
        help="Database connection URL (overrides SOURCE_DB_URL from .env)"
    )
    
    parser.add_argument(
        "--partitions",
        type=int,
        default=None,
        help="Number of partitions to create (overrides NUM_PARTITIONS from .env)"
    )
    
    parser.add_argument(
        "--strategy",
        choices=["uniform", "hash", "round_robin"],
        default=None,
        help="Distribution strategy (overrides DISTRIBUTION_STRATEGY from .env)"
    )
    
    parser.add_argument(
        "--output-dir",
        default=None,
        help="Output directory for SQL files (overrides OUTPUT_DIR from .env)"
    )
    
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Enable verbose logging"
    )
    
    parser.add_argument(
        "--use-copy",
        action="store_true",
        help="Use COPY statements for faster data import (default: uses bulk INSERT)"
    )
    
    parser.add_argument(
        "--version",
        action="version",
        version="omop-partitioner 2.0.0"
    )
    
    args = parser.parse_args()
    
    # Set logging level
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    try:
        # Load environment variables
        load_dotenv()
        
        # Get configuration from arguments or environment
        source_db_url = args.db_url or os.getenv('SOURCE_DB_URL')
        num_partitions = args.partitions or int(os.getenv('NUM_PARTITIONS', '2'))
        distribution_strategy = args.strategy or os.getenv('DISTRIBUTION_STRATEGY', 'uniform')
        output_dir = args.output_dir or os.getenv('OUTPUT_DIR', 'sql_exports')
        
        if not source_db_url:
            logger.error("Database URL is required. Set SOURCE_DB_URL in .env file or use --db-url")
            sys.exit(1)
        
        logger.info("Starting OMOP SQL partitioning process...")
        logger.info(f"Source database: {source_db_url}")
        logger.info(f"Number of partitions: {num_partitions}")
        logger.info(f"Distribution strategy: {distribution_strategy}")
        logger.info(f"Output directory: {output_dir}")
        
        # Initialize and run partitioner
        partitioner = OMOPSQLPartitioner(
            source_db_url=source_db_url,
            num_partitions=num_partitions,
            output_dir=output_dir,
            use_copy=args.use_copy
        )
        
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
        
    except KeyboardInterrupt:
        logger.info("Operation cancelled by user")
        sys.exit(1)
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        if args.verbose:
            logger.exception("Full traceback:")
        sys.exit(1)

if __name__ == "__main__":
    main()
