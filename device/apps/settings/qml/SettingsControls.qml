import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * SettingsControls - Connectivity settings
 *
 * Uses standardized Core components:
 * - TacticalBackground for grid + vignette
 * - PageHeader for navigation
 * - Card for content sections
 * - Theme colors for consistency
 * - MaterialIcon for icons
 * - Switch for toggles
 */
Rectangle {
    id: settingsControls
    color: Core.Theme.background

    // Navigation signals
    signal backRequested()

    // Radio states
    property bool loraEnabled: true
    property bool wifiEnabled: true
    property bool bluetoothEnabled: true
    property bool lteEnabled: false

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
            title: "Controls"
            subtitle: "Connectivity"
            showBack: true
            onBackClicked: settingsControls.backRequested()
        }

        // Scrollable content
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: contentColumn.height + 32
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: contentColumn
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Core.Theme.spacingMedium

                Item { Layout.preferredHeight: Core.Theme.spacingSmall }

                // LoRA Mesh Card
                Core.Card {
                    Layout.fillWidth: true
                    Layout.leftMargin: Core.Theme.spacingMedium
                    Layout.rightMargin: Core.Theme.spacingMedium

                    ColumnLayout {
                        width: parent.width
                        spacing: 0

                        // Header row
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Core.Theme.spacingSmall

                            // Icon
                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                radius: Core.Theme.borderRadius
                                color: Qt.rgba(Core.Theme.surfaceHighlight.r, Core.Theme.surfaceHighlight.g, Core.Theme.surfaceHighlight.b, 0.3)

                                Core.MaterialIcon {
                                    anchors.centerIn: parent
                                    name: "access-point"
                                    size: 20
                                    iconColor: Core.Theme.warning
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: "LORA MESH"
                                    color: Core.Theme.textPrimary
                                    font.pixelSize: Core.Theme.bodySmallSize
                                    font.weight: Core.Theme.fontWeightBold
                                    font.letterSpacing: Core.Theme.letterSpacingNormal
                                }
                                Text {
                                    text: loraEnabled ? "ACTIVE" : "DISABLED"
                                    color: loraEnabled ? Core.Theme.warning : Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.labelSize
                                    font.family: Core.Theme.fontFamilyMono
                                    font.weight: Core.Theme.fontWeightBold
                                    font.letterSpacing: Core.Theme.letterSpacingNormal
                                }
                            }

                            Core.Switch {
                                checked: loraEnabled
                                onToggled: loraEnabled = checked
                            }
                        }

                        // Details (visible when enabled)
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.topMargin: Core.Theme.spacingMedium
                            visible: loraEnabled
                            spacing: Core.Theme.spacingMedium

                            Core.Divider { Layout.fillWidth: true }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                rowSpacing: Core.Theme.spacingMedium
                                columnSpacing: Core.Theme.spacingSmall

                                ColumnLayout {
                                    spacing: 4
                                    Text {
                                        text: "CHANNEL"
                                        color: Core.Theme.textSecondary
                                        font.pixelSize: Core.Theme.tinySize
                                        font.letterSpacing: Core.Theme.letterSpacingNormal
                                        opacity: 0.7
                                    }
                                    Text {
                                        text: "LongFast"
                                        color: Core.Theme.textPrimary
                                        font.pixelSize: Core.Theme.bodySmallSize
                                        font.family: Core.Theme.fontFamilyMono
                                    }
                                }

                                ColumnLayout {
                                    spacing: 4
                                    Text {
                                        text: "REGION"
                                        color: Core.Theme.textSecondary
                                        font.pixelSize: Core.Theme.tinySize
                                        font.letterSpacing: Core.Theme.letterSpacingNormal
                                        opacity: 0.7
                                    }
                                    Text {
                                        text: "US-915"
                                        color: Core.Theme.textPrimary
                                        font.pixelSize: Core.Theme.bodySmallSize
                                        font.family: Core.Theme.fontFamilyMono
                                    }
                                }

                                ColumnLayout {
                                    Layout.columnSpan: 2
                                    spacing: 4
                                    Text {
                                        text: "NODE ID"
                                        color: Core.Theme.textSecondary
                                        font.pixelSize: Core.Theme.tinySize
                                        font.letterSpacing: Core.Theme.letterSpacingNormal
                                        opacity: 0.7
                                    }
                                    Text {
                                        text: "!2c88:f009:a221"
                                        color: Core.Theme.textPrimary
                                        font.pixelSize: Core.Theme.bodySmallSize
                                        font.family: Core.Theme.fontFamilyMono
                                    }
                                }
                            }

                            Core.Divider { Layout.fillWidth: true }

                            RowLayout {
                                Layout.fillWidth: true

                                Row {
                                    spacing: Core.Theme.spacingSmall

                                    Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 8
                                        height: 8
                                        radius: 4
                                        color: Core.Theme.warning

                                        SequentialAnimation on opacity {
                                            loops: Animation.Infinite
                                            NumberAnimation { to: 0.3; duration: 1000 }
                                            NumberAnimation { to: 1.0; duration: 1000 }
                                        }
                                    }

                                    Text {
                                        text: "4 PEERS ONLINE"
                                        color: Core.Theme.textSecondary
                                        font.pixelSize: Core.Theme.labelSize
                                        font.family: Core.Theme.fontFamilyMono
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: "98% LQ"
                                    color: Core.Theme.warning
                                    font.pixelSize: Core.Theme.smallSize
                                    font.family: Core.Theme.fontFamilyMono
                                }
                            }
                        }
                    }
                }

                // WiFi Card
                Core.Card {
                    Layout.fillWidth: true
                    Layout.leftMargin: Core.Theme.spacingMedium
                    Layout.rightMargin: Core.Theme.spacingMedium

                    ColumnLayout {
                        width: parent.width
                        spacing: 0

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Core.Theme.spacingSmall

                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                radius: Core.Theme.borderRadius
                                color: Qt.rgba(Core.Theme.surfaceHighlight.r, Core.Theme.surfaceHighlight.g, Core.Theme.surfaceHighlight.b, 0.3)

                                Core.MaterialIcon {
                                    anchors.centerIn: parent
                                    name: "wifi"
                                    size: 20
                                    iconColor: Core.Theme.warning
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: "WIFI"
                                    color: Core.Theme.textPrimary
                                    font.pixelSize: Core.Theme.bodySmallSize
                                    font.weight: Core.Theme.fontWeightBold
                                    font.letterSpacing: Core.Theme.letterSpacingNormal
                                }
                                Text {
                                    text: wifiEnabled ? "CONNECTED" : "DISABLED"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.labelSize
                                    font.family: Core.Theme.fontFamilyMono
                                    font.weight: Core.Theme.fontWeightBold
                                    font.letterSpacing: Core.Theme.letterSpacingNormal
                                }
                            }

                            Core.Switch {
                                checked: wifiEnabled
                                onToggled: wifiEnabled = checked
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.topMargin: Core.Theme.spacingMedium
                            visible: wifiEnabled
                            spacing: Core.Theme.spacingSmall

                            Core.Divider { Layout.fillWidth: true }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                Layout.topMargin: Core.Theme.spacingSmall
                                color: Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.3)
                                border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
                                border.width: 1
                                radius: Core.Theme.borderRadius

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: Core.Theme.spacingSmall

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        Text {
                                            text: "WAYCORE_Secure_01"
                                            color: Core.Theme.warning
                                            font.pixelSize: Core.Theme.bodySmallSize
                                            font.family: Core.Theme.fontFamilyMono
                                            font.weight: Core.Theme.fontWeightBold
                                        }
                                        Text {
                                            text: "192.168.10.45"
                                            color: Core.Theme.textSecondary
                                            font.pixelSize: Core.Theme.tinySize
                                            font.family: Core.Theme.fontFamilyMono
                                        }
                                    }

                                    Core.MaterialIcon {
                                        name: "lock"
                                        size: 14
                                        iconColor: Core.Theme.textSecondary
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "SIGNAL STRENGTH"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.family: Core.Theme.fontFamilyMono
                                    font.letterSpacing: Core.Theme.letterSpacingNormal
                                    opacity: 0.7
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: "-62 dBm"
                                    color: Core.Theme.textPrimary
                                    font.pixelSize: Core.Theme.smallSize
                                    font.family: Core.Theme.fontFamilyMono
                                }
                            }
                        }
                    }
                }

                // Bluetooth Card
                Core.Card {
                    Layout.fillWidth: true
                    Layout.leftMargin: Core.Theme.spacingMedium
                    Layout.rightMargin: Core.Theme.spacingMedium

                    ColumnLayout {
                        width: parent.width
                        spacing: 0

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Core.Theme.spacingSmall

                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                radius: Core.Theme.borderRadius
                                color: Qt.rgba(Core.Theme.surfaceHighlight.r, Core.Theme.surfaceHighlight.g, Core.Theme.surfaceHighlight.b, 0.3)

                                Core.MaterialIcon {
                                    anchors.centerIn: parent
                                    name: "bluetooth"
                                    size: 20
                                    iconColor: Core.Theme.warning
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: "BLUETOOTH"
                                    color: Core.Theme.textPrimary
                                    font.pixelSize: Core.Theme.bodySmallSize
                                    font.weight: Core.Theme.fontWeightBold
                                    font.letterSpacing: Core.Theme.letterSpacingNormal
                                }
                                Text {
                                    text: bluetoothEnabled ? "ON" : "OFF"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.labelSize
                                    font.family: Core.Theme.fontFamilyMono
                                    font.weight: Core.Theme.fontWeightBold
                                    font.letterSpacing: Core.Theme.letterSpacingNormal
                                }
                            }

                            Core.Switch {
                                checked: bluetoothEnabled
                                onToggled: bluetoothEnabled = checked
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.topMargin: Core.Theme.spacingMedium
                            visible: bluetoothEnabled
                            spacing: Core.Theme.spacingSmall

                            Core.Divider { Layout.fillWidth: true }

                            Text {
                                text: "PAIRED DEVICES"
                                color: Core.Theme.textSecondary
                                font.pixelSize: Core.Theme.tinySize
                                font.weight: Core.Theme.fontWeightBold
                                font.letterSpacing: Core.Theme.letterSpacingNormal
                                opacity: 0.7
                            }

                            // Device 1
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                color: Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.2)
                                border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
                                border.width: 1
                                radius: Core.Theme.borderRadius

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: Core.Theme.spacingSmall

                                    Core.MaterialIcon {
                                        name: "headphones"
                                        size: 18
                                        iconColor: Core.Theme.textSecondary
                                    }
                                    Text {
                                        text: "Tactical_Headset_X"
                                        color: Core.Theme.textPrimary
                                        font.pixelSize: Core.Theme.bodySmallSize
                                        font.family: Core.Theme.fontFamilyMono
                                        Layout.fillWidth: true
                                    }
                                    Core.Badge {
                                        text: "Connected"
                                        variant: "warning"
                                    }
                                }
                            }

                            // Device 2
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                color: Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.2)
                                border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
                                border.width: 1
                                radius: Core.Theme.borderRadius

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: Core.Theme.spacingSmall

                                    Core.MaterialIcon {
                                        name: "watch"
                                        size: 18
                                        iconColor: Core.Theme.textSecondary
                                    }
                                    Text {
                                        text: "Garmin_Instinct"
                                        color: Core.Theme.textPrimary
                                        font.pixelSize: Core.Theme.bodySmallSize
                                        font.family: Core.Theme.fontFamilyMono
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: "OFFLINE"
                                        color: Core.Theme.textSecondary
                                        font.pixelSize: Core.Theme.tinySize
                                        font.family: Core.Theme.fontFamilyMono
                                        opacity: 0.5
                                    }
                                }
                            }

                            // Scan button
                            Core.Button {
                                Layout.fillWidth: true
                                Layout.topMargin: Core.Theme.spacingSmall
                                text: "Scan for Devices"
                                iconName: "access-point"
                                variant: "tacticalSecondary"
                                onClicked: console.log("Scanning for Bluetooth devices...")
                            }
                        }
                    }
                }

                // LTE Card (Disabled state)
                Core.Card {
                    Layout.fillWidth: true
                    Layout.leftMargin: Core.Theme.spacingMedium
                    Layout.rightMargin: Core.Theme.spacingMedium
                    opacity: 0.8

                    RowLayout {
                        width: parent.width
                        spacing: Core.Theme.spacingSmall

                        Rectangle {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            radius: Core.Theme.borderRadius
                            color: Qt.rgba(Core.Theme.surfaceHighlight.r, Core.Theme.surfaceHighlight.g, Core.Theme.surfaceHighlight.b, 0.2)

                            Core.MaterialIcon {
                                anchors.centerIn: parent
                                name: "cellphone"
                                size: 20
                                iconColor: Core.Theme.textSecondary
                                opacity: 0.5
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: "LTE / CELLULAR"
                                color: Core.Theme.textSecondary
                                font.pixelSize: Core.Theme.bodySmallSize
                                font.weight: Core.Theme.fontWeightBold
                                font.letterSpacing: Core.Theme.letterSpacingNormal
                            }
                            Text {
                                text: "DISABLED"
                                color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.5)
                                font.pixelSize: Core.Theme.labelSize
                                font.family: Core.Theme.fontFamilyMono
                                font.weight: Core.Theme.fontWeightBold
                                font.letterSpacing: Core.Theme.letterSpacingNormal
                            }
                        }

                        Core.Switch {
                            checked: lteEnabled
                            onToggled: lteEnabled = checked
                        }
                    }
                }

                // Bottom spacer
                Item { Layout.preferredHeight: 120 }
            }
        }
    }
}
