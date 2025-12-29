"""Tests for FactoryResetManager."""

from __future__ import annotations

import sqlite3
import tempfile
from pathlib import Path

import pytest
from device.apps.core.reset.defaults import SystemDefaults
from device.apps.core.reset.factory_reset import FactoryResetManager


@pytest.fixture
def temp_dirs() -> tuple[Path, Path]:
    """Create temporary data and storage directories."""
    with tempfile.TemporaryDirectory() as tmpdir:
        base = Path(tmpdir)
        data_dir = base / "data"
        storage_dir = base / "storage"
        data_dir.mkdir()
        storage_dir.mkdir()

        # Create subdirs
        (data_dir / "apps").mkdir()
        (storage_dir / "photos").mkdir()
        (storage_dir / "cache").mkdir()
        (storage_dir / "logs").mkdir()

        yield data_dir, storage_dir


@pytest.fixture
def populated_dirs(temp_dirs: tuple[Path, Path]) -> tuple[Path, Path]:
    """Create directories with sample data."""
    data_dir, storage_dir = temp_dirs

    # Create core database
    core_db = data_dir / "general.sqlite3"
    conn = sqlite3.connect(str(core_db))
    conn.execute("CREATE TABLE test (id INTEGER PRIMARY KEY, value TEXT)")
    conn.execute("INSERT INTO test VALUES (1, 'test data')")
    conn.commit()
    conn.close()

    # Create app database
    app_db = data_dir / "apps" / "com.test.app.sqlite3"
    conn = sqlite3.connect(str(app_db))
    conn.execute("CREATE TABLE app_data (id INTEGER PRIMARY KEY)")
    conn.commit()
    conn.close()

    # Create storage files
    (storage_dir / "photos" / "photo1.jpg").write_bytes(b"fake image")
    (storage_dir / "cache" / "temp.dat").write_bytes(b"cached")
    (storage_dir / "logs" / "system.log").write_text("log entry")

    return data_dir, storage_dir


def test_reset_clears_all_databases(populated_dirs: tuple[Path, Path]) -> None:
    """Test that all databases are cleared and recreated."""
    data_dir, storage_dir = populated_dirs

    manager = FactoryResetManager(data_dir, storage_dir)
    result = manager.reset_all()

    assert result.success
    assert "general.sqlite3" in result.databases_cleared
    assert "apps/com.test.app.sqlite3" in result.databases_cleared

    # Core database is recreated with defaults
    assert (data_dir / "general.sqlite3").exists()

    # App databases should be gone
    assert not (data_dir / "apps" / "com.test.app.sqlite3").exists()

    # Verify the recreated database has fresh schema (no old test data)
    conn = sqlite3.connect(str(data_dir / "general.sqlite3"))
    tables = conn.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='test'"
    ).fetchall()
    assert len(tables) == 0  # Old 'test' table should not exist
    conn.close()


def test_reset_clears_storage(populated_dirs: tuple[Path, Path]) -> None:
    """Test that storage directories are cleared."""
    data_dir, storage_dir = populated_dirs

    manager = FactoryResetManager(data_dir, storage_dir)
    result = manager.reset_all()

    assert result.success
    assert "photos/" in result.storage_cleared
    assert "cache/" in result.storage_cleared

    # Verify files are gone
    assert not (storage_dir / "photos" / "photo1.jpg").exists()
    assert not (storage_dir / "cache" / "temp.dat").exists()


def test_reset_keeps_logs_when_requested(populated_dirs: tuple[Path, Path]) -> None:
    """Test that logs are preserved when requested."""
    data_dir, storage_dir = populated_dirs

    manager = FactoryResetManager(data_dir, storage_dir)
    result = manager.reset_all(keep_system_logs=True)

    assert result.success
    assert "logs/" not in result.storage_cleared

    # Logs should still exist
    assert (storage_dir / "logs" / "system.log").exists()


def test_reset_restores_defaults(populated_dirs: tuple[Path, Path]) -> None:
    """Test that system defaults are restored."""
    data_dir, storage_dir = populated_dirs

    manager = FactoryResetManager(data_dir, storage_dir)
    result = manager.reset_all()

    assert result.success
    assert "general" in result.defaults_restored

    # Verify database was recreated with defaults
    assert (data_dir / "general.sqlite3").exists()

    conn = sqlite3.connect(str(data_dir / "general.sqlite3"))
    cursor = conn.execute("SELECT value FROM user_settings WHERE key = 'theme'")
    row = cursor.fetchone()
    assert row is not None
    assert row[0] == "dark"
    conn.close()


def test_reset_recreates_storage_structure(
    populated_dirs: tuple[Path, Path],
) -> None:
    """Test that essential directories are recreated."""
    data_dir, storage_dir = populated_dirs

    manager = FactoryResetManager(data_dir, storage_dir)
    manager.reset_all()

    # Essential directories should exist
    assert (storage_dir / "photos").exists()
    assert (storage_dir / "cache").exists()
    assert (storage_dir / "downloads").exists()
    assert (storage_dir / "apps").exists()
    assert (storage_dir / "logs").exists()


def test_pre_reset_hooks_called(temp_dirs: tuple[Path, Path]) -> None:
    """Test that pre-reset hooks are called."""
    data_dir, storage_dir = temp_dirs

    hook_called = []

    def my_hook() -> None:
        hook_called.append(True)

    manager = FactoryResetManager(data_dir, storage_dir)
    manager.register_pre_reset_hook(my_hook)
    manager.reset_all()

    assert len(hook_called) == 1


def test_post_reset_hooks_called(temp_dirs: tuple[Path, Path]) -> None:
    """Test that post-reset hooks are called."""
    data_dir, storage_dir = temp_dirs

    hook_called = []

    def my_hook() -> None:
        hook_called.append(True)

    manager = FactoryResetManager(data_dir, storage_dir)
    manager.register_post_reset_hook(my_hook)
    manager.reset_all()

    assert len(hook_called) == 1


def test_hooks_continue_on_error(temp_dirs: tuple[Path, Path]) -> None:
    """Test that hook errors don't stop reset."""
    data_dir, storage_dir = temp_dirs

    calls = []

    def failing_hook() -> None:
        calls.append("failing")
        raise RuntimeError("Hook failed!")

    def success_hook() -> None:
        calls.append("success")

    manager = FactoryResetManager(data_dir, storage_dir)
    manager.register_pre_reset_hook(failing_hook)
    manager.register_pre_reset_hook(success_hook)

    result = manager.reset_all()

    # Both hooks should have been attempted
    assert "failing" in calls
    assert "success" in calls
    assert result.success  # Reset should still succeed


def test_get_data_summary(populated_dirs: tuple[Path, Path]) -> None:
    """Test data summary generation."""
    data_dir, storage_dir = populated_dirs

    manager = FactoryResetManager(data_dir, storage_dir)
    summary = manager.get_data_summary()

    assert "databases" in summary
    assert "storage_dirs" in summary
    assert "total_size_bytes" in summary

    # Should find our databases
    db_names = [db["name"] for db in summary["databases"]]
    assert any("general.sqlite3" in name for name in db_names)


def test_reset_without_storage_dir(temp_dirs: tuple[Path, Path]) -> None:
    """Test reset works with data-only (no storage)."""
    data_dir, _ = temp_dirs

    # Create a database
    db = data_dir / "test.sqlite3"
    conn = sqlite3.connect(str(db))
    conn.execute("CREATE TABLE t (id INTEGER)")
    conn.close()

    manager = FactoryResetManager(data_dir)  # No storage_dir
    result = manager.reset_all()

    assert result.success
    assert "test.sqlite3" in result.databases_cleared
    assert len(result.storage_cleared) == 0


def test_system_defaults_restore() -> None:
    """Test SystemDefaults creates proper schema."""
    with tempfile.TemporaryDirectory() as tmpdir:
        data_dir = Path(tmpdir)
        defaults = SystemDefaults(data_dir)
        result = defaults.restore()

        assert "general" in result
        assert "tables" in result["general"]

        # Verify database structure
        db_path = data_dir / "general.sqlite3"
        conn = sqlite3.connect(str(db_path))

        # Check tables exist
        tables = conn.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()
        table_names = [t[0] for t in tables]

        assert "user_settings" in table_names
        assert "sensor_readings" in table_names
        assert "locations" in table_names
        assert "notes" in table_names

        conn.close()


def test_system_defaults_settings() -> None:
    """Test that all default settings are applied."""
    with tempfile.TemporaryDirectory() as tmpdir:
        data_dir = Path(tmpdir)
        defaults = SystemDefaults(data_dir)
        defaults.restore()

        db_path = data_dir / "general.sqlite3"
        conn = sqlite3.connect(str(db_path))

        # Check all defaults are present
        for key, expected in SystemDefaults.DEFAULT_SETTINGS.items():
            cursor = conn.execute("SELECT value FROM user_settings WHERE key = ?", (key,))
            row = cursor.fetchone()
            assert row is not None, f"Setting '{key}' not found"
            assert row[0] == expected, f"Setting '{key}' has wrong value"

        conn.close()
