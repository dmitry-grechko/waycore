"""
Factory Reset Manager - Schema-agnostic system reset.

This module provides comprehensive factory reset functionality that:
- Automatically discovers all databases (no hardcoded table names)
- Clears all storage directories
- Restores system defaults
- Supports app lifecycle hooks
"""

from __future__ import annotations

import shutil
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Callable


@dataclass
class ResetResult:
    """Result of a factory reset operation."""

    success: bool = False
    databases_cleared: list[str] = field(default_factory=list)
    storage_cleared: list[str] = field(default_factory=list)
    defaults_restored: dict[str, Any] = field(default_factory=dict)
    error: str | None = None


class FactoryResetManager:
    """
    Manages complete factory reset of the system.

    This is schema-agnostic - it discovers and deletes all data
    without needing to know the structure of individual databases.

    Usage:
        manager = FactoryResetManager(
            data_dir=Path("/app/data"),
            storage_dir=Path("/app/storage")
        )
        result = manager.reset_all()
    """

    def __init__(
        self,
        data_dir: Path,
        storage_dir: Path | None = None,
    ) -> None:
        """
        Initialize the reset manager.

        Args:
            data_dir: Path to data directory (contains databases)
            storage_dir: Path to storage directory (photos, cache, etc.)
        """
        self._data_dir = Path(data_dir)
        self._storage_dir = Path(storage_dir) if storage_dir else None
        self._pre_reset_hooks: list[Callable[[], None]] = []
        self._post_reset_hooks: list[Callable[[], None]] = []

    def register_pre_reset_hook(self, hook: Callable[[], None]) -> None:
        """
        Register a callback to run before reset.

        Pre-reset hooks can be used by apps to:
        - Close database connections
        - Cancel pending operations
        - Save critical state externally

        Args:
            hook: Callable to run before reset
        """
        self._pre_reset_hooks.append(hook)

    def register_post_reset_hook(self, hook: Callable[[], None]) -> None:
        """
        Register a callback to run after reset.

        Post-reset hooks can be used to:
        - Reinitialize services
        - Trigger first-run setup

        Args:
            hook: Callable to run after reset
        """
        self._post_reset_hooks.append(hook)

    def reset_all(self, keep_system_logs: bool = False) -> ResetResult:
        """
        Perform complete factory reset.

        This will:
        1. Run pre-reset hooks
        2. Delete all SQLite databases
        3. Clear all storage directories
        4. Restore system defaults
        5. Run post-reset hooks

        Args:
            keep_system_logs: If True, preserve logs for debugging

        Returns:
            ResetResult with details of what was cleared
        """
        result = ResetResult()

        try:
            # 1. Notify apps/services of impending reset
            self._run_pre_reset_hooks()

            # 2. Clear all databases
            result.databases_cleared = self._clear_all_databases()

            # 3. Clear all storage
            if self._storage_dir:
                result.storage_cleared = self._clear_all_storage(keep_system_logs)

            # 4. Restore system defaults
            result.defaults_restored = self._restore_defaults()

            # 5. Notify apps/services reset is complete
            self._run_post_reset_hooks()

            result.success = True

        except Exception as e:
            result.success = False
            result.error = str(e)

        return result

    def _clear_all_databases(self) -> list[str]:
        """
        Find and delete ALL SQLite databases.

        This is intentionally schema-agnostic - we delete entire
        database files rather than specific tables. This ensures:
        - No tables are missed
        - No schema knowledge required
        - Works with any app's database

        Returns:
            List of cleared database names
        """
        cleared: list[str] = []

        if not self._data_dir.exists():
            return cleared

        # Core databases in data_dir/
        for db_file in self._data_dir.glob("*.sqlite3"):
            db_file.unlink()
            cleared.append(str(db_file.name))

        # Also match .db extension
        for db_file in self._data_dir.glob("*.db"):
            db_file.unlink()
            cleared.append(str(db_file.name))

        # App-specific databases in data_dir/apps/
        apps_db_dir = self._data_dir / "apps"
        if apps_db_dir.exists():
            for db_file in apps_db_dir.glob("*.sqlite3"):
                db_file.unlink()
                cleared.append(f"apps/{db_file.name}")

            for db_file in apps_db_dir.glob("*.db"):
                db_file.unlink()
                cleared.append(f"apps/{db_file.name}")

        # Recursively find any other database files
        for db_file in self._data_dir.rglob("*.sqlite3"):
            if db_file.exists():  # May have been deleted above
                relative = db_file.relative_to(self._data_dir)
                if str(relative) not in cleared:
                    db_file.unlink()
                    cleared.append(str(relative))

        return cleared

    def _clear_all_storage(self, keep_logs: bool = False) -> list[str]:
        """
        Clear all storage directories.

        Storage typically includes:
        - photos/
        - cache/
        - downloads/
        - apps/{app_id}/

        Args:
            keep_logs: If True, preserve logs/ directory

        Returns:
            List of cleared directory/file names
        """
        cleared: list[str] = []

        if not self._storage_dir or not self._storage_dir.exists():
            return cleared

        for item in self._storage_dir.iterdir():
            # Optionally keep logs
            if keep_logs and item.name == "logs":
                continue

            if item.is_dir():
                shutil.rmtree(item)
                cleared.append(item.name + "/")
            else:
                item.unlink()
                cleared.append(item.name)

        # Recreate essential directories
        self._ensure_storage_structure()

        return cleared

    def _ensure_storage_structure(self) -> None:
        """Recreate essential storage directories after clearing."""
        if not self._storage_dir:
            return

        essential_dirs = [
            self._storage_dir / "photos",
            self._storage_dir / "cache",
            self._storage_dir / "downloads",
            self._storage_dir / "apps",
            self._storage_dir / "logs",
        ]

        for dir_path in essential_dirs:
            dir_path.mkdir(parents=True, exist_ok=True)

    def _restore_defaults(self) -> dict[str, Any]:
        """
        Restore system to default configuration.

        Creates fresh database with default settings.

        Returns:
            Dictionary describing restored defaults
        """
        from .defaults import SystemDefaults

        defaults = SystemDefaults(self._data_dir)
        return defaults.restore()

    def _run_pre_reset_hooks(self) -> None:
        """Run all pre-reset hooks, catching errors."""
        for hook in self._pre_reset_hooks:
            try:
                hook()
            except Exception as e:
                print(f"Pre-reset hook failed: {e}")

    def _run_post_reset_hooks(self) -> None:
        """Run all post-reset hooks, catching errors."""
        for hook in self._post_reset_hooks:
            try:
                hook()
            except Exception as e:
                print(f"Post-reset hook failed: {e}")

    def get_data_summary(self) -> dict[str, Any]:
        """
        Get a summary of data that would be cleared.

        Useful for showing users what will be deleted before reset.

        Returns:
            Dictionary with database and storage file counts/sizes
        """
        summary: dict[str, Any] = {
            "databases": [],
            "storage_dirs": [],
            "total_size_bytes": 0,
        }

        # Count databases
        if self._data_dir.exists():
            for pattern in ["*.sqlite3", "*.db"]:
                for db_file in self._data_dir.rglob(pattern):
                    size = db_file.stat().st_size
                    summary["databases"].append(
                        {
                            "name": str(db_file.relative_to(self._data_dir)),
                            "size_bytes": size,
                        }
                    )
                    summary["total_size_bytes"] += size

        # Count storage
        if self._storage_dir and self._storage_dir.exists():
            for item in self._storage_dir.iterdir():
                if item.is_dir():
                    # Count files in directory
                    file_count = sum(1 for _ in item.rglob("*") if _.is_file())
                    dir_size = sum(f.stat().st_size for f in item.rglob("*") if f.is_file())
                    summary["storage_dirs"].append(
                        {
                            "name": item.name,
                            "file_count": file_count,
                            "size_bytes": dir_size,
                        }
                    )
                    summary["total_size_bytes"] += dir_size

        return summary
