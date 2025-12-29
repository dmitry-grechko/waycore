import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "." as Core

/**
 * QuickActionStrip - Bottom action bar for quick access to critical functions
 *
 * Always accessible at the bottom of the screen for:
 * - Flashlight toggle
 * - Quick communications
 * - Screen lock
 * - Power options
 */
Rectangle {
    id: quickStrip
    height: Core.Theme.quickActionHeight
    color: Core.Theme.surface

    // Signals for shell integration
    signal navigateToApp(string appId)
    signal lockScreen()

    // State
    property bool flashlightOn: false
    property int unreadMessages: (MeshBridge && MeshBridge.unreadCount) ? MeshBridge.unreadCount : 0

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
        spacing: Core.Theme.spacingMedium

        // Flashlight
        Core.QuickAction {
            icon: flashlightOn ? "🔦" : "🔦"
            label: "FLASH"
            active: flashlightOn
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height - Core.Theme.spacingMedium * 2

            onClicked: toggleFlashlight()
        }

        // Communications
        Core.QuickAction {
            icon: "📡"
            label: "COMMS"
            badge: unreadMessages
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height - Core.Theme.spacingMedium * 2

            onClicked: quickCommsPopup.open()
        }

        // Lock
        Core.QuickAction {
            icon: "🔒"
            label: "LOCK"
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height - Core.Theme.spacingMedium * 2

            onClicked: quickStrip.lockScreen()
        }

        // Power
        Core.QuickAction {
            icon: "⚡"
            label: "POWER"
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height - Core.Theme.spacingMedium * 2

            onClicked: powerMenu.open()
        }
    }

    // Flashlight toggle
    function toggleFlashlight() {
        flashlightOn = !flashlightOn
        // TODO: Implement actual flashlight control via hardware bridge
        console.log("Flashlight:", flashlightOn ? "ON" : "OFF")
    }

    // Quick Comms Popup
    Popup {
        id: quickCommsPopup
        parent: Overlay.overlay
        x: (parent.width - width) / 2
        y: parent.height - quickStrip.height - height - Core.Theme.spacingMedium
        width: parent.width - Core.Theme.spacingLarge * 2
        height: 300
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: Core.Theme.surface
            radius: Core.Theme.borderRadiusLarge
            border.color: Core.Theme.divider
        }

        contentItem: Column {
            spacing: Core.Theme.spacingMedium
            padding: Core.Theme.spacingMedium

            // Header
            RowLayout {
                width: parent.width - Core.Theme.spacingMedium * 2

                Text {
                    text: "QUICK COMMS"
                    color: Core.Theme.textSecondary
                    font.pixelSize: Core.Theme.labelSize
                    font.weight: Font.Bold
                    font.letterSpacing: 1
                    Layout.fillWidth: true
                }

                Text {
                    text: "✕"
                    color: Core.Theme.textSecondary
                    font.pixelSize: 18

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8
                        onClicked: quickCommsPopup.close()
                    }
                }
            }

            Rectangle {
                width: parent.width - Core.Theme.spacingMedium * 2
                height: 1
                color: Core.Theme.divider
            }

            // Recent messages (placeholder)
            Text {
                visible: !MeshBridge || unreadMessages === 0
                text: "No recent messages"
                color: Core.Theme.textSecondary
                font.pixelSize: Core.Theme.bodySize
            }

            ListView {
                visible: MeshBridge && unreadMessages > 0
                width: parent.width - Core.Theme.spacingMedium * 2
                height: 150
                clip: true
                model: MeshBridge ? MeshBridge.recentMessages : []

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 48
                    color: "transparent"

                    Column {
                        anchors.fill: parent
                        anchors.margins: 4

                        Text {
                            text: modelData.from || "Unknown"
                            color: Core.Theme.textSecondary
                            font.pixelSize: Core.Theme.captionSize
                        }
                        Text {
                            text: modelData.text || ""
                            color: Core.Theme.textPrimary
                            font.pixelSize: Core.Theme.bodySize
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }
                }
            }

            Item { height: Core.Theme.spacingSmall }

            // Open full Meshtastic button
            Core.Button {
                text: "Open Meshtastic"
                fullWidth: true
                variant: "primary"

                onClicked: {
                    quickCommsPopup.close()
                    quickStrip.navigateToApp("com.waycore.meshtastic")
                }
            }
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
                font.letterSpacing: 1
            }

            Item { height: Core.Theme.spacingSmall }

            PowerMenuItem {
                icon: "🔋"
                label: "Battery Saver"
                sublabel: "Reduce background activity"
                toggle: true
                checked: powerMenu.batterySaverEnabled
                onClicked: powerMenu.batterySaverEnabled = !powerMenu.batterySaverEnabled
            }

            PowerMenuItem {
                icon: "🌙"
                label: "Sleep Mode"
                sublabel: "Turn off display, keep radios"
                onClicked: {
                    powerMenu.close()
                    console.log("Sleep mode activated")
                }
            }

            Rectangle {
                width: parent.width - Core.Theme.spacingMedium * 2
                height: 1
                color: Core.Theme.divider
            }

            PowerMenuItem {
                icon: "🔄"
                label: "Restart"
                sublabel: "Restart device"
                onClicked: {
                    confirmDialog.action = "restart"
                    confirmDialog.open()
                }
            }

            PowerMenuItem {
                icon: "⏹️"
                label: "Shutdown"
                sublabel: "Power off completely"
                dangerous: true
                onClicked: {
                    confirmDialog.action = "shutdown"
                    confirmDialog.open()
                }
            }
        }

        property bool batterySaverEnabled: false
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

        property string icon: ""
        property string label: ""
        property string sublabel: ""
        property bool toggle: false
        property bool checked: false
        property bool dangerous: false

        signal clicked()

        RowLayout {
            anchors.fill: parent
            anchors.margins: Core.Theme.spacingSmall
            spacing: Core.Theme.spacingSmall

            Text {
                text: icon
                font.pixelSize: 24
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

            Switch {
                visible: toggle
                checked: parent.parent.checked
                Layout.alignment: Qt.AlignVCenter
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
