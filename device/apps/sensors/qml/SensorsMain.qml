import QtQuick 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * Modules - Hardware modules and sensor monitoring
 *
 * Shows connected hardware modules and their status.
 */
Rectangle {
    id: modulesScreen
    color: Core.Theme.background

    // Standard app interface
    property string appId: "com.waycore.modules"
    property string appTitle: "Modules"
    signal closeRequested()

    // Get sensor data from SensorBridge
    property int batteryLevel: (SensorBridge && typeof SensorBridge.batteryLevel !== "undefined") ? SensorBridge.batteryLevel : 85
    property bool batteryCharging: (SensorBridge && typeof SensorBridge.batteryCharging !== "undefined") ? SensorBridge.batteryCharging : false
    property real temperature: (SensorBridge && typeof SensorBridge.temperatureCelsius !== "undefined") ? SensorBridge.temperatureCelsius : 22.5
    property bool hasGpsFix: (SensorBridge && typeof SensorBridge.hasGpsFix !== "undefined") ? SensorBridge.hasGpsFix : false
    property int gpsSatellites: (SensorBridge && typeof SensorBridge.gpsSatellites !== "undefined") ? SensorBridge.gpsSatellites : 0
    property bool backendConnected: (SensorBridge && typeof SensorBridge.connected !== "undefined") ? SensorBridge.connected : false

    Core.AppBar {
        id: appBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        title: "Modules"
        showBack: true
        onBackClicked: modulesScreen.closeRequested()
    }

    Flickable {
        anchors.top: appBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Core.Theme.spacingMedium
        contentHeight: contentColumn.height
        clip: true

        Column {
            id: contentColumn
            width: parent.width
            spacing: Core.Theme.spacingMedium

            // Connection Status
            Core.Card {
                width: parent.width

                RowLayout {
                    width: parent.width
                    height: 48
                    spacing: Core.Theme.spacingMedium

                    Text {
                        text: "🔗"
                        font.pixelSize: 24
                    }

                    Column {
                        Layout.fillWidth: true

                        Text {
                            text: "Backend Connection"
                            color: Core.Theme.textPrimary
                            font.pixelSize: Core.Theme.bodySize
                            font.weight: Font.Medium
                        }

                        Text {
                            text: backendConnected ? "Connected" : "Offline"
                            color: backendConnected ? Core.Theme.success : Core.Theme.textSecondary
                            font.pixelSize: Core.Theme.captionSize
                        }
                    }

                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: backendConnected ? Core.Theme.success : Core.Theme.error
                    }
                }
            }

            // Section Header
            Text {
                text: "HARDWARE MODULES"
                color: Core.Theme.textSecondary
                font.pixelSize: Core.Theme.labelSize
                font.weight: Font.Bold
                font.letterSpacing: 1
                topPadding: Core.Theme.spacingMedium
            }

            // Battery Module
            Core.Card {
                width: parent.width

                RowLayout {
                    width: parent.width
                    height: 56
                    spacing: Core.Theme.spacingMedium

                    Text {
                        text: batteryCharging ? "🔌" : (batteryLevel > 20 ? "🔋" : "🪫")
                        font.pixelSize: 28
                    }

                    Column {
                        Layout.fillWidth: true

                        Text {
                            text: "Battery"
                            color: Core.Theme.textPrimary
                            font.pixelSize: Core.Theme.bodySize
                            font.weight: Font.Medium
                        }

                        Text {
                            text: batteryLevel + "%" + (batteryCharging ? " • Charging" : "")
                            color: batteryLevel < 20 ? Core.Theme.error : Core.Theme.textSecondary
                            font.pixelSize: Core.Theme.captionSize
                        }
                    }

                    Core.ProgressBar {
                        Layout.preferredWidth: 60
                        value: batteryLevel / 100
                        variant: batteryLevel < 20 ? "error" : "default"
                    }
                }
            }

            // Temperature Module
            Core.Card {
                width: parent.width

                RowLayout {
                    width: parent.width
                    height: 56
                    spacing: Core.Theme.spacingMedium

                    Text {
                        text: "🌡️"
                        font.pixelSize: 28
                    }

                    Column {
                        Layout.fillWidth: true

                        Text {
                            text: "Temperature Sensor"
                            color: Core.Theme.textPrimary
                            font.pixelSize: Core.Theme.bodySize
                            font.weight: Font.Medium
                        }

                        Text {
                            text: temperature.toFixed(1) + "°C"
                            color: temperature > 35 ? Core.Theme.error : (temperature > 28 ? Core.Theme.warning : Core.Theme.textSecondary)
                            font.pixelSize: Core.Theme.captionSize
                        }
                    }

                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: Core.Theme.success
                    }
                }
            }

            // GPS Module
            Core.Card {
                width: parent.width

                RowLayout {
                    width: parent.width
                    height: 56
                    spacing: Core.Theme.spacingMedium

                    Text {
                        text: "🛰"
                        font.pixelSize: 28
                    }

                    Column {
                        Layout.fillWidth: true

                        Text {
                            text: "GPS Module"
                            color: Core.Theme.textPrimary
                            font.pixelSize: Core.Theme.bodySize
                            font.weight: Font.Medium
                        }

                        Text {
                            text: hasGpsFix ? gpsSatellites + " satellites" : "Searching..."
                            color: hasGpsFix ? Core.Theme.success : Core.Theme.textSecondary
                            font.pixelSize: Core.Theme.captionSize
                        }
                    }

                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: hasGpsFix ? Core.Theme.success : Core.Theme.warning
                    }
                }
            }

            // Mesh Radio Module
            Core.Card {
                width: parent.width

                property bool meshConnected: (MeshBridge && typeof MeshBridge.isConnected !== "undefined") ? MeshBridge.isConnected : false

                RowLayout {
                    width: parent.width
                    height: 56
                    spacing: Core.Theme.spacingMedium

                    Text {
                        text: "📻"
                        font.pixelSize: 28
                    }

                    Column {
                        Layout.fillWidth: true

                        Text {
                            text: "Mesh Radio"
                            color: Core.Theme.textPrimary
                            font.pixelSize: Core.Theme.bodySize
                            font.weight: Font.Medium
                        }

                        Text {
                            text: parent.parent.parent.meshConnected ? "Connected" : "Offline"
                            color: parent.parent.parent.meshConnected ? Core.Theme.success : Core.Theme.textSecondary
                            font.pixelSize: Core.Theme.captionSize
                        }
                    }

                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: parent.parent.meshConnected ? Core.Theme.success : Core.Theme.error
                    }
                }
            }

            // Camera Module
            Core.Card {
                width: parent.width

                RowLayout {
                    width: parent.width
                    height: 56
                    spacing: Core.Theme.spacingMedium

                    Text {
                        text: "📷"
                        font.pixelSize: 28
                    }

                    Column {
                        Layout.fillWidth: true

                        Text {
                            text: "Camera"
                            color: Core.Theme.textPrimary
                            font.pixelSize: Core.Theme.bodySize
                            font.weight: Font.Medium
                        }

                        Text {
                            text: "Available"
                            color: Core.Theme.success
                            font.pixelSize: Core.Theme.captionSize
                        }
                    }

                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: Core.Theme.success
                    }
                }
            }
        }
    }
}
