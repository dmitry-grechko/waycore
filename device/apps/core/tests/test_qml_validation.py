"""QML Validation Tests.

Validates QML files for common errors that would cause runtime failures.
"""

from __future__ import annotations

import re
from pathlib import Path

import pytest

# Get paths
APPS_DIR = Path(__file__).parent.parent.parent
CORE_DIR = APPS_DIR / "core" / "Core"
COMPONENTS_DIR = CORE_DIR / "components"


def get_all_qml_files() -> list[Path]:
    """Get all QML files from migrated apps (excluding legacy ui/qml)."""
    qml_files = []

    # Core components
    if CORE_DIR.exists():
        qml_files.extend(CORE_DIR.glob("*.qml"))
        qml_files.extend(COMPONENTS_DIR.glob("*.qml"))

    # Migrated apps (exclude ui/qml which is legacy)
    for app_dir in APPS_DIR.iterdir():
        if app_dir.is_dir() and app_dir.name not in ("core", "ui", "__pycache__"):
            qml_dir = app_dir / "qml"
            if qml_dir.exists():
                qml_files.extend(qml_dir.glob("*.qml"))

    return qml_files


def get_qmldir_exports() -> set[str]:
    """Get all component names exported from Core qmldir."""
    exports = set()
    qmldir = CORE_DIR / "qmldir"

    if qmldir.exists():
        content = qmldir.read_text()
        for line in content.splitlines():
            line = line.strip()
            if line and not line.startswith("#") and not line.startswith("module"):
                # Format: ComponentName version file.qml
                parts = line.split()
                if len(parts) >= 3:
                    exports.add(parts[0])
                elif line.startswith("singleton"):
                    # singleton Theme 1.0 Theme.qml
                    parts = line.split()
                    if len(parts) >= 4:
                        exports.add(parts[1])

    return exports


class TestQMLSyntax:
    """Test QML files for syntax issues."""

    @pytest.fixture
    def qml_files(self) -> list[Path]:
        """Get all QML files to test."""
        return get_all_qml_files()

    def test_no_uppercase_ids(self, qml_files: list[Path]) -> None:
        """QML IDs cannot start with uppercase letters."""
        errors = []

        for qml_file in qml_files:
            content = qml_file.read_text()
            # Match id: followed by uppercase letter (not in comments)
            for i, line in enumerate(content.splitlines(), 1):
                # Skip comments
                if "//" in line:
                    line = line[: line.index("//")]

                match = re.search(r"\bid:\s*([A-Z][a-zA-Z0-9]*)", line)
                if match:
                    errors.append(
                        f"{qml_file.name}:{i} - ID '{match.group(1)}' starts with uppercase"
                    )

        assert not errors, "QML IDs cannot start with uppercase:\n" + "\n".join(errors)

    def test_no_undefined_assignments(self, qml_files: list[Path]) -> None:
        """Numeric/size properties cannot be assigned 'undefined' directly.

        Note: Conditional anchors like `anchors.right: cond ? parent.right : undefined`
        are valid QML patterns and are excluded from this check.
        """
        errors = []

        # Properties that should never be assigned undefined
        numeric_props = [
            "width",
            "height",
            "implicitWidth",
            "implicitHeight",
            "x",
            "y",
            "opacity",
            "radius",
            "border.width",
        ]
        pattern = r"\b(" + "|".join(numeric_props) + r"):\s*.*undefined"

        for qml_file in qml_files:
            content = qml_file.read_text()
            for i, line in enumerate(content.splitlines(), 1):
                # Skip comments
                if "//" in line:
                    line = line[: line.index("//")]

                # Check for undefined on numeric properties (not anchors)
                if re.search(pattern, line):
                    errors.append(f"{qml_file.name}:{i} - Assignment of 'undefined'")

        assert not errors, "Cannot assign 'undefined' to numeric properties:\n" + "\n".join(errors)

    def test_core_import_has_namespace(self, qml_files: list[Path]) -> None:
        """Core import should use 'as Core' for proper namespace."""
        errors = []

        for qml_file in qml_files:
            # Skip Core's own components
            if "core/Core" in str(qml_file):
                continue

            content = qml_file.read_text()
            # Check if file uses Core.* components
            uses_core = "Core." in content

            if uses_core:
                # Should have "import Core as Core" or similar
                has_proper_import = bool(re.search(r"import\s+Core\s+as\s+Core", content))
                if not has_proper_import:
                    errors.append(
                        f"{qml_file.name} - Uses Core.* but missing 'import Core as Core'"
                    )

        assert not errors, "Missing Core namespace import:\n" + "\n".join(errors)


class TestQMLComponents:
    """Test Core QML components for required properties."""

    def test_theme_has_required_properties(self) -> None:
        """Theme.qml should have all commonly used properties."""
        theme_file = CORE_DIR / "Theme.qml"
        assert theme_file.exists(), "Theme.qml not found"

        content = theme_file.read_text()

        required_props = [
            "background",
            "surface",
            "primary",
            "textPrimary",
            "textSecondary",
            "spacingSmall",
            "spacingMedium",
            "spacingLarge",
            "borderRadius",
            "buttonHeight",
            "touchTargetMin",
            "success",
            "error",
            "warning",
        ]

        missing = []
        for prop in required_props:
            if "property" not in content or prop not in content:
                # More specific check
                if not re.search(rf"property\s+\w+\s+{prop}\b", content):
                    missing.append(prop)

        assert not missing, f"Theme.qml missing properties: {missing}"

    def test_button_has_required_properties(self) -> None:
        """Button.qml should have standard button properties."""
        button_file = COMPONENTS_DIR / "Button.qml"
        assert button_file.exists(), "Button.qml not found"

        content = button_file.read_text()

        required_props = ["text", "variant", "enabled", "clicked"]

        missing = []
        for prop in required_props:
            if prop not in content:
                missing.append(prop)

        assert not missing, f"Button.qml missing: {missing}"

    def test_appbar_has_required_properties(self) -> None:
        """AppBar.qml should have standard app bar properties."""
        appbar_file = COMPONENTS_DIR / "AppBar.qml"
        assert appbar_file.exists(), "AppBar.qml not found"

        content = appbar_file.read_text()

        required_props = ["title", "showBack", "backClicked"]

        missing = []
        for prop in required_props:
            if prop not in content:
                missing.append(prop)

        assert not missing, f"AppBar.qml missing: {missing}"

    def test_card_has_required_properties(self) -> None:
        """Card.qml should have standard card properties."""
        card_file = COMPONENTS_DIR / "Card.qml"
        assert card_file.exists(), "Card.qml not found"

        content = card_file.read_text()

        required_props = ["pressable", "clicked"]

        missing = []
        for prop in required_props:
            if prop not in content:
                missing.append(prop)

        assert not missing, f"Card.qml missing: {missing}"

    def test_all_components_exported_in_qmldir(self) -> None:
        """All component QML files should be exported in qmldir."""
        qmldir_file = COMPONENTS_DIR / "qmldir"
        assert qmldir_file.exists(), "components/qmldir not found"

        qmldir_content = qmldir_file.read_text()

        # Get all .qml files in components
        component_files = [f.stem for f in COMPONENTS_DIR.glob("*.qml")]

        missing = []
        for comp in component_files:
            if comp not in qmldir_content:
                missing.append(comp)

        assert not missing, f"Components not in qmldir: {missing}"


class TestAppManifests:
    """Test app QML entry points exist."""

    def test_manifest_qml_entries_exist(self) -> None:
        """All app manifest QML entries should point to existing files."""
        import json

        errors = []

        for app_dir in APPS_DIR.iterdir():
            if not app_dir.is_dir() or app_dir.name in ("core", "ui", "__pycache__"):
                continue

            manifest_file = app_dir / "manifest.json"
            if not manifest_file.exists():
                continue

            manifest = json.loads(manifest_file.read_text())

            # Check QML entry
            entry = manifest.get("entry", {})
            qml_path = entry.get("qml")

            if qml_path:
                full_path = app_dir / qml_path
                if not full_path.exists():
                    errors.append(f"{app_dir.name}: QML entry '{qml_path}' not found")

        assert not errors, "Missing QML entry files:\n" + "\n".join(errors)
