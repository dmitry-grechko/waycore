"""
AppDatabase - App-specific SQLite database management.

Each app gets its own database file with:
- Automatic schema creation from manifest
- Version tracking and migrations
- Full CRUD operations
"""

from __future__ import annotations

import sqlite3
from dataclasses import dataclass
from pathlib import Path
from typing import Any


@dataclass
class TableColumn:
    """Definition of a table column."""

    name: str
    type: str
    primary: bool = False
    nullable: bool = True
    default: str | None = None
    references: str | None = None


@dataclass
class TableIndex:
    """Definition of a table index."""

    name: str
    columns: list[str]
    unique: bool = False


@dataclass
class TableDefinition:
    """Definition of a database table."""

    name: str
    columns: list[TableColumn]
    indexes: list[TableIndex] | None = None


@dataclass
class Migration:
    """Database migration step."""

    version: int
    up: str  # SQL to upgrade
    down: str | None = None  # SQL to downgrade (optional)


@dataclass
class DatabaseConfig:
    """Database configuration from manifest."""

    version: int
    tables: list[TableDefinition]
    migrations: list[Migration] | None = None
    shared_data_access: list[str] | None = None


class AppDatabase:
    """
    Manages an app's private SQLite database.

    Each app gets: /app/data/apps/{app_id}.sqlite3

    Features:
    - Automatic table creation from config
    - Schema versioning and migrations
    - Full CRUD operations
    - Transaction support
    """

    def __init__(
        self,
        app_id: str,
        data_dir: Path,
        config: DatabaseConfig | None = None,
    ) -> None:
        """
        Initialize the app database.

        Args:
            app_id: Unique app identifier
            data_dir: Base data directory
            config: Database configuration (optional)
        """
        self._app_id = app_id
        self._config = config
        self._db_path = Path(data_dir) / "apps" / f"{app_id}.sqlite3"
        self._db_path.parent.mkdir(parents=True, exist_ok=True)
        self._conn: sqlite3.Connection | None = None

    @property
    def path(self) -> Path:
        """Return the database file path."""
        return self._db_path

    @property
    def is_open(self) -> bool:
        """Check if database connection is open."""
        return self._conn is not None

    def open(self) -> None:
        """Open database connection."""
        if self._conn is None:
            self._conn = sqlite3.connect(str(self._db_path))
            self._conn.row_factory = sqlite3.Row
            # Enable foreign keys
            self._conn.execute("PRAGMA foreign_keys = ON")

    def close(self) -> None:
        """Close database connection."""
        if self._conn:
            self._conn.close()
            self._conn = None

    def initialize(self) -> None:
        """
        Initialize database and run migrations.

        Creates the schema version table and applies any pending
        migrations based on the config.
        """
        self.open()
        assert self._conn is not None

        # Create schema version tracking table
        self._conn.execute(
            """
            CREATE TABLE IF NOT EXISTS _schema_version (
                version INTEGER PRIMARY KEY,
                applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                description TEXT
            )
        """
        )
        self._conn.commit()

        # Get current schema version
        cursor = self._conn.execute("SELECT MAX(version) as version FROM _schema_version")
        row = cursor.fetchone()
        current_version = row["version"] if row["version"] is not None else 0

        # Apply migrations if we have config
        if self._config and current_version < self._config.version:
            self._run_migrations(current_version, self._config.version)

    def _run_migrations(self, from_version: int, to_version: int) -> None:
        """Run migrations from current to target version."""
        assert self._conn is not None
        assert self._config is not None

        # Initial schema creation (version 0 -> 1)
        if from_version == 0 and self._config.tables:
            self._create_initial_schema()
            from_version = 1

        # Run incremental migrations
        if self._config.migrations:
            for migration in sorted(self._config.migrations, key=lambda m: m.version):
                if from_version < migration.version <= to_version:
                    print(f"Running migration v{migration.version} " f"for {self._app_id}")
                    for statement in migration.up.split(";"):
                        statement = statement.strip()
                        if statement:
                            self._conn.execute(statement)

                    self._conn.execute(
                        "INSERT INTO _schema_version (version, description) " "VALUES (?, ?)",
                        (migration.version, f"Migration to v{migration.version}"),
                    )

        self._conn.commit()

    def _create_initial_schema(self) -> None:
        """Create tables from manifest definition."""
        assert self._conn is not None
        assert self._config is not None

        for table in self._config.tables:
            columns = []
            for col in table.columns:
                col_def = f"{col.name} {col.type}"
                if col.primary:
                    col_def += " PRIMARY KEY"
                if not col.nullable:
                    col_def += " NOT NULL"
                if col.default:
                    col_def += f" DEFAULT {col.default}"
                if col.references:
                    col_def += f" REFERENCES {col.references}"
                columns.append(col_def)

            sql = f"CREATE TABLE IF NOT EXISTS {table.name} ({', '.join(columns)})"
            self._conn.execute(sql)

            # Create indexes
            if table.indexes:
                for idx in table.indexes:
                    idx_cols = ", ".join(idx.columns)
                    unique = "UNIQUE " if idx.unique else ""
                    self._conn.execute(
                        f"CREATE {unique}INDEX IF NOT EXISTS "
                        f"{idx.name} ON {table.name} ({idx_cols})"
                    )

        # Record initial schema version
        self._conn.execute(
            "INSERT INTO _schema_version (version, description) VALUES (1, ?)",
            ("Initial schema",),
        )
        self._conn.commit()

    def get_version(self) -> int:
        """Get current schema version."""
        if not self.is_open:
            self.open()
        assert self._conn is not None

        try:
            cursor = self._conn.execute("SELECT MAX(version) as version FROM _schema_version")
            row = cursor.fetchone()
            return row["version"] if row and row["version"] else 0
        except sqlite3.OperationalError:
            return 0

    def execute(self, sql: str, params: tuple[Any, ...] | dict[str, Any] = ()) -> sqlite3.Cursor:
        """
        Execute a SQL statement.

        Args:
            sql: SQL statement
            params: Parameters (tuple for ? placeholders, dict for :name)

        Returns:
            Cursor object
        """
        if not self.is_open:
            self.open()
        assert self._conn is not None
        return self._conn.execute(sql, params)

    def executemany(self, sql: str, params_list: list[tuple[Any, ...]]) -> sqlite3.Cursor:
        """
        Execute a SQL statement with multiple parameter sets.

        Args:
            sql: SQL statement
            params_list: List of parameter tuples

        Returns:
            Cursor object
        """
        if not self.is_open:
            self.open()
        assert self._conn is not None
        return self._conn.executemany(sql, params_list)

    def fetchone(self, sql: str, params: tuple[Any, ...] = ()) -> dict[str, Any] | None:
        """
        Execute and fetch one row.

        Args:
            sql: SQL query
            params: Parameters

        Returns:
            Row as dict or None
        """
        cursor = self.execute(sql, params)
        row = cursor.fetchone()
        return dict(row) if row else None

    def fetchall(self, sql: str, params: tuple[Any, ...] = ()) -> list[dict[str, Any]]:
        """
        Execute and fetch all rows.

        Args:
            sql: SQL query
            params: Parameters

        Returns:
            List of rows as dicts
        """
        cursor = self.execute(sql, params)
        return [dict(row) for row in cursor.fetchall()]

    def insert(
        self,
        table: str,
        data: dict[str, Any],
    ) -> int:
        """
        Insert a row into a table.

        Args:
            table: Table name
            data: Column-value dict

        Returns:
            Last inserted row ID
        """
        columns = list(data.keys())
        placeholders = ", ".join("?" for _ in columns)
        col_str = ", ".join(columns)
        sql = f"INSERT INTO {table} ({col_str}) VALUES ({placeholders})"

        cursor = self.execute(sql, tuple(data.values()))
        self.commit()
        return cursor.lastrowid or 0

    def update(
        self,
        table: str,
        data: dict[str, Any],
        where: str,
        params: tuple[Any, ...] = (),
    ) -> int:
        """
        Update rows in a table.

        Args:
            table: Table name
            data: Column-value dict to update
            where: WHERE clause (without WHERE)
            params: Parameters for WHERE clause

        Returns:
            Number of rows affected
        """
        set_parts = [f"{col} = ?" for col in data.keys()]
        set_str = ", ".join(set_parts)
        sql = f"UPDATE {table} SET {set_str} WHERE {where}"

        cursor = self.execute(sql, (*data.values(), *params))
        self.commit()
        return cursor.rowcount

    def delete(
        self,
        table: str,
        where: str,
        params: tuple[Any, ...] = (),
    ) -> int:
        """
        Delete rows from a table.

        Args:
            table: Table name
            where: WHERE clause (without WHERE)
            params: Parameters for WHERE clause

        Returns:
            Number of rows deleted
        """
        sql = f"DELETE FROM {table} WHERE {where}"
        cursor = self.execute(sql, params)
        self.commit()
        return cursor.rowcount

    def commit(self) -> None:
        """Commit the current transaction."""
        if self._conn:
            self._conn.commit()

    def rollback(self) -> None:
        """Rollback the current transaction."""
        if self._conn:
            self._conn.rollback()

    def __enter__(self) -> AppDatabase:
        """Context manager entry."""
        self.open()
        return self

    def __exit__(self, exc_type: Any, exc_val: Any, exc_tb: Any) -> None:
        """Context manager exit."""
        if exc_type:
            self.rollback()
        self.close()
