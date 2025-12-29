"""
SharedDataReader - Read-only access to shared/core database tables.

Apps can access specific tables that are documented and stable.
Write access is NOT provided - apps must use their own database.
"""

from __future__ import annotations

import sqlite3
from pathlib import Path
from typing import Any


class SharedDataReader:
    """
    Provides read-only access to whitelisted tables in core databases.

    Apps can query specific tables from:
    - general.sqlite3: Sensor readings, locations, settings
    - mesh.sqlite3: Nodes, messages

    All queries are executed in read-only mode to prevent data corruption.
    """

    # Allowed tables and columns that apps can read
    # Format: {"database": {"table": ["columns"]}}
    ALLOWED_TABLES: dict[str, dict[str, list[str]]] = {
        "general.sqlite3": {
            "sensor_readings": [
                "id",
                "sensor_type",
                "value",
                "unit",
                "timestamp",
                "source",
            ],
            "locations": [
                "id",
                "name",
                "latitude",
                "longitude",
                "altitude",
                "timestamp",
            ],
            "user_settings": ["key", "value", "updated_at"],
            "notes": [
                "id",
                "title",
                "content",
                "created_at",
                "updated_at",
            ],
        },
        "mesh.sqlite3": {
            "nodes": [
                "node_id",
                "short_name",
                "long_name",
                "hardware_model",
                "last_seen",
                "snr",
                "rssi",
            ],
            "messages": [
                "id",
                "from_node",
                "to_node",
                "channel",
                "text",
                "timestamp",
                "is_read",
            ],
        },
        "ai.sqlite3": {
            "conversations": [
                "id",
                "title",
                "created_at",
                "updated_at",
            ],
            "messages": [
                "id",
                "conversation_id",
                "role",
                "content",
                "timestamp",
            ],
        },
    }

    def __init__(self, data_dir: Path) -> None:
        """
        Initialize the shared data reader.

        Args:
            data_dir: Path to the data directory containing database files
        """
        self._data_dir = Path(data_dir)

    def query(
        self,
        database: str,
        table: str,
        columns: list[str] | None = None,
        where: str | None = None,
        params: tuple[Any, ...] = (),
        order_by: str | None = None,
        limit: int | None = None,
    ) -> list[dict[str, Any]]:
        """
        Execute a read-only query on a shared table.

        Args:
            database: Database name (e.g., "general.sqlite3")
            table: Table name (must be in ALLOWED_TABLES)
            columns: Columns to select (None = all allowed columns)
            where: WHERE clause (without WHERE keyword)
            params: Parameters for WHERE clause
            order_by: ORDER BY clause (without ORDER BY keyword)
            limit: Maximum rows to return

        Returns:
            List of row dictionaries

        Raises:
            PermissionError: If table/column access is not allowed
            FileNotFoundError: If database file doesn't exist
        """
        # Validate database access
        if database not in self.ALLOWED_TABLES:
            raise PermissionError(f"Access to database '{database}' not allowed")

        allowed_tables = self.ALLOWED_TABLES[database]
        if table not in allowed_tables:
            raise PermissionError(f"Access to table '{table}' in '{database}' not allowed")

        allowed_cols = allowed_tables[table]

        # Validate columns
        if columns:
            for col in columns:
                if col not in allowed_cols:
                    raise PermissionError(f"Access to column '{col}' in '{table}' not allowed")
            select_cols = columns
        else:
            select_cols = allowed_cols

        # Build SQL query
        col_str = ", ".join(select_cols)
        sql = f"SELECT {col_str} FROM {table}"

        if where:
            sql += f" WHERE {where}"

        if order_by:
            sql += f" ORDER BY {order_by}"

        if limit:
            sql += f" LIMIT {limit}"

        # Execute in read-only mode
        db_path = self._data_dir / database
        if not db_path.exists():
            raise FileNotFoundError(f"Database not found: {db_path}")

        conn = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
        conn.row_factory = sqlite3.Row

        try:
            cursor = conn.execute(sql, params)
            return [dict(row) for row in cursor.fetchall()]
        finally:
            conn.close()

    def get_latest_sensor_reading(self, sensor_type: str) -> dict[str, Any] | None:
        """
        Get the latest reading for a specific sensor type.

        Args:
            sensor_type: Type of sensor (e.g., "temperature", "gps")

        Returns:
            Latest reading dict or None if not found
        """
        try:
            results = self.query(
                "general.sqlite3",
                "sensor_readings",
                where="sensor_type = ?",
                params=(sensor_type,),
                order_by="timestamp DESC",
                limit=1,
            )
            return results[0] if results else None
        except FileNotFoundError:
            return None

    def get_sensor_history(
        self,
        sensor_type: str,
        limit: int = 100,
    ) -> list[dict[str, Any]]:
        """
        Get historical sensor readings.

        Args:
            sensor_type: Type of sensor
            limit: Maximum number of readings to return

        Returns:
            List of readings, newest first
        """
        try:
            return self.query(
                "general.sqlite3",
                "sensor_readings",
                where="sensor_type = ?",
                params=(sensor_type,),
                order_by="timestamp DESC",
                limit=limit,
            )
        except FileNotFoundError:
            return []

    def get_user_setting(self, key: str) -> Any:
        """
        Get a user setting value.

        Args:
            key: Setting key

        Returns:
            Setting value or None if not found
        """
        try:
            results = self.query(
                "general.sqlite3",
                "user_settings",
                columns=["value"],
                where="key = ?",
                params=(key,),
            )
            return results[0]["value"] if results else None
        except FileNotFoundError:
            return None

    def get_locations(self, limit: int = 50) -> list[dict[str, Any]]:
        """
        Get saved locations.

        Args:
            limit: Maximum number of locations

        Returns:
            List of location dicts
        """
        try:
            return self.query(
                "general.sqlite3",
                "locations",
                order_by="timestamp DESC",
                limit=limit,
            )
        except FileNotFoundError:
            return []

    def get_mesh_nodes(self) -> list[dict[str, Any]]:
        """
        Get all known mesh nodes.

        Returns:
            List of node dicts
        """
        try:
            return self.query(
                "mesh.sqlite3",
                "nodes",
                order_by="last_seen DESC",
            )
        except FileNotFoundError:
            return []

    def get_mesh_messages(
        self,
        from_node: str | None = None,
        to_node: str | None = None,
        limit: int = 100,
    ) -> list[dict[str, Any]]:
        """
        Get mesh messages, optionally filtered by node.

        Args:
            from_node: Filter by sender node ID
            to_node: Filter by recipient node ID
            limit: Maximum messages to return

        Returns:
            List of message dicts
        """
        where_parts = []
        params: list[Any] = []

        if from_node:
            where_parts.append("from_node = ?")
            params.append(from_node)

        if to_node:
            where_parts.append("to_node = ?")
            params.append(to_node)

        where = " AND ".join(where_parts) if where_parts else None

        try:
            return self.query(
                "mesh.sqlite3",
                "messages",
                where=where,
                params=tuple(params),
                order_by="timestamp DESC",
                limit=limit,
            )
        except FileNotFoundError:
            return []
