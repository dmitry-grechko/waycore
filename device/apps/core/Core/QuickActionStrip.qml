import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "." as Core
import "./components" as Components

/**
 * QuickActionStrip - Tactical quick action dock at bottom
 *
 * Three quick action buttons with tactical styling:
 * - LIGHT (flashlight toggle)
 * - LOCK (screen lock)
 * - POWER (power menu)
 */
Rectangle {
    id: quickStrip
    height: Core.Theme.quickActionHeight
    color: Core.Theme.background

    // Signals for shell integration
    signal navigateToApp(string appId)
    signal lockScreen()

    // State
    property bool flashlightOn: false

    // Top border
    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: 1
        color: Core.Theme.divider
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Core.Theme.spacingMedium
        spacing: Core.Theme.spacingSmall

        // LIGHT button (primary, turns bronze when active)
        TacticalQuickButton {
            Layout.fillWidth: true
            Layout.fillHeight: true
            iconName: flashlightOn ? "lightbulb-on" : "lightbulb"
            label: "LIGHT"
            variant: "primary"
            active: flashlightOn

            onClicked: toggleFlashlight()
        }

        // LOCK button (primary)
        TacticalQuickButton {
            Layout.fillWidth: true
            Layout.fillHeight: true
            iconName: "lock"
            label: "LOCK"
            variant: "primary"

            onClicked: quickStrip.lockScreen()
        }

        // POWER button (warning)
        TacticalQuickButton {
            Layout.fillWidth: true
            Layout.fillHeight: true
            iconName: "power"
            label: "POWER"
            variant: "warning"

            onClicked: powerMenu.open()
        }
    }

    // Flashlight toggle
    function toggleFlashlight() {
        flashlightOn = !flashlightOn
        console.log("Flashlight:", flashlightOn ? "ON" : "OFF")
    }

    // Tactical Quick Button component
    component TacticalQuickButton: Rectangle {
        id: btn

        property string iconName: ""
        property string label: ""
        property string variant: "primary"  // primary | warning
        property bool active: false

        signal clicked()

        radius: Core.Theme.borderRadius

        // Colors based on variant and active state
        color: {
            if (variant === "warning") {
                return mouseArea.pressed
                    ? Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.4)
                    : Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.2)
            }
            // Active state - use warning/bronze color
            if (active) {
                return mouseArea.pressed
                    ? Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.4)
                    : Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.25)
            }
            // Default primary variant
            return mouseArea.pressed
                ? Qt.darker(Core.Theme.primary, 1.2)
                : Core.Theme.primary
        }

        // Border color - warning/bronze when active
        border.color: {
            if (variant === "warning" || active) {
                return Core.Theme.warning
            }
            return Core.Theme.divider
        }
        border.width: active ? 2 : 1

        Column {
            anchors.centerIn: parent
            spacing: 4

            Components.MaterialIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                name: btn.iconName
                size: 24
                // Use warning color when active or warning variant
                iconColor: (variant === "warning" || btn.active) ? Core.Theme.warning : Core.Theme.textPrimary

                Behavior on iconColor {
                    ColorAnimation { duration: Core.Theme.animationFast }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: btn.label
                // Use warning color when active or warning variant
                color: (variant === "warning" || btn.active) ? Core.Theme.warning : Core.Theme.textPrimary
                font.pixelSize: Core.Theme.tinySize
                font.weight: Font.Bold
                font.letterSpacing: Core.Theme.letterSpacingNormal

                Behavior on color {
                    ColorAnimation { duration: Core.Theme.animationFast }
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: btn.clicked()
        }

        // Press animation
        scale: mouseArea.pressed ? 0.98 : 1.0
        Behavior on scale {
            NumberAnimation { duration: Core.Theme.animationFast }
        }

        Behavior on color {
            ColorAnimation { duration: Core.Theme.animationFast }
        }

        Behavior on border.color {
            ColorAnimation { duration: Core.Theme.animationFast }
        }
    }

    // Power Menu Popup
    Popup {
        id: powerMenu
        parent: Overlay.overlay
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 280
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: Core.Theme.surface
            radius: Core.Theme.borderRadiusLarge
            border.color: Core.Theme.divider
        }

        contentItem: Column {
            spacing: Core.Theme.spacingSmall
            padding: Core.Theme.spacingMedium

            Text {
                text: "POWER OPTIONS"
                color: Core.Theme.textSecondary
                font.pixelSize: Core.Theme.labelSize
                font.weight: Font.Bold
                font.letterSpacing: Core.Theme.letterSpacingNormal
            }

            Item { height: Core.Theme.spacingSmall }

            PowerMenuItem {
                iconName: "sleep"
                label: "Sleep Mode"
                sublabel: "Turn off display, keep radios"
                onClicked: {
                    powerMenu.close()
                    console.log("Sleep mode activated")
                }
            }

            PowerMenuItem {
                iconName: "restart"
                label: "Restart"
                sublabel: "Restart device"
                onClicked: {
                    confirmDialog.action = "restart"
                    confirmDialog.open()
                }
            }

            Rectangle {
                width: parent.width - Core.Theme.spacingMedium * 2
                height: 1
                color: Core.Theme.divider
            }

            PowerMenuItem {
                iconName: "power"
                label: "Shutdown"
                sublabel: "Power off completely"
                dangerous: true
                onClicked: {
                    confirmDialog.action = "shutdown"
                    confirmDialog.open()
                }
            }
        }
    }

    // Confirmation Dialog
    Popup {
        id: confirmDialog
        parent: Overlay.overlay
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 280
        modal: true

        property string action: ""

        background: Rectangle {
            color: Core.Theme.surface
            radius: Core.Theme.borderRadiusLarge
            border.color: Core.Theme.divider
        }

        contentItem: Column {
            spacing: Core.Theme.spacingMedium
            padding: Core.Theme.spacingMedium

            Text {
                text: confirmDialog.action === "restart" ? "Restart Device?" : "Shutdown Device?"
                color: Core.Theme.textPrimary
                font.pixelSize: Core.Theme.h3Size
                font.weight: Font.Bold
            }

            Text {
                text: confirmDialog.action === "restart" ?
                    "The device will restart. This may take a few moments." :
                    "The device will power off completely."
                color: Core.Theme.textSecondary
                font.pixelSize: Core.Theme.bodySize
                wrapMode: Text.WordWrap
                width: parent.width - Core.Theme.spacingMedium * 2
            }

            RowLayout {
                width: parent.width - Core.Theme.spacingMedium * 2
                spacing: Core.Theme.spacingSmall

                Core.Button {
                    text: "Cancel"
                    variant: "secondary"
                    Layout.fillWidth: true
                    onClicked: confirmDialog.close()
                }

                Core.Button {
                    text: confirmDialog.action === "restart" ? "Restart" : "Shutdown"
                    variant: "danger"
                    Layout.fillWidth: true
                    onClicked: {
                        console.log("Confirmed:", confirmDialog.action)
                        confirmDialog.close()
                        powerMenu.close()
                        // TODO: Actually perform restart/shutdown via bridge
                    }
                }
            }
        }
    }

    // PowerMenuItem helper component
    component PowerMenuItem: Rectangle {
        width: parent.width - Core.Theme.spacingMedium * 2
        height: 56
        color: mouseArea.containsMouse ? Core.Theme.surfaceElevated : "transparent"
        radius: Core.Theme.borderRadius

        property string iconName: ""
        property string label: ""
        property string sublabel: ""
        property bool dangerous: false

        signal clicked()

        RowLayout {
            anchors.fill: parent
            anchors.margins: Core.Theme.spacingSmall
            spacing: Core.Theme.spacingSmall

            Components.MaterialIcon {
                name: iconName
                size: 24
                iconColor: dangerous ? Core.Theme.error : Core.Theme.textPrimary
                Layout.alignment: Qt.AlignVCenter
            }

            Column {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                Text {
                    text: label
                    color: dangerous ? Core.Theme.error : Core.Theme.textPrimary
                    font.pixelSize: Core.Theme.bodySize
                }
                Text {
                    text: sublabel
                    color: Core.Theme.textSecondary
                    font.pixelSize: Core.Theme.captionSize
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: parent.clicked()
        }
    }
}
