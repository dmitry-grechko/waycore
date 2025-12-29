import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "." as Core

/**
 * StatusBar - Information-dense status bar for field use
 *
 * Features:
 * - Battery level with percentage
 * - 24h time format
 * - Temperature (from sensors)
 * - Connectivity indicators (LTE, WiFi, GPS, Mesh)
 * - Long-press for detailed status popup
 */
Rectangle {
    id: statusBar
    height: Core.Theme.statusBarHeight
    color: "#000000"  // Pure black for OLED power savings

    // Properties from SensorBridge or mocked defaults
    property int batteryLevel: (SensorBridge && typeof SensorBridge.batteryLevel !== "undefined") ? SensorBridge.batteryLevel : 85
    property bool isCharging: (SensorBridge && typeof SensorBridge.isCharging !== "undefined") ? SensorBridge.isCharging : false
    property var temperature: getTemperatureValue()
    property bool hasLTE: false  // Future implementation
    property bool hasWiFi: (SensorBridge && typeof SensorBridge.connected !== "undefined") ? SensorBridge.connected : true
    property bool hasGPS: (SensorBridge && typeof SensorBridge.hasGpsFix !== "undefined") ? SensorBridge.hasGpsFix : false
    property int gpsSatellites: (SensorBridge && typeof SensorBridge.gpsSatellites !== "undefined") ? SensorBridge.gpsSatellites : 0
    property bool hasMesh: (MeshBridge && typeof MeshBridge.isConnected !== "undefined") ? MeshBridge.isConnected : false

    function getTemperatureValue() {
        if (SensorBridge && typeof SensorBridge.temperatureCelsius !== "undefined" && SensorBridge.temperatureCelsius !== null) {
            return SensorBridge.temperatureCelsius
        }
        // Return mock value for testing when backend not available
        return 22
    }

    // Current time/date
    property string currentTime: Qt.formatTime(new Date(), "HH:mm")
    property string currentDate: Qt.formatDate(new Date(), "ddd, MMM d")

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Core.Theme.spacingMedium
        anchors.rightMargin: Core.Theme.spacingMedium
        spacing: Core.Theme.spacingMedium

        // Left section: Battery
        Row {
            spacing: 4
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: getBatteryIcon(batteryLevel, isCharging)
                font.pixelSize: 18
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: batteryLevel + "%"
                color: batteryLevel < 20 ? Core.Theme.error : Core.Theme.textPrimary
                font.pixelSize: Core.Theme.bodySize
                font.weight: Font.Medium
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Time
        Text {
            id: timeText
            text: currentTime
            color: Core.Theme.textPrimary
            font.pixelSize: 18
            font.weight: Font.Bold
            Layout.alignment: Qt.AlignVCenter
        }

        // Temperature
        Row {
            spacing: 4
            visible: temperature !== null && typeof temperature !== "undefined"
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: "🌡️"
                font.pixelSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: (temperature !== null && typeof temperature !== "undefined") ? (temperature + "°C") : ""
                color: getTemperatureColor(temperature)
                font.pixelSize: Core.Theme.bodySize
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Item { Layout.fillWidth: true }  // Spacer

        // Right section: Connectivity indicators
        Row {
            spacing: 12
            Layout.alignment: Qt.AlignVCenter

            Core.StatusIndicator {
                icon: "📶"
                active: hasLTE
                tooltip: "Cellular"
            }

            Core.StatusIndicator {
                icon: hasWiFi ? "📡" : "📡"
                active: hasWiFi
                tooltip: hasWiFi ? "Connected" : "Offline"
            }

            Core.StatusIndicator {
                icon: "🛰"
                active: hasGPS
                tooltip: hasGPS ? gpsSatellites + " satellites" : "No GPS fix"
            }

            Core.StatusIndicator {
                icon: "📻"
                active: hasMesh
                tooltip: hasMesh ? "Mesh connected" : "Mesh offline"
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
                font.letterSpacing: 1
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
                font.letterSpacing: 1
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
        if (charging) return "🔌"
        if (level > 80) return "🔋"
        if (level > 50) return "🔋"
        if (level > 20) return "🪫"
        return "🪫"
    }

    function getTemperatureColor(temp) {
        if (temp === null || typeof temp === "undefined") return Core.Theme.textSecondary
        if (temp < 0) return Core.Theme.info
        if (temp > 35) return Core.Theme.error
        if (temp > 28) return Core.Theme.warning
        return Core.Theme.textPrimary
    }
}
