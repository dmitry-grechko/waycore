import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "." as Core
import "./components" as Components

/**
 * StatusBar - Tactical HUD-style status bar
 *
 * Features:
 * - 24h time display (prominent)
 * - Battery level with icon
 * - Signal strength in dBm
 * - GPS coordinates in military format
 * - Status indicator dots (pulsing)
 * - Long-press for detailed status popup
 */
Rectangle {
    id: statusBar
    height: Core.Theme.statusBarHeight
    color: Qt.rgba(Core.Theme.background.r, Core.Theme.background.g, Core.Theme.background.b, 0.95)

    // Properties from SensorBridge or mocked defaults
    property int batteryLevel: (SensorBridge && typeof SensorBridge.batteryLevel !== "undefined") ? SensorBridge.batteryLevel : 84
    property bool isCharging: (SensorBridge && typeof SensorBridge.isCharging !== "undefined") ? SensorBridge.isCharging : false
    property var temperature: getTemperatureValue()
    property bool hasLTE: false
    property bool hasWiFi: (SensorBridge && typeof SensorBridge.connected !== "undefined") ? SensorBridge.connected : true
    property bool hasGPS: (SensorBridge && typeof SensorBridge.hasGpsFix !== "undefined") ? SensorBridge.hasGpsFix : true
    property int gpsSatellites: (SensorBridge && typeof SensorBridge.gpsSatellites !== "undefined") ? SensorBridge.gpsSatellites : 6
    property bool hasMesh: (MeshBridge && typeof MeshBridge.isConnected !== "undefined") ? MeshBridge.isConnected : false
    property int signalStrength: -85  // dBm

    // GPS coordinates (mock for now)
    property real gpsLatitude: 34.05
    property real gpsLongitude: -118.24
    property int gpsAltitude: 420

    function getTemperatureValue() {
        if (SensorBridge && typeof SensorBridge.temperatureCelsius !== "undefined" && SensorBridge.temperatureCelsius !== null) {
            return SensorBridge.temperatureCelsius
        }
        return 22
    }

    // Current time/date
    property string currentTime: Qt.formatTime(new Date(), "HH:mm")
    property string currentDate: Qt.formatDate(new Date(), "ddd, MMM d")

    // Format GPS coordinates
    function formatGPS() {
        var latDir = gpsLatitude >= 0 ? "N" : "S"
        var lonDir = gpsLongitude >= 0 ? "E" : "W"
        return "GPS: " + Math.abs(gpsLatitude).toFixed(2) + latDir + ", " + Math.abs(gpsLongitude).toFixed(2) + lonDir + " (" + gpsAltitude + "m)"
    }

    // Border at bottom
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Core.Theme.divider
    }

    Column {
        anchors.fill: parent
        anchors.leftMargin: Core.Theme.spacingMedium
        anchors.rightMargin: Core.Theme.spacingMedium
        anchors.topMargin: Core.Theme.spacingMedium
        anchors.bottomMargin: Core.Theme.spacingSmall
        spacing: 4

        // Top row: Time | Battery & Signal
        RowLayout {
            width: parent.width
            spacing: Core.Theme.spacingMedium

            // Time (left side, prominent)
            Row {
                spacing: 6
                Layout.alignment: Qt.AlignVCenter

                Components.MaterialIcon {
                    name: "schedule"
                    size: 14
                    iconColor: Core.Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: currentTime
                    color: Core.Theme.textPrimary
                    font.pixelSize: 21
                    font.weight: Font.Bold
                    font.letterSpacing: Core.Theme.letterSpacingWide
                    font.family: Core.Theme.fontFamily
                }
            }

            Item { Layout.fillWidth: true }

            // Battery & Signal (right side)
            Row {
                spacing: Core.Theme.spacingMedium
                Layout.alignment: Qt.AlignVCenter

                // Battery
                Row {
                    spacing: 4

                    Components.MaterialIcon {
                        name: "battery_5_bar"
                        size: 14
                        iconColor: Core.Theme.textSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: batteryLevel + "%"
                        color: Core.Theme.textSecondary
                        font.pixelSize: Core.Theme.bodySmallSize
                        font.weight: Font.Bold
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Signal strength
                Row {
                    spacing: 4

                    Components.MaterialIcon {
                        name: "signal_cellular_alt"
                        size: 14
                        iconColor: Core.Theme.textSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: signalStrength + "dBm"
                        color: Core.Theme.textSecondary
                        font.pixelSize: Core.Theme.bodySmallSize
                        font.weight: Font.Bold
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // Bottom row: GPS coordinates | Status dots
        RowLayout {
            width: parent.width
            spacing: Core.Theme.spacingSmall

            // GPS coordinates (left, monospace style)
            Text {
                text: formatGPS()
                color: Core.Theme.textSecondary
                font.pixelSize: Core.Theme.tinySize
                font.family: Core.Theme.fontFamilyMono
                font.letterSpacing: Core.Theme.letterSpacingMono
                textFormat: Text.PlainText
            }

            Item { Layout.fillWidth: true }

            // Status indicator dots (right)
            Row {
                spacing: 4

                // Active status dot (pulsing)
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: Core.Theme.primary

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: true
                        NumberAnimation { to: 0.4; duration: 500 }
                        NumberAnimation { to: 1.0; duration: 500 }
                    }
                }

                // Secondary status dot
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: Core.Theme.divider
                }
            }
        }
    }

    // Long-press for detailed status popup
    MouseArea {
        anchors.fill: parent
        onPressAndHold: statusPopup.open()
    }

    // Timer for clock updates
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date()
            currentTime = Qt.formatTime(now, "HH:mm")
            currentDate = Qt.formatDate(now, "ddd, MMM d")
        }
    }

    // Status Popup (detailed view)
    Popup {
        id: statusPopup
        parent: Overlay.overlay
        x: (parent.width - width) / 2
        y: statusBar.height + Core.Theme.spacingSmall
        width: parent.width - Core.Theme.spacingLarge * 2
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
            Text {
                text: "DEVICE STATUS"
                color: Core.Theme.textSecondary
                font.pixelSize: Core.Theme.labelSize
                font.weight: Font.Bold
                font.letterSpacing: Core.Theme.letterSpacingNormal
            }

            // Battery details
            StatusRow {
                label: "Battery"
                value: batteryLevel + "%" + (isCharging ? " (Charging)" : "")
                valueColor: batteryLevel < 20 ? Core.Theme.error : Core.Theme.textPrimary
            }

            // Temperature
            StatusRow {
                label: "Temperature"
                value: temperature !== null ? temperature + "°C" : "N/A"
                valueColor: getTemperatureColor(temperature)
            }

            // Date
            StatusRow {
                label: "Date"
                value: currentDate
            }

            Rectangle {
                width: parent.width - Core.Theme.spacingMedium * 2
                height: 1
                color: Core.Theme.divider
            }

            // Connectivity section
            Text {
                text: "CONNECTIVITY"
                color: Core.Theme.textSecondary
                font.pixelSize: Core.Theme.labelSize
                font.weight: Font.Bold
                font.letterSpacing: Core.Theme.letterSpacingNormal
            }

            StatusRow {
                label: "WiFi/Backend"
                value: hasWiFi ? "Connected" : "Offline"
                valueColor: hasWiFi ? Core.Theme.success : Core.Theme.textSecondary
            }

            StatusRow {
                label: "GPS"
                value: hasGPS ? "Fix (" + gpsSatellites + " sats)" : "No fix"
                valueColor: hasGPS ? Core.Theme.success : Core.Theme.textSecondary
            }

            StatusRow {
                label: "Mesh Radio"
                value: hasMesh ? "Connected" : "Offline"
                valueColor: hasMesh ? Core.Theme.success : Core.Theme.textSecondary
            }

            StatusRow {
                label: "Cellular"
                value: hasLTE ? "Connected" : "Not available"
                valueColor: hasLTE ? Core.Theme.success : Core.Theme.textSecondary
            }
        }

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150 }
        }

        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 100 }
        }
    }

    // Helper component for status rows
    component StatusRow: RowLayout {
        property string label: ""
        property string value: ""
        property color valueColor: Core.Theme.textPrimary

        width: parent.width - Core.Theme.spacingMedium * 2

        Text {
            text: label
            color: Core.Theme.textSecondary
            font.pixelSize: Core.Theme.bodySize
            Layout.fillWidth: true
        }

        Text {
            text: value
            color: valueColor
            font.pixelSize: Core.Theme.bodySize
            font.weight: Font.Medium
        }
    }

    // Helper functions
    function getBatteryIcon(level, charging) {
        if (charging) return "battery_charging_full"
        if (level > 80) return "battery_5_bar"
        if (level > 60) return "battery_4_bar"
        if (level > 40) return "battery_3_bar"
        if (level > 20) return "battery_2_bar"
        return "battery_1_bar"
    }

    function getTemperatureColor(temp) {
        if (temp === null || typeof temp === "undefined") return Core.Theme.textSecondary
        if (temp < 0) return Core.Theme.info
        if (temp > 35) return Core.Theme.error
        if (temp > 28) return Core.Theme.warning
        return Core.Theme.textPrimary
    }
}
