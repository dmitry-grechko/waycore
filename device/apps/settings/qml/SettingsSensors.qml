import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * SettingsSensors - Sensor status and calibration
 */
Rectangle {
    id: settingsSensors
    color: Core.Theme.background

    signal backRequested()

    // Sensors from registry
    property var sensorsList: SensorBridge ? SensorBridge.sensors : []

    // Refresh timer
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            if (SensorBridge) SensorBridge.refreshSensors()
        }
    }

    Component.onCompleted: {
        if (SensorBridge) SensorBridge.refreshSensors()
    }

    function getSensorIcon(sensorType) {
        switch(sensorType) {
            case "gps": return "📍"
            case "temperature": return "🌡️"
            case "pressure": return "🌀"
            case "accelerometer": return "📐"
            case "magnetometer": return "🧭"
            case "light": return "☀️"
            case "humidity": return "💧"
            case "battery": return "🔋"
            default: return "📟"
        }
    }

    function getStatusColor(status) {
        switch(status) {
            case "online": return Core.Theme.success
            case "offline": return Core.Theme.error
            case "error": return Core.Theme.error
            case "calibrating": return Core.Theme.warning
            default: return Core.Theme.textSecondary
        }
    }

    function formatSensorValue(sensor) {
        if (!sensor.last_value) return "No data"
        var val = sensor.last_value
        switch(sensor.type) {
            case "gps":
                if (!val.has_fix) return "No fix"
                return "Lat: " + val.latitude.toFixed(4) + "°, Lon: " + val.longitude.toFixed(4) + "°"
            case "temperature":
                return val.celsius.toFixed(1) + "°C / " + val.fahrenheit.toFixed(1) + "°F"
            case "magnetometer":
                return val.heading.toFixed(0) + "° " + val.cardinal + (val.calibrated ? " ✓" : " ⚠")
            case "battery":
                return val.level + "%" + (val.charging ? " ⚡" : "")
            default:
                return JSON.stringify(val).substring(0, 40)
        }
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
                title: "🌡️ Sensors"
                showBack: true
                onBackClicked: settingsSensors.backRequested()

                rightContent: Core.IconButton {
                    icon: "🔄"
                    onClicked: {
                        if (SensorBridge) SensorBridge.discoverSensors()
                    }
                }
            }

            // Status bar
            Core.Card {
                Layout.fillWidth: true
                Layout.margins: Core.Theme.spacingMedium

                RowLayout {
                    anchors.fill: parent

                    Text {
                        text: SensorBridge && SensorBridge.connected ? "🟢 Live data" : "🟡 Mock data"
                        color: Core.Theme.textSecondary
                        font.pixelSize: Core.Theme.captionSize
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: sensorsList.length + " sensors"
                        color: Core.Theme.textSecondary
                        font.pixelSize: Core.Theme.captionSize
                    }
                }
            }

            // Sensor list
            Repeater {
                model: sensorsList

                Core.Card {
                    Layout.fillWidth: true
                    Layout.margins: Core.Theme.spacingMedium
                    Layout.topMargin: 0

                    ColumnLayout {
                        width: parent.width
                        spacing: Core.Theme.spacingSmall

                        RowLayout {
                            Layout.fillWidth: true

                            Text { text: getSensorIcon(modelData.type); font.pixelSize: 24 }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text { text: modelData.name; color: Core.Theme.textPrimary; font.weight: Core.Theme.fontWeightBold }
                                Text { text: modelData.status; color: getStatusColor(modelData.status); font.pixelSize: Core.Theme.captionSize }
                            }

                            Core.Badge {
                                dot: true
                                variant: modelData.status === "online" ? "success" : "error"
                            }
                        }

                        Text {
                            text: formatSensorValue(modelData)
                            color: Core.Theme.textPrimary
                            font.pixelSize: Core.Theme.captionSize
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "Driver: " + modelData.driver
                            color: Core.Theme.textSecondary
                            font.pixelSize: Core.Theme.smallSize
                            visible: modelData.driver !== undefined
                        }

                        Core.Button {
                            text: "Calibrate"
                            size: "small"
                            variant: "secondary"
                            visible: modelData.type === "magnetometer" && modelData.last_value && !modelData.last_value.calibrated
                            onClicked: {
                                if (SensorBridge) SensorBridge.calibrateCompass()
                            }
                        }
                    }
                }
            }

            // Empty state
            Core.EmptyState {
                Layout.fillWidth: true
                Layout.margins: Core.Theme.spacingMedium
                visible: sensorsList.length === 0
                icon: "📟"
                title: "No Sensors"
                description: "Tap 🔄 to run discovery"
            }

            Item { Layout.preferredHeight: Core.Theme.spacingLarge }
        }
    }
}
