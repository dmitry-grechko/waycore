import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * Modules - External Hardware Module Management
 *
 * Manages external hardware modules connected to the device.
 */
Rectangle {
    id: modules
    color: Core.Theme.background

    // Standard app interface
    property string appId: "com.waycore.modules"
    property string appTitle: "Modules"
    signal closeRequested()

    // Module state (currently empty)
    property var connectedModules: []

    // Tactical grid background
    Core.TacticalBackground {
        anchors.fill: parent
        gridOpacity: 0.15
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header bar
        Core.PageHeader {
            Layout.fillWidth: true
            title: "Modules"
            showBack: true
            onBackClicked: closeRequested()
        }

        // Main content - Empty state
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Column {
                anchors.centerIn: parent
                spacing: Core.Theme.spacingLarge
                width: parent.width - Core.Theme.spacingLarge * 2

                // Icon with animated rings
                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 160
                    height: 160

                    // Outer dashed ring (rotating)
                    Rectangle {
                        anchors.centerIn: parent
                        width: 180
                        height: 180
                        radius: 90
                        color: "transparent"
                        border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.4)
                        border.width: 1

                        RotationAnimation on rotation {
                            from: 0
                            to: 360
                            duration: 12000
                            loops: Animation.Infinite
                            running: true
                        }
                    }

                    // Inner dashed ring (counter-rotating)
                    Rectangle {
                        anchors.centerIn: parent
                        width: 200
                        height: 200
                        radius: 100
                        color: "transparent"
                        border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.2)
                        border.width: 1

                        RotationAnimation on rotation {
                            from: 360
                            to: 0
                            duration: 12000
                            loops: Animation.Infinite
                            running: true
                        }
                    }

                    // Main icon container
                    Rectangle {
                        anchors.centerIn: parent
                        width: 160
                        height: 160
                        radius: 80
                        color: Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.3)
                        border.color: Core.Theme.divider
                        border.width: 2

                        // Gradient overlay
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.05) }
                                GradientStop { position: 1.0; color: "transparent" }
                            }
                        }

                        // Module icon
                        Core.MaterialIcon {
                            anchors.centerIn: parent
                            name: "usb"
                            size: 80
                            iconColor: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.4)
                        }
                    }

                    // Warning badge
                    Rectangle {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: 16
                        anchors.bottomMargin: 16
                        width: 36
                        height: 36
                        radius: 18
                        color: Core.Theme.background
                        border.color: Core.Theme.divider
                        border.width: 1

                        Core.MaterialIcon {
                            anchors.centerIn: parent
                            name: "warning"
                            size: 20
                            iconColor: Core.Theme.warning
                        }
                    }
                }

                // Title
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "NO EXTERNAL MODULES"
                    color: Core.Theme.textPrimary
                    font.pixelSize: Core.Theme.h3Size
                    font.weight: Font.Bold
                    font.letterSpacing: 3
                }

                // Description
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(300, parent.width)
                    height: descriptionText.height + Core.Theme.spacingMedium * 2
                    color: "transparent"

                    Rectangle {
                        anchors.top: parent.top
                        width: parent.width
                        height: 1
                        color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
                    }

                    Text {
                        id: descriptionText
                        anchors.centerIn: parent
                        width: parent.width - Core.Theme.spacingMedium * 2
                        text: "Connect a module to the module hub port"
                        color: Core.Theme.textSecondary
                        font.pixelSize: Core.Theme.bodySmallSize
                        font.family: Core.Theme.fontFamilyMono
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }

                // Spacer
                Item { width: 1; height: Core.Theme.spacingLarge }

                // Future: Scan button (disabled for now)
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(200, parent.width)
                    height: 48
                    radius: Core.Theme.borderRadius
                    color: Core.Theme.surface
                    border.color: Core.Theme.divider
                    border.width: 1
                    opacity: 0.5

                    Row {
                        anchors.centerIn: parent
                        spacing: Core.Theme.spacingSmall

                        Core.MaterialIcon {
                            name: "search"
                            size: 20
                            iconColor: Core.Theme.textSecondary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "SCAN FOR MODULES"
                            color: Core.Theme.textSecondary
                            font.pixelSize: Core.Theme.bodySmallSize
                            font.weight: Font.Bold
                            font.letterSpacing: 1
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }
}
