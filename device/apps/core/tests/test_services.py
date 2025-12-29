"""Tests for CoreServices registry."""

from __future__ import annotations

import pytest
from device.apps.core.services import (
    CoreServices,
    get_core_services,
    reset_core_services,
)


@pytest.fixture
def services() -> CoreServices:
    """Create a fresh CoreServices instance for testing."""
    return CoreServices()


@pytest.fixture(autouse=True)
def reset_global() -> None:
    """Reset global services before each test."""
    reset_core_services()
    yield
    reset_core_services()


class TestCoreServices:
    """Tests for the CoreServices class."""

    def test_register_and_get_service(self, services: CoreServices) -> None:
        """Test registering and retrieving a service."""
        services.register("test", lambda: "test_instance")

        result = services.get("test")
        assert result == "test_instance"

    def test_singleton_returns_same_instance(self, services: CoreServices) -> None:
        """Test that singleton services return the same instance."""
        call_count = 0

        def factory() -> dict:  # type: ignore[type-arg]
            nonlocal call_count
            call_count += 1
            return {"id": call_count}

        services.register("singleton", factory, singleton=True)

        first = services.get("singleton")
        second = services.get("singleton")

        assert first is second
        assert call_count == 1
        assert first["id"] == 1

    def test_non_singleton_creates_new_instances(self, services: CoreServices) -> None:
        """Test that non-singleton services create new instances."""
        call_count = 0

        def factory() -> dict:  # type: ignore[type-arg]
            nonlocal call_count
            call_count += 1
            return {"id": call_count}

        services.register("non_singleton", factory, singleton=False)

        first = services.get("non_singleton")
        second = services.get("non_singleton")

        assert first is not second
        assert call_count == 2
        assert first["id"] == 1
        assert second["id"] == 2

    def test_get_nonexistent_service_returns_none(self, services: CoreServices) -> None:
        """Test that getting a nonexistent service returns None."""
        result = services.get("nonexistent")
        assert result is None

    def test_has_service(self, services: CoreServices) -> None:
        """Test checking if a service exists."""
        services.register("exists", lambda: "instance")

        assert services.has("exists") is True
        assert services.has("not_exists") is False

    def test_get_all_names(self, services: CoreServices) -> None:
        """Test getting all registered service names."""
        services.register("service1", lambda: 1)
        services.register("service2", lambda: 2)
        services.register("service3", lambda: 3)

        names = services.get_all_names()
        assert sorted(names) == ["service1", "service2", "service3"]

    def test_register_instance(self, services: CoreServices) -> None:
        """Test registering an existing instance."""
        instance = {"pre": "created"}
        services.register_instance("precreated", instance)

        result = services.get("precreated")
        assert result is instance

    def test_get_service_info(self, services: CoreServices) -> None:
        """Test getting service information."""
        services.register("info_test", lambda: "test", description="A test service")

        info = services.get_service_info("info_test")
        assert info is not None
        assert info["name"] == "info_test"
        assert info["singleton"] is True
        assert info["description"] == "A test service"
        assert info["instantiated"] is False

        # Instantiate and check again
        services.get("info_test")
        info = services.get_service_info("info_test")
        assert info is not None
        assert info["instantiated"] is True

    def test_get_service_info_nonexistent(self, services: CoreServices) -> None:
        """Test getting info for nonexistent service."""
        info = services.get_service_info("nonexistent")
        assert info is None

    def test_overwrite_service_warning(
        self, services: CoreServices, caplog: pytest.LogCaptureFixture
    ) -> None:
        """Test that overwriting a service logs a warning."""
        services.register("duplicate", lambda: 1)
        services.register("duplicate", lambda: 2)

        assert "Overwriting existing service" in caplog.text

    def test_clear_removes_all(self, services: CoreServices) -> None:
        """Test that clear removes all services and instances."""
        services.register("to_clear", lambda: "value")
        services.get("to_clear")  # Instantiate

        services.clear()

        assert services.get_all_names() == []
        assert services.get("to_clear") is None


class TestGlobalCoreServices:
    """Tests for global services functions."""

    def test_get_core_services_returns_singleton(self) -> None:
        """Test that get_core_services returns the same instance."""
        first = get_core_services()
        second = get_core_services()
        assert first is second

    def test_reset_core_services(self) -> None:
        """Test that reset clears the global instance."""
        services = get_core_services()
        services.register("test", lambda: "value")

        reset_core_services()
        new_services = get_core_services()

        assert new_services is not services
        assert new_services.get("test") is None
