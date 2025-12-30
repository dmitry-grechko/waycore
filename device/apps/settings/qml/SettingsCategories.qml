import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * SettingsCategories - Main settings hub with category tiles
 *
 * Uses standardized Core components:
 * - TacticalBackground for grid + vignette
 * - PageHeader for navigation
 * - Theme colors for consistency
 * - MaterialIcon for icons
 */
Rectangle {
    id: settingsCategories
    color: Core.Theme.background

    // Navigation signals
    signal backRequested()
    signal categorySelected(string category)

    // Settings categories model
    ListModel {
        id: categoriesModel
        ListElement {
            name: "General"
            iconName: "tune"
            description: "System configuration, display & power preferences."
            category: "general"
        }
        ListElement {
            name: "Controls"
            iconName: "gamepad"
            description: "Input mapping, sensitivity settings & macros."
            category: "controls"
        }
        ListElement {
            name: "Sensors"
            iconName: "access-point"
            description: "GPS, Compass calibration & environment data."
            category: "sensors"
        }
        ListElement {
            name: "Info"
            iconName: "console"
            description: "Device logs, version info, manuals & diagnostics."
            category: "info"
        }
    }

    // Tactical background using standardized component
    Core.TacticalBackground {
        anchors.fill: parent
        z: 0
        vignetteOpacity: 0.5
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        z: 10

        // Header using PageHeader
        Core.PageHeader {
            Layout.fillWidth: true
            title: "Settings"
            showBack: true
            onBackClicked: settingsCategories.backRequested()
        }

        // Categories Grid
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Core.Theme.spacingLarge

            GridLayout {
                anchors.fill: parent
                anchors.bottomMargin: 80
                columns: 2
                rowSpacing: Core.Theme.spacingMedium
                columnSpacing: Core.Theme.spacingMedium

                Repeater {
                    model: categoriesModel

                    // Category tile using styled Rectangle for better layout control
                    Rectangle {
                        id: categoryTile
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: tileArea.pressed ? Core.Theme.surfaceHighlight : Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.2)
                        border.color: tileArea.containsMouse ? Core.Theme.warning : Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
                        border.width: 1
                        radius: Core.Theme.borderRadius

                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Core.Theme.spacingMedium
                            spacing: Core.Theme.spacingSmall

                            // Icon container
                            Rectangle {
                                Layout.preferredWidth: 56
                                Layout.preferredHeight: 56
                                color: tileArea.containsMouse ? Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.2) : Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.3)
                                border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.1)
                                border.width: 1
                                radius: Core.Theme.borderRadius

                                Behavior on color { ColorAnimation { duration: 150 } }

                                Core.MaterialIcon {
                                    anchors.centerIn: parent
                                    name: model.iconName
                                    size: 28
                                    iconColor: Core.Theme.warning
                                }
                            }

                            Item { Layout.fillHeight: true }

                            // Title
                            Text {
                                text: model.name.toUpperCase()
                                color: tileArea.containsMouse ? Core.Theme.warning : Core.Theme.textPrimary
                                font.pixelSize: Core.Theme.bodySize
                                font.weight: Core.Theme.fontWeightBold
                                font.letterSpacing: Core.Theme.letterSpacingNormal

                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            // Description
                            Text {
                                Layout.fillWidth: true
                                text: model.description
                                color: Core.Theme.textSecondary
                                font.pixelSize: Core.Theme.labelSize
                                font.family: Core.Theme.fontFamilyMono
                                wrapMode: Text.WordWrap
                                opacity: 0.8
                                lineHeight: 1.3
                            }
                        }

                        // Arrow indicator on hover
                        Core.MaterialIcon {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: Core.Theme.spacingSmall
                            name: "arrow-top-right"
                            size: 14
                            iconColor: Core.Theme.warning
                            opacity: tileArea.containsMouse ? 1.0 : 0.0

                            Behavior on opacity {
                                NumberAnimation { duration: 150 }
                            }
                        }

                        MouseArea {
                            id: tileArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: settingsCategories.categorySelected(model.category)
                        }
                    }
                }
            }
        }

        // Bottom status bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: Qt.rgba(Core.Theme.background.r, Core.Theme.background.g, Core.Theme.background.b, 0.95)
            z: 20

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Core.Theme.spacingLarge
                anchors.rightMargin: Core.Theme.spacingLarge

                // Connection status
                Row {
                    spacing: Core.Theme.spacingSmall

                    // Animated pulse indicator
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 8
                        height: 8
                        radius: 4
                        color: SensorBridge && SensorBridge.connected ? Core.Theme.success : Core.Theme.textSecondary

                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.4; duration: 1000 }
                            NumberAnimation { to: 1.0; duration: 1000 }
                        }
                    }

                    Text {
                        text: SensorBridge && SensorBridge.connected ? "BACKEND CONNECTED" : "OFFLINE MODE"
                        color: Core.Theme.textPrimary
                        font.pixelSize: Core.Theme.tinySize
                        font.weight: Core.Theme.fontWeightBold
                        font.family: Core.Theme.fontFamilyMono
                        font.letterSpacing: Core.Theme.letterSpacingNormal
                    }
                }

                Item { Layout.fillWidth: true }

                // Version
                Text {
                    text: "V" + (SensorBridge ? SensorBridge.appVersion : "2.4.0") + "-REL"
                    color: Core.Theme.textSecondary
                    font.pixelSize: Core.Theme.tinySize
                    font.weight: Core.Theme.fontWeightBold
                    font.family: Core.Theme.fontFamilyMono
                    font.letterSpacing: Core.Theme.letterSpacingNormal
                }
            }
        }
    }
}
