import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * SettingsInfo - Device and software information
 */
Rectangle {
    id: settingsInfo
    color: Core.Theme.background

    signal backRequested()

    // System info
    property string appVersion: SensorBridge ? SensorBridge.appVersion : "0.1.0-dev"
    property string deviceModel: SensorBridge ? SensorBridge.deviceModel : "Waycore Dev Board"
    property string hostname: SensorBridge ? SensorBridge.hostname : "waycore"
    property bool connected: SensorBridge ? SensorBridge.connected : false

    // Runtime tracking
    property int appUptime: 0
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: appUptime++
    }

    function formatUptime(seconds) {
        var hours = Math.floor(seconds / 3600)
        var mins = Math.floor((seconds % 3600) / 60)
        var secs = seconds % 60
        if (hours > 0) return hours + "h " + mins + "m " + secs + "s"
        if (mins > 0) return mins + "m " + secs + "s"
        return secs + "s"
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.height
        clip: true

        ColumnLayout {
            id: contentColumn
            width: parent.width
            spacing: 0

            // App bar
            Core.AppBar {
                Layout.fillWidth: true
                title: "ℹ️ Info"
                showBack: true
                onBackClicked: settingsInfo.backRequested()
            }

            // Device Card
            Core.Card {
                Layout.fillWidth: true
                Layout.margins: Core.Theme.spacingMedium
                title: "Device"

                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    rowSpacing: Core.Theme.spacingXS
                    columnSpacing: Core.Theme.spacingLarge

                    Text { text: "Model"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                    Text { text: deviceModel; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize; wrapMode: Text.WordWrap; Layout.fillWidth: true }

                    Text { text: "Serial"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                    Text { text: "WC-2024-001234"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize }

                    Text { text: "Hardware Rev"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                    Text { text: "v1.0"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize }

                    Text { text: "Hostname"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                    Text { text: hostname; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize }

                    Text { text: "CPU"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                    Text { text: "ARM Cortex-A76 (4 cores)"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize; wrapMode: Text.WordWrap; Layout.fillWidth: true }

                    Text { text: "RAM"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                    Text { text: "8 GB"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize }
                }
            }

            // Software Card
            Core.Card {
                Layout.fillWidth: true
                Layout.margins: Core.Theme.spacingMedium
                Layout.topMargin: 0
                title: "Software"

                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    rowSpacing: Core.Theme.spacingXS
                    columnSpacing: Core.Theme.spacingLarge

                    Text { text: "App Version"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                    Text { text: appVersion; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize }

                    Text { text: "Build"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                    Text { text: "2024.12.25-abc1234"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize }

                    Text { text: "Python"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                    Text { text: "3.11.0"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize }

                    Text { text: "Qt/QML"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                    Text { text: "6.5.0"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize }

                    Text { text: "OS"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                    Text { text: "Raspberry Pi OS Lite"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                }
            }

            // Network Card
            Core.Card {
                Layout.fillWidth: true
                Layout.margins: Core.Theme.spacingMedium
                Layout.topMargin: 0
                title: "Network"

                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    rowSpacing: Core.Theme.spacingXS
                    columnSpacing: Core.Theme.spacingLarge

                    Text { text: "WiFi IP"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                    Text { text: "192.168.1.42"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize }

                    Text { text: "WiFi MAC"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                    Text { text: "DC:A6:32:XX:XX:XX"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize }

                    Text { text: "LoRA Node"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                    Text { text: "!abc12345"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize }
                }
            }

            // Runtime Card
            Core.Card {
                Layout.fillWidth: true
                Layout.margins: Core.Theme.spacingMedium
                Layout.topMargin: 0
                title: "Runtime"

                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    rowSpacing: Core.Theme.spacingXS
                    columnSpacing: Core.Theme.spacingLarge

                    Text { text: "System Uptime"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                    Text { text: SensorBridge ? formatUptime(SensorBridge.uptimeSeconds) : "Unknown"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize }

                    Text { text: "App Uptime"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                    Text { text: formatUptime(appUptime); color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize }

                    Text { text: "Memory"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                    Text { text: "512 MB / 8 GB (6%)"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize }

                    Text { text: "CPU Temp"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                    Text { text: "45°C"; color: Core.Theme.success; font.pixelSize: Core.Theme.captionSize }

                    Text { text: "Battery"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                    Text {
                        text: (SensorBridge ? SensorBridge.batteryLevel : 85) + "%" + (SensorBridge && SensorBridge.batteryCharging ? " ⚡" : "")
                        color: (SensorBridge ? SensorBridge.batteryLevel : 85) > 20 ? Core.Theme.success : Core.Theme.error
                        font.pixelSize: Core.Theme.captionSize
                    }

                    Text { text: "Backend"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                    Text { text: connected ? "Connected" : "Offline"; color: connected ? Core.Theme.success : Core.Theme.warning; font.pixelSize: Core.Theme.captionSize }
                }
            }

            Item { Layout.preferredHeight: Core.Theme.spacingLarge }
        }
    }
}
