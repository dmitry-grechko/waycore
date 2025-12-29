"""Tests for AppDatabase."""

from __future__ import annotations

import tempfile
from pathlib import Path

import pytest
from device.apps.core.database.app_database import (
    AppDatabase,
    DatabaseConfig,
    Migration,
    TableColumn,
    TableDefinition,
    TableIndex,
)


@pytest.fixture
def temp_data_dir() -> Path:
    """Create a temporary data directory."""
    with tempfile.TemporaryDirectory() as tmpdir:
        yield Path(tmpdir)


@pytest.fixture
def sample_config() -> DatabaseConfig:
    """Create a sample database configuration."""
    return DatabaseConfig(
        version=1,
        tables=[
            TableDefinition(
                name="notes",
                columns=[
                    TableColumn(name="id", type="INTEGER", primary=True),
                    TableColumn(name="title", type="TEXT", nullable=False),
                    TableColumn(name="content", type="TEXT"),
                    TableColumn(
                        name="created_at",
                        type="TIMESTAMP",
                        default="CURRENT_TIMESTAMP",
                    ),
                ],
                indexes=[
                    TableIndex(name="idx_notes_created", columns=["created_at"]),
                ],
            ),
        ],
    )


def test_database_creation(temp_data_dir: Path) -> None:
    """Test that database file is created."""
    db = AppDatabase("com.test.app", temp_data_dir)
    db.initialize()

    assert db.path.exists()
    assert db.is_open

    db.close()


def test_database_path(temp_data_dir: Path) -> None:
    """Test database path is correct."""
    db = AppDatabase("com.test.app", temp_data_dir)

    expected = temp_data_dir / "apps" / "com.test.app.sqlite3"
    assert db.path == expected


def test_schema_creation(temp_data_dir: Path, sample_config: DatabaseConfig) -> None:
    """Test that tables are created from config."""
    db = AppDatabase("com.test.notes", temp_data_dir, sample_config)
    db.initialize()

    # Verify table exists
    cursor = db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='notes'")
    assert cursor.fetchone() is not None

    # Verify index exists
    cursor = db.execute(
        "SELECT name FROM sqlite_master WHERE type='index' AND name='idx_notes_created'"
    )
    assert cursor.fetchone() is not None

    db.close()


def test_version_tracking(temp_data_dir: Path, sample_config: DatabaseConfig) -> None:
    """Test schema version is tracked."""
    db = AppDatabase("com.test.app", temp_data_dir, sample_config)
    db.initialize()

    assert db.get_version() == 1

    db.close()


def test_insert_and_fetch(temp_data_dir: Path, sample_config: DatabaseConfig) -> None:
    """Test inserting and fetching data."""
    db = AppDatabase("com.test.notes", temp_data_dir, sample_config)
    db.initialize()

    # Insert
    row_id = db.insert("notes", {"title": "Test Note", "content": "Hello world"})
    assert row_id > 0

    # Fetch
    note = db.fetchone("SELECT * FROM notes WHERE id = ?", (row_id,))
    assert note is not None
    assert note["title"] == "Test Note"
    assert note["content"] == "Hello world"

    db.close()


def test_update(temp_data_dir: Path, sample_config: DatabaseConfig) -> None:
    """Test updating data."""
    db = AppDatabase("com.test.notes", temp_data_dir, sample_config)
    db.initialize()

    # Insert
    row_id = db.insert("notes", {"title": "Original"})

    # Update
    affected = db.update(
        "notes",
        {"title": "Updated"},
        "id = ?",
        (row_id,),
    )
    assert affected == 1

    # Verify
    note = db.fetchone("SELECT * FROM notes WHERE id = ?", (row_id,))
    assert note is not None
    assert note["title"] == "Updated"

    db.close()


def test_delete(temp_data_dir: Path, sample_config: DatabaseConfig) -> None:
    """Test deleting data."""
    db = AppDatabase("com.test.notes", temp_data_dir, sample_config)
    db.initialize()

    # Insert
    row_id = db.insert("notes", {"title": "To Delete"})

    # Delete
    affected = db.delete("notes", "id = ?", (row_id,))
    assert affected == 1

    # Verify
    note = db.fetchone("SELECT * FROM notes WHERE id = ?", (row_id,))
    assert note is None

    db.close()


def test_fetchall(temp_data_dir: Path, sample_config: DatabaseConfig) -> None:
    """Test fetching all rows."""
    db = AppDatabase("com.test.notes", temp_data_dir, sample_config)
    db.initialize()

    # Insert multiple
    db.insert("notes", {"title": "Note 1"})
    db.insert("notes", {"title": "Note 2"})
    db.insert("notes", {"title": "Note 3"})

    # Fetch all
    notes = db.fetchall("SELECT * FROM notes ORDER BY id")
    assert len(notes) == 3
    assert notes[0]["title"] == "Note 1"
    assert notes[2]["title"] == "Note 3"

    db.close()


def test_migration(temp_data_dir: Path) -> None:
    """Test migration system."""
    # Initial config (v1)
    config_v1 = DatabaseConfig(
        version=1,
        tables=[
            TableDefinition(
                name="items",
                columns=[
                    TableColumn(name="id", type="INTEGER", primary=True),
                    TableColumn(name="name", type="TEXT"),
                ],
            ),
        ],
    )

    # Create database with v1
    db = AppDatabase("com.test.migrate", temp_data_dir, config_v1)
    db.initialize()
    db.insert("items", {"name": "Item 1"})
    db.close()

    # Updated config with migration to v2
    config_v2 = DatabaseConfig(
        version=2,
        tables=[
            TableDefinition(
                name="items",
                columns=[
                    TableColumn(name="id", type="INTEGER", primary=True),
                    TableColumn(name="name", type="TEXT"),
                    TableColumn(name="description", type="TEXT"),
                ],
            ),
        ],
        migrations=[
            Migration(
                version=2,
                up="ALTER TABLE items ADD COLUMN description TEXT",
            ),
        ],
    )

    # Reopen with v2 config
    db = AppDatabase("com.test.migrate", temp_data_dir, config_v2)
    db.initialize()

    # Verify migration ran
    assert db.get_version() == 2

    # Verify new column works
    db.execute("UPDATE items SET description = ? WHERE name = ?", ("A description", "Item 1"))
    item = db.fetchone("SELECT * FROM items WHERE name = ?", ("Item 1",))
    assert item is not None
    assert item["description"] == "A description"

    db.close()


def test_context_manager(temp_data_dir: Path, sample_config: DatabaseConfig) -> None:
    """Test context manager interface."""
    with AppDatabase("com.test.ctx", temp_data_dir, sample_config) as db:
        db.initialize()
        db.insert("notes", {"title": "Context Note"})

        note = db.fetchone("SELECT * FROM notes WHERE title = ?", ("Context Note",))
        assert note is not None

    # Connection should be closed
    assert not db.is_open


def test_multiple_apps_isolated(temp_data_dir: Path) -> None:
    """Test that different apps have isolated databases."""
    config = DatabaseConfig(
        version=1,
        tables=[
            TableDefinition(
                name="data",
                columns=[
                    TableColumn(name="id", type="INTEGER", primary=True),
                    TableColumn(name="value", type="TEXT"),
                ],
            ),
        ],
    )

    # App 1
    db1 = AppDatabase("com.app1", temp_data_dir, config)
    db1.initialize()
    db1.insert("data", {"value": "app1_data"})
    db1.close()

    # App 2
    db2 = AppDatabase("com.app2", temp_data_dir, config)
    db2.initialize()
    db2.insert("data", {"value": "app2_data"})
    db2.close()

    # Verify isolation
    db1 = AppDatabase("com.app1", temp_data_dir)
    db1.open()
    rows = db1.fetchall("SELECT * FROM data")
    assert len(rows) == 1
    assert rows[0]["value"] == "app1_data"
    db1.close()

    db2 = AppDatabase("com.app2", temp_data_dir)
    db2.open()
    rows = db2.fetchall("SELECT * FROM data")
    assert len(rows) == 1
    assert rows[0]["value"] == "app2_data"
    db2.close()
