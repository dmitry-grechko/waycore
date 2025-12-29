"""
System Defaults - Restore system to default configuration.

Creates fresh databases with essential default values after factory reset.
"""

from __future__ import annotations

import sqlite3
from pathlib import Path
from typing import Any


class SystemDefaults:
    """
    Restores system to default configuration.

    Creates fresh databases with essential default values.
    This ensures the system is in a known good state after reset.
    """

    # Default user settings
    DEFAULT_SETTINGS: dict[str, str] = {
        "units": "metric",
        "theme": "dark",
        "language": "en",
        "timezone": "UTC",
        "first_run": "true",
        "daylight_mode": "false",
        "haptic_feedback": "true",
        "screen_timeout": "60",
    }

    def __init__(self, data_dir: Path) -> None:
        """
        Initialize the defaults manager.

        Args:
            data_dir: Path to data directory
        """
        self._data_dir = Path(data_dir)
        self._data_dir.mkdir(parents=True, exist_ok=True)

    def restore(self) -> dict[str, Any]:
        """
        Restore all defaults and return summary.

        Creates fresh database files with default schemas and values.

        Returns:
            Dictionary describing what was restored
        """
        results: dict[str, Any] = {}

        # Create general.sqlite3 with defaults
        results["general"] = self._restore_general_database()

        # Ensure apps database directory exists
        (self._data_dir / "apps").mkdir(exist_ok=True)

        return results

    def _restore_general_database(self) -> dict[str, Any]:
        """
        Create general.sqlite3 with default schema and values.

        Returns:
            Dictionary describing created tables and settings
        """
        db_path = self._data_dir / "general.sqlite3"
        conn = sqlite3.connect(str(db_path))

        try:
            # Create essential tables
            conn.executescript(
                """
                -- User settings table
                CREATE TABLE IF NOT EXISTS user_settings (
                    key TEXT PRIMARY KEY,
                    value TEXT,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                );

                -- Sensor readings (historical)
                CREATE TABLE IF NOT EXISTS sensor_readings (
                    id TEXT PRIMARY KEY,
                    sensor_type TEXT NOT NULL,
                    value TEXT NOT NULL,
                    unit TEXT,
                    source TEXT,
                    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                );

                -- Saved locations
                CREATE TABLE IF NOT EXISTS locations (
                    id TEXT PRIMARY KEY,
                    name TEXT,
                    latitude REAL,
                    longitude REAL,
                    altitude REAL,
                    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                );

                -- Notes
                CREATE TABLE IF NOT EXISTS notes (
                    id TEXT PRIMARY KEY,
                    title TEXT NOT NULL,
                    content TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                );

                -- Create indexes for common queries
                CREATE INDEX IF NOT EXISTS idx_sensor_type
                    ON sensor_readings(sensor_type);
                CREATE INDEX IF NOT EXISTS idx_sensor_timestamp
                    ON sensor_readings(timestamp);
                CREATE INDEX IF NOT EXISTS idx_notes_updated
                    ON notes(updated_at);
            """
            )

            # Insert default settings
            for key, value in self.DEFAULT_SETTINGS.items():
                conn.execute(
                    "INSERT OR REPLACE INTO user_settings (key, value) VALUES (?, ?)",
                    (key, value),
                )

            conn.commit()

            return {
                "tables": ["user_settings", "sensor_readings", "locations", "notes"],
                "settings_count": len(self.DEFAULT_SETTINGS),
            }

        finally:
            conn.close()

    def get_default_setting(self, key: str) -> str | None:
        """
        Get the default value for a setting.

        Args:
            key: Setting key

        Returns:
            Default value or None if not defined
        """
        return self.DEFAULT_SETTINGS.get(key)

    @classmethod
    def get_all_defaults(cls) -> dict[str, str]:
        """
        Get all default settings.

        Returns:
            Copy of all default settings
        """
        return cls.DEFAULT_SETTINGS.copy()
