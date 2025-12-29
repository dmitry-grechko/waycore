"""Core services registry for modular apps.

This module provides a registry of core services that are available to all apps.
Services include bridges, database connections, and other shared functionality.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Any, Callable

if TYPE_CHECKING:
    pass

logger = logging.getLogger(__name__)


@dataclass
class ServiceDefinition:
    """Definition of a core service.

    Attributes:
        name: Unique identifier for the service
        factory: Callable that creates the service instance
        singleton: If True, only one instance is created
        description: Human-readable description
    """

    name: str
    factory: Callable[[], Any]
    singleton: bool = True
    description: str = ""


@dataclass
class CoreServices:
    """Registry of core services available to apps.

    Core services include:
    - SensorBridge: Access to sensor data
    - NotesBridge: Note storage and retrieval
    - MeshBridge: Mesh network communication
    - CameraBridge: Camera capture
    - AIBridge: AI/LLM inference
    - Database: Database connections

    Example:
        services = get_core_services()
        services.register("sensor", SensorBridge)
        sensor = services.get("sensor")
    """

    _services: dict[str, ServiceDefinition] = field(default_factory=dict)
    _instances: dict[str, Any] = field(default_factory=dict)

    def register(
        self,
        name: str,
        factory: Callable[[], Any],
        singleton: bool = True,
        description: str = "",
    ) -> None:
        """Register a core service.

        Args:
            name: Unique identifier for the service
            factory: Callable that creates the service instance
            singleton: If True, only one instance is created (default: True)
            description: Human-readable description
        """
        if name in self._services:
            logger.warning(f"Overwriting existing service: {name}")

        self._services[name] = ServiceDefinition(
            name=name,
            factory=factory,
            singleton=singleton,
            description=description,
        )
        logger.debug(f"Registered service: {name}")

    def register_instance(self, name: str, instance: Any, description: str = "") -> None:
        """Register an existing instance as a service.

        This is useful for services that are created elsewhere.

        Args:
            name: Unique identifier for the service
            instance: The pre-created service instance
            description: Human-readable description
        """
        # Create a factory that returns the instance
        self._services[name] = ServiceDefinition(
            name=name,
            factory=lambda: instance,
            singleton=True,
            description=description,
        )
        self._instances[name] = instance
        logger.debug(f"Registered instance: {name}")

    def get(self, name: str) -> Any | None:
        """Get a service instance.

        For singleton services, the same instance is returned on each call.
        For non-singleton services, a new instance is created each time.

        Args:
            name: The service identifier

        Returns:
            The service instance, or None if not found
        """
        if name not in self._services:
            logger.warning(f"Service not found: {name}")
            return None

        service = self._services[name]

        if service.singleton:
            if name not in self._instances:
                try:
                    self._instances[name] = service.factory()
                    logger.debug(f"Created singleton instance: {name}")
                except Exception as e:
                    logger.exception(f"Failed to create service {name}: {e}")
                    return None
            return self._instances[name]
        else:
            try:
                return service.factory()
            except Exception as e:
                logger.exception(f"Failed to create service {name}: {e}")
                return None

    def has(self, name: str) -> bool:
        """Check if a service is registered.

        Args:
            name: The service identifier

        Returns:
            True if the service is registered
        """
        return name in self._services

    def get_all_names(self) -> list[str]:
        """Get all registered service names.

        Returns:
            List of service names
        """
        return list(self._services.keys())

    def get_service_info(self, name: str) -> dict[str, Any] | None:
        """Get information about a service.

        Args:
            name: The service identifier

        Returns:
            Dictionary with service info, or None if not found
        """
        if name not in self._services:
            return None

        service = self._services[name]
        return {
            "name": service.name,
            "singleton": service.singleton,
            "description": service.description,
            "instantiated": name in self._instances,
        }

    def clear(self) -> None:
        """Clear all services and instances.

        This is mainly useful for testing.
        """
        self._services.clear()
        self._instances.clear()


# Global instance
_core_services: CoreServices | None = None


def get_core_services() -> CoreServices:
    """Get the global core services registry.

    Returns:
        The CoreServices singleton
    """
    global _core_services
    if _core_services is None:
        _core_services = CoreServices()
    return _core_services


def reset_core_services() -> None:
    """Reset the global core services registry.

    This is mainly useful for testing.
    """
    global _core_services
    if _core_services is not None:
        _core_services.clear()
    _core_services = None
