"""
App database access module.

Provides:
- SharedDataReader: Read-only access to core database tables
- AppDatabase: App-specific database management with migrations
- DatabaseBridge: QML bridge for database operations
"""

from __future__ import annotations

from .app_database import AppDatabase
from .shared_reader import SharedDataReader

__all__ = ["AppDatabase", "SharedDataReader"]
