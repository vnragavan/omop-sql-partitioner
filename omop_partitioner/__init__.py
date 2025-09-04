"""
OMOP Database Partitioner

A comprehensive Python-based tool for partitioning OMOP (Observational Medical Outcomes Partnership) 
databases by generating SQL files that can be imported into PostgreSQL containers.
"""

__version__ = "1.0.0"
__author__ = "Narasimha Raghavan"
__email__ = "your-email@example.com"
__description__ = "A comprehensive Python-based tool for partitioning OMOP databases by generating SQL files"

from .sql_partitioner import OMOPSQLPartitioner
from .sql_export import SQLExporter
from .distribution_strategies import (
    DistributionStrategy,
    UniformDistributionStrategy,
    HashDistributionStrategy,
    RoundRobinDistributionStrategy
)
from .cleanup import OMOPCleanup

__all__ = [
    "OMOPSQLPartitioner",
    "SQLExporter",
    "DistributionStrategy",
    "UniformDistributionStrategy",
    "HashDistributionStrategy",
    "RoundRobinDistributionStrategy",
    "OMOPCleanup",
]
