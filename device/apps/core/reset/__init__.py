"""
Factory reset module for Waycore.

Provides schema-agnostic factory reset functionality that:
- Discovers and clears all databases automatically
- Clears all storage directories
- Restores system defaults
- Supports pre/post reset hooks for apps
"""

from __future__ import annotations

from .factory_reset import FactoryResetManager, ResetResult

__all__ = ["FactoryResetManager", "ResetResult"]
