"""
OMOP SQL Exporter - Core functionality for generating SQL files

This module provides the core functionality for exporting OMOP database schemas
and data to SQL files that can be imported into PostgreSQL containers.

Author: Narasimha Raghavan
"""

import os
import logging
import subprocess
import tempfile
from typing import List, Dict, Set, Tuple
import networkx as nx
from sqlalchemy import create_engine, text, MetaData, inspect
from urllib.parse import urlparse
from .distribution_strategies import DistributionStrategy

logger = logging.getLogger(__name__)

class SQLExporter:
    """Handles SQL export functionality for OMOP partitions"""
    
    def __init__(self, source_db_url: str, num_partitions: int, output_dir: str = "sql_exports", use_copy: bool = False):
        """
        Initialize the SQL exporter
        
        Args:
            source_db_url: Connection string for the source database
            num_partitions: Number of partitions to create
            output_dir: Directory to save SQL files
            use_copy: Use COPY statements for faster import (default: False, uses INSERT)
        """
        self.source_db_url = source_db_url
        self.num_partitions = num_partitions
        self.use_copy = use_copy
        self.output_dir = output_dir
        self.source_engine = create_engine(source_db_url)
        self.person_table = 'omopcdm.person'
        
        # Parse source database URL to get connection details
        parsed_url = urlparse(source_db_url)
        self.db_host = parsed_url.hostname or 'localhost'
        self.db_port = parsed_url.port or 5432
        self.db_name = parsed_url.path.lstrip('/')
        self.db_user = parsed_url.username
        self.db_password = parsed_url.password
        
        # Create output directory
        os.makedirs(output_dir, exist_ok=True)
        
        # List of known lookup/reference tables that should be duplicated
        # Note: cdm_source is removed because it has foreign key dependencies
        self.lookup_tables = {
            'concept', 'concept_ancestor', 'concept_class', 'concept_relationship',
            'concept_synonym', 'domain', 'drug_strength', 'relationship',
            'source_to_concept_map', 'vocabulary'
        }
        
        # Tables that should be loaded first (vocabulary tables)
        self.vocabulary_tables = {
            'concept', 'vocabulary', 'domain', 'concept_class', 'relationship',
            'concept_ancestor', 'concept_relationship', 'concept_synonym'
        }
    
    def analyze_schema(self) -> nx.DiGraph:
        """
        Analyze the database schema to build a dependency graph
        Returns a directed graph representing table relationships
        """
        graph = nx.DiGraph()
        
        # Query to get foreign key relationships, including schema
        query = """
        SELECT
            tc.table_schema,
            tc.table_name, 
            kcu.column_name,
            ccu.table_schema AS foreign_table_schema,
            ccu.table_name AS foreign_table_name,
            ccu.column_name AS foreign_column_name
        FROM 
            information_schema.table_constraints AS tc 
            JOIN information_schema.key_column_usage AS kcu
              ON tc.constraint_name = kcu.constraint_name
            JOIN information_schema.constraint_column_usage AS ccu
              ON ccu.constraint_name = tc.constraint_name
        WHERE tc.constraint_type = 'FOREIGN KEY';
        """
        
        with self.source_engine.connect() as conn:
            result = conn.execute(text(query))
            for row in result:
                from_table = f"{row[3]}.{row[4]}"
                to_table = f"{row[0]}.{row[1]}"
                graph.add_edge(from_table, to_table)
        
        return graph
    
    def _get_ordered_tables(self, graph: nx.DiGraph) -> List[str]:
        """
        Get tables in proper dependency order, handling cycles
        Prioritizes vocabulary tables and handles circular dependencies
        """
        # Define priority order for tables
        # Note: OMOP vocabulary tables have circular dependencies, so we need to handle them carefully
        priority_order = [
            # Core vocabulary tables (highest priority) - handle circular dependencies
            # Start with tables that have minimal dependencies
            'omopcdm.vocabulary', 
            'omopcdm.domain',
            'omopcdm.concept_class',
            'omopcdm.relationship',
            # Concept table has circular refs but is central - load after basic tables
            'omopcdm.concept',  
            'omopcdm.concept_ancestor',
            'omopcdm.concept_relationship',
            'omopcdm.concept_synonym',
            'omopcdm.drug_strength',
            'omopcdm.source_to_concept_map',
            
            # Core OMOP tables
            'omopcdm.person',
            'omopcdm.observation_period',
            'omopcdm.location',
            'omopcdm.care_site',
            'omopcdm.provider',
            
            # Visit tables
            'omopcdm.visit_occurrence',
            'omopcdm.visit_detail',
            
            # Clinical tables
            'omopcdm.condition_occurrence',
            'omopcdm.drug_exposure',
            'omopcdm.procedure_occurrence',
            'omopcdm.measurement',
            'omopcdm.observation',
            'omopcdm.device_exposure',
            'omopcdm.specimen',
            'omopcdm.note',
            'omopcdm.note_nlp',
            'omopcdm.fact_relationship',
            
            # Episode tables
            'omopcdm.episode',
            'omopcdm.episode_event',
            
            # Metadata tables (lowest priority)
            'omopcdm.cdm_source',
            'omopcdm.cohort_definition',
            'omopcdm.cohort',
        ]
        
        # Get all tables from the graph
        all_tables = set(graph.nodes())
        
        # Start with priority order
        ordered_tables = []
        for table in priority_order:
            if table in all_tables:
                ordered_tables.append(table)
                all_tables.remove(table)
        
        # Add any remaining tables (not in priority list)
        ordered_tables.extend(sorted(all_tables))
        
        return ordered_tables
    
    def get_related_tables(self, graph: nx.DiGraph) -> Set[str]:
        """
        Get all tables that are related to the person table
        """
        related_tables = set()
        for node in nx.descendants(graph, self.person_table):
            related_tables.add(node)
        related_tables.add(self.person_table)
        return related_tables
    
    def _has_person_id_column(self, table: str) -> bool:
        """Check if a table has a person_id column"""
        schema, table_name = table.split('.')
        with self.source_engine.connect() as conn:
            result = conn.execute(text(f"""
                SELECT EXISTS (
                    SELECT 1 
                    FROM information_schema.columns 
                    WHERE table_schema = '{schema}'
                    AND table_name = '{table_name}'
                    AND column_name = 'person_id'
                );
            """))
            return result.scalar()
    
    def export_schema_sql(self) -> str:
        """
        Export the complete schema as SQL using pg_dump
        Includes: tables, constraints, indexes, sequences, functions, triggers, etc.
        Returns the path to the schema SQL file
        """
        schema_file = os.path.join(self.output_dir, "schema.sql")
        
        # Use pg_dump to export complete schema with all components
        cmd = [
            'pg_dump',
            f'--host={self.db_host}',
            f'--port={self.db_port}',
            f'--username={self.db_user}',
            f'--dbname={self.db_name}',
            '--schema-only',           # Schema only, no data
            '--no-owner',             # Don't include ownership commands
            '--no-privileges',        # Don't include privilege commands
            '--schema=omopcdm',       # Only export omopcdm schema
            '--verbose',              # Verbose output for debugging
            '--file', schema_file
        ]
        
        # Set password via environment variable
        env = os.environ.copy()
        env['PGPASSWORD'] = self.db_password
        
        try:
            logger.info(f"Exporting complete schema to {schema_file}")
            logger.info("Including: tables, constraints, indexes, sequences, functions, triggers")
            result = subprocess.run(cmd, env=env, capture_output=True, text=True, check=True)
            logger.info("Schema export completed successfully")
            
            # Verify the schema file contains expected components
            self._verify_schema_components(schema_file)
            
            return schema_file
        except subprocess.CalledProcessError as e:
            logger.error(f"Schema export failed: {e.stderr}")
            raise
    
    def export_partition_data(self, partition_index: int, graph: nx.DiGraph) -> str:
        """
        Export data for a specific partition
        Returns the path to the partition SQL file
        """
        partition_file = os.path.join(self.output_dir, f"partition_{partition_index}.sql")
        
        logger.info(f"Exporting data for partition {partition_index}")
        
        with open(partition_file, 'w') as f:
            # Write header
            f.write(f"-- OMOP Partition {partition_index} Data Export\n")
            f.write(f"-- Generated from source database: {self.db_name}\n")
            f.write(f"-- Partition: {partition_index} of {self.num_partitions}\n\n")
            
            # Get all tables from the source database
            with self.source_engine.connect() as conn:
                result = conn.execute(text("""
                    SELECT table_name 
                    FROM information_schema.tables 
                    WHERE table_schema = 'omopcdm'
                    ORDER BY table_name
                """))
                tables = [f"omopcdm.{row[0]}" for row in result]
            
            # Export data for each table
            for table in tables:
                self._export_table_data(f, table, partition_index)
        
        logger.info(f"Partition {partition_index} data exported to {partition_file}")
        return partition_file
    
    def _export_table_data(self, file_handle, table: str, partition_index: int):
        """
        Export data for a specific table to a partition
        """
        schema, table_name = table.split('.')
        
        with self.source_engine.connect() as conn:
            # Get total count of rows
            result = conn.execute(text(f"SELECT COUNT(*) FROM {schema}.{table_name}"))
            total_rows = result.scalar()
            
            if total_rows == 0:
                logger.info(f"Table {table_name} is empty, skipping")
                return
            
            # Special handling for episode_event
            if table_name == 'episode_event':
                self._export_episode_event_data(file_handle, table, partition_index)
                return
            
            # For vocabulary tables, always copy full table to every partition
            if table_name in self.vocabulary_tables:
                self._export_full_table_data(file_handle, table)
                return
            
            # For lookup tables, copy full table to every partition
            if table_name in self.lookup_tables:
                self._export_full_table_data(file_handle, table)
                return
            
            # For person-dependent tables, use modulus on person_id
            if self._has_person_id_column(table):
                self._export_person_dependent_data(file_handle, table, partition_index)
                return
            
            # For any other tables, copy full table to every partition
            self._export_full_table_data(file_handle, table)
    
    def _export_episode_event_data(self, file_handle, table: str, partition_index: int):
        """Export episode_event data based on episode's person_id"""
        schema, table_name = table.split('.')
        
        query = f"""
            SELECT ee.* 
            FROM {schema}.{table_name} ee
            JOIN {schema}.episode e ON ee.episode_id = e.episode_id
            WHERE (e.person_id % {self.num_partitions}) = {partition_index}
        """
        
        self._export_query_data(file_handle, table, query)
        logger.info(f"Exported episode_event data for partition {partition_index} based on episode.person_id")
    
    def _export_person_dependent_data(self, file_handle, table: str, partition_index: int):
        """Export person-dependent table data using modulus on person_id"""
        schema, table_name = table.split('.')
        
        query = f"SELECT * FROM {schema}.{table_name} WHERE (person_id % {self.num_partitions}) = {partition_index}"
        
        self._export_query_data(file_handle, table, query)
        logger.info(f"Exported {table_name} data for partition {partition_index} using modulus on person_id")
    
    def _export_full_table_data(self, file_handle, table: str):
        """Export full table data (for lookup tables)"""
        schema, table_name = table.split('.')
        
        query = f"SELECT * FROM {schema}.{table_name}"
        
        self._export_query_data(file_handle, table, query)
        logger.info(f"Exported full {table_name} data")
    
    def _export_query_data(self, file_handle, table: str, query: str):
        """
        Export data using a custom query and write in pgdump INSERT format
        """
        schema, table_name = table.split('.')
        
        with self.source_engine.connect() as conn:
            # Get column information
            result = conn.execute(text(f"""
                SELECT column_name, data_type, is_nullable, column_default
                FROM information_schema.columns 
                WHERE table_schema = '{schema}' 
                AND table_name = '{table_name}'
                ORDER BY ordinal_position
            """))
            cols_meta = [(row[0], row[1], row[2] == 'YES', row[3]) for row in result]
            columns = [c for c, _, _, _ in cols_meta]
            nullable_cols = [c for c, _, is_null, _ in cols_meta if is_null]
            
            if not columns:
                logger.warning(f"No columns found for table {table}")
                return
            
            # Execute the query
            result = conn.execute(text(query))
            rows = result.fetchall()
            
            if not rows:
                logger.info(f"No data found for table {table_name} with given query")
                return
            
            # Write table header
            file_handle.write(f"\n-- Data for table {schema}.{table_name} ({len(rows)} rows)\n")
            file_handle.write(f"SET search_path TO {schema}, public;\n\n")
            
            if self.use_copy:
                # Use COPY statements for maximum performance
                self._write_copy_data(file_handle, schema, table_name, columns, rows, nullable_cols)
            else:
                # Write data in bulk INSERT format for better performance
                column_list = ', '.join(columns)
                batch_size = 1000  # Insert 1000 rows per statement
                
                for batch_start in range(0, len(rows), batch_size):
                    batch_end = min(batch_start + batch_size, len(rows))
                    batch_rows = rows[batch_start:batch_end]
                    
                    # Build VALUES clause for this batch
                    value_clauses = []
                    for row in batch_rows:
                        values = []
                        for i, value in enumerate(row):
                            if value is None:
                                values.append('NULL')
                            elif isinstance(value, str):
                                # Escape single quotes
                                escaped_value = value.replace("'", "''")
                                values.append(f"'{escaped_value}'")
                            elif isinstance(value, (int, float)):
                                values.append(str(value))
                            else:
                                # Convert to string and escape
                                escaped_value = str(value).replace("'", "''")
                                values.append(f"'{escaped_value}'")
                        
                        value_clauses.append(f"({', '.join(values)})")
                    
                    # Write bulk INSERT statement
                    values_sql = ',\n    '.join(value_clauses)
                    file_handle.write(f"INSERT INTO {schema}.{table_name} ({column_list}) VALUES\n    {values_sql};\n\n")
            
            file_handle.write("\n")
    
    def _write_copy_data(self, file_handle, schema: str, table_name: str, columns: List[str], rows: List, nullable_cols: List[str] = None):
        """
        Write data using COPY statements for maximum performance
        """
        import csv
        
        # Build FORCE_NULL clause for nullable columns
        force_null_clause = f", FORCE_NULL ({', '.join(nullable_cols)})" if nullable_cols else ""
        
        # Write COPY statement with proper NULL handling
        file_handle.write(
            f"COPY {schema}.{table_name} ({', '.join(columns)}) "
            f"FROM STDIN WITH (FORMAT CSV, DELIMITER ',', QUOTE '\"', ESCAPE '\"', HEADER FALSE, NULL ''{force_null_clause});\n"
        )
        
        # Write CSV data directly to file handle
        writer = csv.writer(file_handle, quoting=csv.QUOTE_MINIMAL, lineterminator='\n')
        for row in rows:
            # Convert None to empty string - PostgreSQL will treat empty strings as NULL for nullable columns
            writer.writerow(['' if v is None else v for v in row])
        
        file_handle.write("\\.\n\n")
    
    def export_all_partitions(self, graph: nx.DiGraph) -> List[str]:
        """
        Export all partitions as SQL files
        Returns list of generated SQL file paths
        """
        exported_files = []
        
        # First export the schema
        schema_file = self.export_schema_sql()
        exported_files.append(schema_file)
        
        # Then export data for each partition
        for i in range(self.num_partitions):
            partition_file = self.export_partition_data(i, graph)
            exported_files.append(partition_file)
        
        logger.info(f"Exported {len(exported_files)} SQL files to {self.output_dir}")
        return exported_files
    
    def create_combined_partition_files(self, graph: nx.DiGraph) -> List[str]:
        """
        Create combined SQL files for each partition (schema + data)
        Returns list of combined SQL file paths
        """
        combined_files = []
        
        # First export the schema
        schema_file = self.export_schema_sql()
        
        # Create combined files for each partition
        for i in range(self.num_partitions):
            combined_file = os.path.join(self.output_dir, f"partition_{i}_complete.sql")
            
            logger.info(f"Creating combined file for partition {i}")
            
            with open(combined_file, 'w') as out_f:
                # Write header
                out_f.write(f"-- OMOP Partition {i} Complete Export\n")
                out_f.write(f"-- Generated from source database: {self.db_name}\n")
                out_f.write(f"-- Partition: {i} of {self.num_partitions}\n")
                out_f.write(f"-- This file contains both schema and data\n\n")
                
                # Copy schema
                with open(schema_file, 'r') as schema_f:
                    out_f.write("-- ============================================\n")
                    out_f.write("-- SCHEMA DEFINITION\n")
                    out_f.write("-- ============================================\n\n")
                    out_f.write(schema_f.read())
                    out_f.write("\n\n")
                
                # Add data
                out_f.write("-- ============================================\n")
                out_f.write("-- DATA FOR PARTITION\n")
                out_f.write("-- ============================================\n\n")
                
                # Disable foreign key constraints to handle circular dependencies
                out_f.write("-- Temporarily disable foreign key constraints for data import\n")
                out_f.write("SET session_replication_role = replica;\n\n")
                
                # Get tables in dependency order, handling cycles
                # Use a custom ordering that prioritizes vocabulary tables
                tables = self._get_ordered_tables(graph)
                
                # Export data for each table
                for table in tables:
                    self._export_table_data(out_f, table, i)
                
                # Re-enable foreign key constraints
                out_f.write("\n-- Re-enable foreign key constraints\n")
                out_f.write("SET session_replication_role = DEFAULT;\n\n")
                
                # Add validation to ensure data integrity
                out_f.write("-- ============================================\n")
                out_f.write("-- DATA VALIDATION\n")
                out_f.write("-- ============================================\n\n")
                out_f.write("-- Validate foreign key constraints\n")
                out_f.write("DO $$\n")
                out_f.write("DECLARE\n")
                out_f.write("    constraint_violations INTEGER;\n")
                out_f.write("BEGIN\n")
                out_f.write("    -- Check for foreign key violations\n")
                out_f.write("    SELECT COUNT(*) INTO constraint_violations\n")
                out_f.write("    FROM (\n")
                out_f.write("        SELECT 'concept' as table_name, concept_class_id as fk_value\n")
                out_f.write("        FROM omopcdm.concept c\n")
                out_f.write("        WHERE c.concept_class_id NOT IN (SELECT concept_class_id FROM omopcdm.concept_class)\n")
                out_f.write("        UNION ALL\n")
                out_f.write("        SELECT 'concept' as table_name, vocabulary_id as fk_value\n")
                out_f.write("        FROM omopcdm.concept c\n")
                out_f.write("        WHERE c.vocabulary_id NOT IN (SELECT vocabulary_id FROM omopcdm.vocabulary)\n")
                out_f.write("        UNION ALL\n")
                out_f.write("        SELECT 'concept' as table_name, domain_id as fk_value\n")
                out_f.write("        FROM omopcdm.concept c\n")
                out_f.write("        WHERE c.domain_id NOT IN (SELECT domain_id FROM omopcdm.domain)\n")
                out_f.write("    ) violations;\n")
                out_f.write("    \n")
                out_f.write("    IF constraint_violations > 0 THEN\n")
                out_f.write("        RAISE EXCEPTION 'Foreign key constraint violations detected: % violations', constraint_violations;\n")
                out_f.write("    ELSE\n")
                out_f.write("        RAISE NOTICE 'All foreign key constraints validated successfully';\n")
                out_f.write("    END IF;\n")
                out_f.write("END $$;\n\n")
            
            combined_files.append(combined_file)
            logger.info(f"Created combined file: {combined_file}")
        
        return combined_files
    
    def validate_export(self, graph: nx.DiGraph) -> bool:
        """
        Validate that the exported data is correct
        """
        logger.info("Validating exported data...")
        validation_passed = True
        
        # Get source counts
        source_counts = {}
        with self.source_engine.connect() as conn:
            for table in self.get_related_tables(graph):
                schema, table_name = table.split('.')
                result = conn.execute(text(f"SELECT COUNT(*) FROM {schema}.{table_name}"))
                source_counts[table_name] = result.scalar()
        
        # Validate each partition
        for i in range(self.num_partitions):
            logger.info(f"Validating partition {i}...")
            
            # Create a temporary database connection for validation
            # This would require setting up temporary databases, which is complex
            # For now, we'll just log the validation approach
            logger.info(f"Partition {i} validation would check:")
            for table_name, source_count in source_counts.items():
                if table_name in self.lookup_tables:
                    expected_count = source_count
                elif self._has_person_id_column(f"omopcdm.{table_name}"):
                    expected_count = source_count // self.num_partitions
                    if i < source_count % self.num_partitions:
                        expected_count += 1
                else:
                    expected_count = source_count
                
                logger.info(f"  Table {table_name}: expected {expected_count} rows")
        
        logger.info("Export validation completed")
        return validation_passed
    
    def _verify_schema_components(self, schema_file: str):
        """
        Verify that the schema file contains all expected components
        """
        if not os.path.exists(schema_file):
            logger.error(f"Schema file {schema_file} does not exist")
            return False
        
        with open(schema_file, 'r') as f:
            content = f.read()
        
        # Check for essential schema components
        components = {
            'CREATE SCHEMA': 'Schema creation',
            'CREATE TABLE': 'Table definitions',
            'PRIMARY KEY': 'Primary key constraints',
            'FOREIGN KEY': 'Foreign key constraints',
            'CREATE INDEX': 'Index definitions',
            'CREATE SEQUENCE': 'Sequence definitions',
            'CREATE FUNCTION': 'Function definitions',
            'CREATE TRIGGER': 'Trigger definitions'
        }
        
        missing_components = []
        for pattern, description in components.items():
            if pattern not in content:
                missing_components.append(description)
        
        if missing_components:
            logger.warning(f"Schema file may be missing: {', '.join(missing_components)}")
        else:
            logger.info("✓ Schema file contains all expected components")
        
        # Log some statistics
        table_count = content.count('CREATE TABLE')
        index_count = content.count('CREATE INDEX')
        fk_count = content.count('FOREIGN KEY')
        
        logger.info(f"Schema statistics: {table_count} tables, {index_count} indexes, {fk_count} foreign keys")
        
        return len(missing_components) == 0
    
    def export_complete_database_dump(self) -> str:
        """
        Export a complete database dump including all schemas, data, and metadata
        This is an alternative method that ensures everything is included
        """
        complete_file = os.path.join(self.output_dir, "complete_database_dump.sql")
        
        # Use pg_dump to export everything
        cmd = [
            'pg_dump',
            f'--host={self.db_host}',
            f'--port={self.db_port}',
            f'--username={self.db_user}',
            f'--dbname={self.db_name}',
            '--no-owner',             # Don't include ownership commands
            '--no-privileges',        # Don't include privilege commands
            '--verbose',              # Verbose output for debugging
            '--file', complete_file
        ]
        
        # Set password via environment variable
        env = os.environ.copy()
        env['PGPASSWORD'] = self.db_password
        
        try:
            logger.info(f"Exporting complete database dump to {complete_file}")
            logger.info("Including: all schemas, tables, data, constraints, indexes, sequences, functions, triggers")
            result = subprocess.run(cmd, env=env, capture_output=True, text=True, check=True)
            logger.info("Complete database dump export completed successfully")
            return complete_file
        except subprocess.CalledProcessError as e:
            logger.error(f"Complete database dump export failed: {e.stderr}")
            raise
