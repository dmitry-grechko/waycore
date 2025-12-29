"""Tests for SharedDataReader."""

from __future__ import annotations

import sqlite3
import tempfile
from pathlib import Path

import pytest
from device.apps.core.database.shared_reader import SharedDataReader


@pytest.fixture
def temp_data_dir() -> Path:
    """Create a temporary data directory with test databases."""
    with tempfile.TemporaryDirectory() as tmpdir:
        data_dir = Path(tmpdir)

        # Create general.sqlite3 with test data
        general_db = data_dir / "general.sqlite3"
        conn = sqlite3.connect(str(general_db))
        conn.execute(
            """
            CREATE TABLE sensor_readings (
                id INTEGER PRIMARY KEY,
                sensor_type TEXT,
                value REAL,
                unit TEXT,
                timestamp TEXT,
                source TEXT
            )
        """
        )
        conn.execute(
            """
            INSERT INTO sensor_readings (sensor_type, value, unit, timestamp, source)
            VALUES ('temperature', 22.5, 'C', '2024-01-01 12:00:00', 'bme280')
        """
        )
        conn.execute(
            """
            CREATE TABLE user_settings (
                key TEXT PRIMARY KEY,
                value TEXT,
                updated_at TEXT
            )
        """
        )
        conn.execute(
            """
            INSERT INTO user_settings (key, value, updated_at)
            VALUES ('theme', 'dark', '2024-01-01')
        """
        )
        conn.commit()
        conn.close()

        # Create mesh.sqlite3 with test data
        mesh_db = data_dir / "mesh.sqlite3"
        conn = sqlite3.connect(str(mesh_db))
        conn.execute(
            """
            CREATE TABLE nodes (
                node_id TEXT PRIMARY KEY,
                short_name TEXT,
                long_name TEXT,
                hardware_model TEXT,
                last_seen TEXT,
                snr REAL,
                rssi INTEGER
            )
        """
        )
        conn.execute(
            """
            INSERT INTO nodes (node_id, short_name, long_name, last_seen)
            VALUES ('!abc123', 'Node1', 'First Node', '2024-01-01 12:00:00')
        """
        )
        conn.commit()
        conn.close()

        yield data_dir


def test_query_allowed_table(temp_data_dir: Path) -> None:
    """Test querying an allowed table."""
    reader = SharedDataReader(temp_data_dir)

    results = reader.query("general.sqlite3", "sensor_readings")

    assert len(results) == 1
    assert results[0]["sensor_type"] == "temperature"
    assert results[0]["value"] == 22.5


def test_query_with_where_clause(temp_data_dir: Path) -> None:
    """Test querying with WHERE clause."""
    reader = SharedDataReader(temp_data_dir)

    results = reader.query(
        "general.sqlite3",
        "sensor_readings",
        where="sensor_type = ?",
        params=("temperature",),
    )

    assert len(results) == 1
    assert results[0]["sensor_type"] == "temperature"


def test_query_with_specific_columns(temp_data_dir: Path) -> None:
    """Test querying specific columns."""
    reader = SharedDataReader(temp_data_dir)

    results = reader.query(
        "general.sqlite3",
        "sensor_readings",
        columns=["sensor_type", "value"],
    )

    assert len(results) == 1
    assert "sensor_type" in results[0]
    assert "value" in results[0]
    assert "unit" not in results[0]  # Not requested


def test_query_disallowed_database(temp_data_dir: Path) -> None:
    """Test that querying disallowed database raises error."""
    reader = SharedDataReader(temp_data_dir)

    with pytest.raises(PermissionError, match="not allowed"):
        reader.query("secret.sqlite3", "passwords")


def test_query_disallowed_table(temp_data_dir: Path) -> None:
    """Test that querying disallowed table raises error."""
    reader = SharedDataReader(temp_data_dir)

    with pytest.raises(PermissionError, match="not allowed"):
        reader.query("general.sqlite3", "admin_secrets")


def test_query_disallowed_column(temp_data_dir: Path) -> None:
    """Test that querying disallowed column raises error."""
    reader = SharedDataReader(temp_data_dir)

    with pytest.raises(PermissionError, match="not allowed"):
        reader.query(
            "general.sqlite3",
            "sensor_readings",
            columns=["secret_key"],  # Not in allowed columns
        )


def test_get_latest_sensor_reading(temp_data_dir: Path) -> None:
    """Test convenience method for sensor readings."""
    reader = SharedDataReader(temp_data_dir)

    reading = reader.get_latest_sensor_reading("temperature")

    assert reading is not None
    assert reading["value"] == 22.5


def test_get_latest_sensor_reading_not_found(temp_data_dir: Path) -> None:
    """Test sensor reading returns None when not found."""
    reader = SharedDataReader(temp_data_dir)

    reading = reader.get_latest_sensor_reading("nonexistent")

    assert reading is None


def test_get_user_setting(temp_data_dir: Path) -> None:
    """Test convenience method for user settings."""
    reader = SharedDataReader(temp_data_dir)

    value = reader.get_user_setting("theme")

    assert value == "dark"


def test_get_user_setting_not_found(temp_data_dir: Path) -> None:
    """Test user setting returns None when not found."""
    reader = SharedDataReader(temp_data_dir)

    value = reader.get_user_setting("nonexistent")

    assert value is None


def test_get_mesh_nodes(temp_data_dir: Path) -> None:
    """Test getting mesh nodes."""
    reader = SharedDataReader(temp_data_dir)

    nodes = reader.get_mesh_nodes()

    assert len(nodes) == 1
    assert nodes[0]["short_name"] == "Node1"


def test_database_not_found(temp_data_dir: Path) -> None:
    """Test that FileNotFoundError is raised for missing database."""
    reader = SharedDataReader(temp_data_dir)

    with pytest.raises(FileNotFoundError):
        reader.query("ai.sqlite3", "conversations")
