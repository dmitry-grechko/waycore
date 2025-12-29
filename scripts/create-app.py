#!/usr/bin/env python3
"""
Create a new Waycore app from template.

Usage:
    python scripts/create-app.py my-app-name
    python scripts/create-app.py my-app-name --backend

Examples:
    python scripts/create-app.py weather-tracker
    python scripts/create-app.py fitness-tracker --backend
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def create_app(name: str, with_backend: bool = False) -> bool:
    """
    Create a new app directory with template files.

    Args:
        name: App name (lowercase, hyphens allowed)
        with_backend: Include Python backend module

    Returns:
        True if successful
    """
    # Validate name
    if not name.replace("-", "").replace("_", "").isalnum():
        print(f"Error: Invalid app name '{name}'")
        print("Use lowercase letters, numbers, and hyphens only")
        return False

    # Convert name to ID format
    app_id = f"com.waycore.{name.replace('-', '').replace('_', '')}"
    display_name = name.replace("-", " ").replace("_", " ").title()[:12]

    # Determine app directory
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    app_dir = project_root / "device" / "apps" / name

    if app_dir.exists():
        print(f"Error: {app_dir} already exists")
        return False

    print(f"Creating app: {name}")
    print(f"  ID: {app_id}")
    print(f"  Name: {display_name}")

    # Create directory structure
    app_dir.mkdir(parents=True)
    (app_dir / "qml").mkdir()

    if with_backend:
        (app_dir / "backend").mkdir()
        print("  Backend: enabled")

    # Create manifest.json
    manifest = {
        "id": app_id,
        "name": display_name,
        "version": "1.0.0",
        "description": "A Waycore app",
        "icon": "📱",
        "category": "utilities",
        "entry": {
            "qml": "qml/Main.qml",
        },
        "tier": 2,
        "enabled": True,
    }

    if with_backend:
        manifest["entry"]["backend"] = "backend/service.py"

    with open(app_dir / "manifest.json", "w") as f:
        json.dump(manifest, f, indent=2)

    # Create main QML file
    qml_content = f"""import QtQuick 2.15
import QtQuick.Layouts 1.15
import Core as Core

Rectangle {{
    id: root
    color: Core.Theme.background

    signal closeRequested()

    property string appId: "{app_id}"
    property string appTitle: "{display_name}"

    Core.AppBar {{
        id: appBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        title: root.appTitle
        showBack: true
        onBackClicked: root.closeRequested()
    }}

    ColumnLayout {{
        anchors.top: appBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Core.Theme.spacingMedium

        Item {{ Layout.fillHeight: true }}

        Text {{
            text: "Hello from " + root.appTitle + "!"
            color: Core.Theme.textPrimary
            font.pixelSize: Core.Theme.h2Size
            Layout.alignment: Qt.AlignHCenter
        }}

        Text {{
            text: "Edit qml/Main.qml to customize this app"
            color: Core.Theme.textSecondary
            font.pixelSize: Core.Theme.bodySize
            Layout.alignment: Qt.AlignHCenter
        }}

        Item {{ Layout.fillHeight: true }}
    }}
}}
"""

    with open(app_dir / "qml" / "Main.qml", "w") as f:
        f.write(qml_content)

    # Create backend if requested
    if with_backend:
        backend_init = '"""Backend module for {name}."""\n'
        with open(app_dir / "backend" / "__init__.py", "w") as f:
            f.write(backend_init.format(name=display_name))

        backend_content = f'''"""Backend service for {display_name}."""

from __future__ import annotations

from PySide6.QtCore import QObject, Signal, Slot


class AppBackend(QObject):
    """Backend service for {display_name}."""

    # Signals for QML
    dataChanged = Signal()

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)

    @Slot(result=str)
    def hello(self) -> str:
        """Example slot callable from QML."""
        return "Hello from backend!"

    @Slot(str, result=str)
    def processData(self, input_data: str) -> str:
        """Process data and return result."""
        return input_data.upper()


def create_bridge() -> QObject:
    """Factory function called by the app loader."""
    return AppBackend()
'''

        with open(app_dir / "backend" / "service.py", "w") as f:
            f.write(backend_content)

    # Create README.md
    readme_content = f"""# {display_name}

A Waycore app.

## Development

1. Edit `qml/Main.qml` for the UI
{"2. Edit `backend/service.py` for backend logic" if with_backend else ""}

## Structure

```
{name}/
├── manifest.json
├── qml/
│   └── Main.qml
{"├── backend/\n│   ├── __init__.py\n│   └── service.py" if with_backend else ""}
└── README.md
```

## Testing

Run the UI app and navigate to your app from the System Hub:

```bash
cd device/apps/ui && python main.py
```
"""

    with open(app_dir / "README.md", "w") as f:
        f.write(readme_content)

    print(f"\n✅ Created app: {app_dir}")
    print("\nNext steps:")
    print(f"  1. Edit {app_dir}/qml/Main.qml")
    if with_backend:
        print(f"  2. Edit {app_dir}/backend/service.py")
    print("  3. Run the UI to test your app")

    return True


def main() -> int:
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Create a new Waycore app",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python scripts/create-app.py weather-tracker
  python scripts/create-app.py fitness-tracker --backend
        """,
    )
    parser.add_argument(
        "name",
        help="App name (lowercase, hyphens allowed)",
    )
    parser.add_argument(
        "--backend",
        action="store_true",
        help="Include Python backend module",
    )

    args = parser.parse_args()

    success = create_app(args.name, args.backend)
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
