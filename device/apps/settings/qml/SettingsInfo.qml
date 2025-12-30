import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * SettingsInfo - Device information and diagnostics
 *
 * Uses standardized Core components:
 * - TacticalBackground for grid + vignette
 * - PageHeader for navigation
 * - Card for content sections
 * - Theme colors for consistency
 * - MaterialIcon for icons
 * - ProgressBar, Badge
 */
Rectangle {
    id: settingsInfo
    color: Core.Theme.background

    // Navigation signals
    signal backRequested()

    // System info
    property string appVersion: SensorBridge ? SensorBridge.appVersion : "2.4.1"
    property string deviceModel: SensorBridge ? SensorBridge.deviceModel : "Waycore Mk V"
    property string hostname: SensorBridge ? SensorBridge.hostname : "waycore-field-1"
    property bool connected: SensorBridge ? SensorBridge.connected : false
    property int batteryLevel: SensorBridge ? SensorBridge.batteryLevel : 84

    // Runtime tracking
    property int appUptime: 0
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: appUptime++
    }

    function formatUptime(seconds) {
        var days = Math.floor(seconds / 86400)
        var hours = Math.floor((seconds % 86400) / 3600)
        var mins = Math.floor((seconds % 3600) / 60)
        var secs = seconds % 60

        if (days > 0) {
            return days + "d " + hours.toString().padStart(2, '0') + "h " + mins.toString().padStart(2, '0') + "m"
        } else if (hours > 0) {
            return hours.toString().padStart(2, '0') + "h " + mins.toString().padStart(2, '0') + "m " + secs.toString().padStart(2, '0') + "s"
        }
        return mins + "m " + secs + "s"
    }

    // Tactical background using standardized component
    Core.TacticalBackground {
        anchors.fill: parent
        z: 0
        vignetteOpacity: 0.5
    }

    // Scanline effect (retro tactical look)
    Rectangle {
        anchors.fill: parent
        z: 50
        opacity: 0.03
        color: "transparent"

        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.fillStyle = "black"
                for (var y = 0; y < height; y += 4) {
                    ctx.fillRect(0, y + 2, width, 2)
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        z: 10

        // Header using PageHeader
        Core.PageHeader {
            Layout.fillWidth: true
            title: "Device"
            subtitle: "Information"
            showBack: true
            onBackClicked: settingsInfo.backRequested()
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

                // Runtime Section
                Core.Card {
                    Layout.fillWidth: true
                    Layout.leftMargin: Core.Theme.spacingMedium
                    Layout.rightMargin: Core.Theme.spacingMedium

                    // Live indicator
                    Row {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: Core.Theme.spacingMedium
                        spacing: Core.Theme.spacingSmall
                        z: 1

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
                            text: "LIVE"
                            color: Core.Theme.warning
                            font.pixelSize: Core.Theme.tinySize
                            font.family: Core.Theme.fontFamilyMono
                            font.letterSpacing: 1
                        }
                    }

                    ColumnLayout {
                        width: parent.width
                        spacing: Core.Theme.spacingMedium

                        Row {
                            spacing: Core.Theme.spacingSmall
                            Core.MaterialIcon {
                                name: "heart-pulse"
                                size: 16
                                iconColor: Core.Theme.warning
                            }
                            Text {
                                text: "RUNTIME"
                                color: Core.Theme.warning
                                font.pixelSize: Core.Theme.labelSize
                                font.weight: Core.Theme.fontWeightBold
                                font.letterSpacing: Core.Theme.letterSpacingNormal
                            }
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: Core.Theme.spacingMedium
                            rowSpacing: Core.Theme.spacingSmall

                            ColumnLayout {
                                spacing: 4
                                Text {
                                    text: "SYSTEM UPTIME"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.weight: Core.Theme.fontWeightBold
                                    font.letterSpacing: 1
                                }
                                Text {
                                    text: SensorBridge ? formatUptime(SensorBridge.uptimeSeconds) : "4d 02h 14m"
                                    color: Core.Theme.textPrimary
                                    font.pixelSize: Core.Theme.bodySmallSize
                                    font.family: Core.Theme.fontFamilyMono
                                }
                            }

                            ColumnLayout {
                                spacing: 4
                                Text {
                                    text: "APP UPTIME"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.weight: Core.Theme.fontWeightBold
                                    font.letterSpacing: 1
                                }
                                Text {
                                    text: formatUptime(appUptime)
                                    color: Core.Theme.textPrimary
                                    font.pixelSize: Core.Theme.bodySmallSize
                                    font.family: Core.Theme.fontFamilyMono
                                }
                            }
                        }

                        // Memory usage bar
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Core.Theme.spacingSmall

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "MEMORY USAGE"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.weight: Core.Theme.fontWeightBold
                                    font.letterSpacing: 1
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: "4.2GB / 8.0GB"
                                    color: Core.Theme.textPrimary
                                    font.pixelSize: Core.Theme.smallSize
                                    font.family: Core.Theme.fontFamilyMono
                                }
                            }

                            Core.ProgressBar {
                                Layout.fillWidth: true
                                value: 0.52
                            }
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: Core.Theme.spacingMedium
                            rowSpacing: Core.Theme.spacingSmall

                            ColumnLayout {
                                spacing: 4
                                Text {
                                    text: "CPU TEMP"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.weight: Core.Theme.fontWeightBold
                                    font.letterSpacing: 1
                                }
                                Row {
                                    spacing: Core.Theme.spacingSmall
                                    Text {
                                        text: "48°C"
                                        color: Core.Theme.textPrimary
                                        font.pixelSize: Core.Theme.bodySmallSize
                                        font.family: Core.Theme.fontFamilyMono
                                    }
                                    Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 8
                                        height: 8
                                        radius: 4
                                        color: Core.Theme.success
                                    }
                                }
                            }

                            ColumnLayout {
                                spacing: 4
                                Text {
                                    text: "BATTERY"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.weight: Core.Theme.fontWeightBold
                                    font.letterSpacing: 1
                                }
                                Row {
                                    spacing: Core.Theme.spacingSmall
                                    Core.MaterialIcon {
                                        name: "lightning-bolt"
                                        size: 14
                                        iconColor: Core.Theme.warning

                                        SequentialAnimation on opacity {
                                            running: true
                                            loops: Animation.Infinite
                                            NumberAnimation { to: 0.3; duration: 500 }
                                            NumberAnimation { to: 1.0; duration: 500 }
                                        }
                                    }
                                    Text {
                                        text: batteryLevel + "%"
                                        color: Core.Theme.textPrimary
                                        font.pixelSize: Core.Theme.bodySmallSize
                                        font.family: Core.Theme.fontFamilyMono
                                    }
                                }
                            }
                        }

                        Core.Divider { Layout.fillWidth: true }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: "BACKEND CONNECTION"
                                color: Core.Theme.textSecondary
                                font.pixelSize: Core.Theme.tinySize
                                font.weight: Core.Theme.fontWeightBold
                                font.letterSpacing: 1
                            }
                            Row {
                                spacing: Core.Theme.spacingSmall
                                Core.MaterialIcon {
                                    name: "check"
                                    size: 14
                                    iconColor: Core.Theme.success
                                }
                                Text {
                                    text: "wss://api.waycore.net"
                                    color: Core.Theme.textPrimary
                                    font.pixelSize: Core.Theme.bodySmallSize
                                    font.family: Core.Theme.fontFamilyMono
                                }
                            }
                        }
                    }
                }

                // Device Section
                Core.Card {
                    Layout.fillWidth: true
                    Layout.leftMargin: Core.Theme.spacingMedium
                    Layout.rightMargin: Core.Theme.spacingMedium

                    ColumnLayout {
                        width: parent.width
                        spacing: Core.Theme.spacingSmall

                        Row {
                            spacing: Core.Theme.spacingSmall
                            Core.MaterialIcon {
                                name: "chip"
                                size: 16
                                iconColor: Core.Theme.divider
                            }
                            Text {
                                text: "DEVICE"
                                color: Core.Theme.divider
                                font.pixelSize: Core.Theme.labelSize
                                font.weight: Core.Theme.fontWeightBold
                                font.letterSpacing: Core.Theme.letterSpacingNormal
                            }
                        }

                        Core.Divider { Layout.fillWidth: true }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: Core.Theme.spacingSmall
                            rowSpacing: 4

                            ColumnLayout {
                                spacing: 2
                                Text { text: "MODEL"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.tinySize; opacity: 0.7 }
                                Text { text: deviceModel; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.bodySmallSize; font.family: Core.Theme.fontFamilyMono }
                            }

                            ColumnLayout {
                                Layout.alignment: Qt.AlignRight
                                spacing: 2
                                Text { text: "SERIAL"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.tinySize; opacity: 0.7; Layout.alignment: Qt.AlignRight }
                                Text { text: "WC-884-X"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.bodySmallSize; font.family: Core.Theme.fontFamilyMono }
                            }
                        }

                        Core.Divider { Layout.fillWidth: true }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: Core.Theme.spacingSmall
                            rowSpacing: 4

                            ColumnLayout {
                                spacing: 2
                                Text { text: "HARDWARE"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.tinySize; opacity: 0.7 }
                                Text { text: "RPi 5 B+"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.bodySmallSize; font.family: Core.Theme.fontFamilyMono }
                            }

                            ColumnLayout {
                                Layout.alignment: Qt.AlignRight
                                spacing: 2
                                Text { text: "HOSTNAME"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.tinySize; opacity: 0.7; Layout.alignment: Qt.AlignRight }
                                Text { text: hostname; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.bodySmallSize; font.family: Core.Theme.fontFamilyMono }
                            }
                        }

                        Core.Divider { Layout.fillWidth: true }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: Core.Theme.spacingSmall

                            ColumnLayout {
                                spacing: 2
                                Text { text: "CPU"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.tinySize; opacity: 0.7 }
                                Text { text: "Cortex-A76"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.bodySmallSize; font.family: Core.Theme.fontFamilyMono }
                            }

                            ColumnLayout {
                                Layout.alignment: Qt.AlignRight
                                spacing: 2
                                Text { text: "RAM"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.tinySize; opacity: 0.7; Layout.alignment: Qt.AlignRight }
                                Text { text: "8GB LPDDR4X"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.bodySmallSize; font.family: Core.Theme.fontFamilyMono }
                            }
                        }
                    }
                }

                // Software Section
                Core.Card {
                    Layout.fillWidth: true
                    Layout.leftMargin: Core.Theme.spacingMedium
                    Layout.rightMargin: Core.Theme.spacingMedium

                    ColumnLayout {
                        width: parent.width
                        spacing: Core.Theme.spacingSmall

                        Row {
                            spacing: Core.Theme.spacingSmall
                            Core.MaterialIcon {
                                name: "code-tags"
                                size: 16
                                iconColor: Core.Theme.divider
                            }
                            Text {
                                text: "SOFTWARE"
                                color: Core.Theme.divider
                                font.pixelSize: Core.Theme.labelSize
                                font.weight: Core.Theme.fontWeightBold
                                font.letterSpacing: Core.Theme.letterSpacingNormal
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "APP VERSION"
                                color: Core.Theme.textSecondary
                                font.pixelSize: Core.Theme.labelSize
                                font.letterSpacing: 1
                            }
                            Item { Layout.fillWidth: true }
                            Core.Badge {
                                text: "v" + appVersion
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "BUILD ID"
                                color: Core.Theme.textSecondary
                                font.pixelSize: Core.Theme.labelSize
                                font.letterSpacing: 1
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: "20231024-RC"
                                color: Core.Theme.textPrimary
                                font.pixelSize: Core.Theme.bodySmallSize
                                font.family: Core.Theme.fontFamilyMono
                            }
                        }

                        Core.Divider { Layout.fillWidth: true }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 3
                            columnSpacing: Core.Theme.spacingSmall
                            rowSpacing: 4

                            Repeater {
                                model: [
                                    { label: "PYTHON", value: "3.11.2" },
                                    { label: "QT/QML", value: "6.5.0" },
                                    { label: "OS", value: "WayOS 12" }
                                ]

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 48
                                    color: Qt.rgba(Core.Theme.background.r, Core.Theme.background.g, Core.Theme.background.b, 0.3)
                                    border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.1)
                                    border.width: 1
                                    radius: Core.Theme.borderRadius

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: Core.Theme.spacingSmall
                                        spacing: 4

                                        Text {
                                            text: modelData.label
                                            color: Core.Theme.textSecondary
                                            font.pixelSize: Core.Theme.tinySize
                                        }
                                        Text {
                                            text: modelData.value
                                            color: Core.Theme.textPrimary
                                            font.pixelSize: Core.Theme.smallSize
                                            font.family: Core.Theme.fontFamilyMono
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Network Section
                Core.Card {
                    Layout.fillWidth: true
                    Layout.leftMargin: Core.Theme.spacingMedium
                    Layout.rightMargin: Core.Theme.spacingMedium

                    ColumnLayout {
                        width: parent.width
                        spacing: Core.Theme.spacingMedium

                        Row {
                            spacing: Core.Theme.spacingSmall
                            Core.MaterialIcon {
                                name: "access-point"
                                size: 16
                                iconColor: Core.Theme.divider
                            }
                            Text {
                                text: "NETWORK"
                                color: Core.Theme.divider
                                font.pixelSize: Core.Theme.labelSize
                                font.weight: Core.Theme.fontWeightBold
                                font.letterSpacing: Core.Theme.letterSpacingNormal
                            }
                        }

                        // WiFi
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Core.Theme.spacingSmall

                            Rectangle {
                                width: 40
                                height: 40
                                radius: Core.Theme.borderRadius
                                color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.1)
                                border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.2)
                                border.width: 1

                                Core.MaterialIcon {
                                    anchors.centerIn: parent
                                    name: "wifi"
                                    size: 18
                                    iconColor: Core.Theme.textSecondary
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: "WLAN0 (INTERNAL)"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.weight: Core.Theme.fontWeightBold
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: "192.168.1.42"
                                        color: Core.Theme.textPrimary
                                        font.pixelSize: Core.Theme.bodySmallSize
                                        font.family: Core.Theme.fontFamilyMono
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: "AA:BB:CC:DD:EE:FF"
                                        color: Core.Theme.textSecondary
                                        font.pixelSize: Core.Theme.tinySize
                                        font.family: Core.Theme.fontFamilyMono
                                        opacity: 0.5
                                    }
                                }
                            }
                        }

                        // LoRa
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Core.Theme.spacingSmall

                            Rectangle {
                                width: 40
                                height: 40
                                radius: Core.Theme.borderRadius
                                color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.1)
                                border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.2)
                                border.width: 1

                                Core.MaterialIcon {
                                    anchors.centerIn: parent
                                    name: "access-point"
                                    size: 18
                                    iconColor: Core.Theme.textSecondary
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: "LORA MESH"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.weight: Core.Theme.fontWeightBold
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: "NODE-04"
                                        color: Core.Theme.textPrimary
                                        font.pixelSize: Core.Theme.bodySmallSize
                                        font.family: Core.Theme.fontFamilyMono
                                    }
                                    Item { Layout.fillWidth: true }
                                    Core.Badge {
                                        text: "Active"
                                        variant: "warning"
                                    }
                                }
                            }
                        }
                    }
                }

                // Bottom spacer
                Item { Layout.preferredHeight: 120 }
            }
        }
    }
}
