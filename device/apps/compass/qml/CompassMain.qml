import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * CompassMain - Navigation compass with magnetic heading
 *
 * Features:
 * - Rotating compass rose with cardinal directions
 * - Live heading display in degrees
 * - GPS coordinates (when available)
 * - Elevation display (when available)
 * - Calibration status and trigger
 */
Rectangle {
    id: root
    color: Core.Theme.background

    // Standard app interface
    signal closeRequested()
    property string appId: "com.waycore.compass"
    property string appTitle: "Compass"

    // Compass data from SensorBridge
    property real heading: SensorBridge ? SensorBridge.compassHeading : 0
    property string cardinal: SensorBridge ? SensorBridge.compassCardinal : "N"
    property bool calibrated: SensorBridge ? SensorBridge.compassCalibrated : false
    property bool connected: SensorBridge ? SensorBridge.connected : false

    // GPS data (optional)
    property bool hasGps: SensorBridge ? SensorBridge.hasGpsFix : false
    property real latitude: SensorBridge ? SensorBridge.gpsLatitude : 0
    property real longitude: SensorBridge ? SensorBridge.gpsLongitude : 0
    property real gpsAccuracy: SensorBridge ? SensorBridge.gpsAccuracy : 0

    // Elevation data (optional)
    property bool hasElevation: SensorBridge ? SensorBridge.hasElevation : false
    property real elevation: SensorBridge ? SensorBridge.elevationMeters : 0

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Core.Theme.spacingMedium
        spacing: Core.Theme.spacingSmall

        // App bar header
        Core.AppBar {
            Layout.fillWidth: true
            title: root.appTitle
            showBack: true
            onBackClicked: root.closeRequested()

            rightContent: Row {
                spacing: Core.Theme.spacingSmall

                Core.Badge {
                    anchors.verticalCenter: parent.verticalCenter
                    text: connected ? "LIVE" : "MOCK"
                    variant: connected ? "success" : "warning"
                }
            }
        }

        // Main compass display - takes remaining space
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Compass rose
            Rectangle {
                id: compassRose
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height - 20)
                height: width
                radius: width / 2
                color: Core.Theme.surface
                border.color: Core.Theme.divider
                border.width: 2

                // Cardinal directions (rotates with heading)
                Item {
                    anchors.fill: parent
                    rotation: -heading

                    Behavior on rotation {
                        NumberAnimation {
                            duration: Core.Theme.animationNormal
                            easing.type: Easing.OutQuad
                        }
                    }

                    // North marker (highlighted in red/accent)
                    Text {
                        text: "N"
                        color: Core.Theme.error
                        font.pixelSize: 24
                        font.weight: Core.Theme.fontWeightBold
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 14
                    }

                    // South
                    Text {
                        text: "S"
                        color: Core.Theme.textSecondary
                        font.pixelSize: 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 14
                    }

                    // East
                    Text {
                        text: "E"
                        color: Core.Theme.textSecondary
                        font.pixelSize: 20
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                    }

                    // West
                    Text {
                        text: "W"
                        color: Core.Theme.textSecondary
                        font.pixelSize: 20
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                    }

                    // Degree marks (every 10 degrees)
                    Repeater {
                        model: 36
                        Rectangle {
                            width: index % 9 === 0 ? 3 : 1
                            height: index % 9 === 0 ? 15 : 8
                            color: Core.Theme.textSecondary
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 4
                            transformOrigin: Item.Bottom
                            transform: Rotation {
                                origin.x: width / 2
                                origin.y: compassRose.height / 2 - 4
                                angle: index * 10
                            }
                        }
                    }
                }

                // Fixed needle indicator (pointing up - shows current direction)
                Rectangle {
                    width: 4
                    height: compassRose.height / 2 - 60
                    color: Core.Theme.primary
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 40
                    radius: 2
                }

                // Center circle with heading display
                Rectangle {
                    width: 100
                    height: 100
                    radius: 50
                    color: Core.Theme.surfaceElevated
                    border.color: Core.Theme.primary
                    border.width: 2
                    anchors.centerIn: parent

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            text: heading.toFixed(0) + "°"
                            color: Core.Theme.textPrimary
                            font.pixelSize: Core.Theme.h1Size
                            font.weight: Core.Theme.fontWeightBold
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: cardinal
                            color: Core.Theme.textSecondary
                            font.pixelSize: Core.Theme.bodySize
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }

        // GPS & Elevation info card
        Core.Card {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            visible: hasGps || hasElevation

            RowLayout {
                anchors.fill: parent
                spacing: Core.Theme.spacingLarge

                // GPS coordinates
                Column {
                    visible: hasGps
                    spacing: 2
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: "📍 " + latitude.toFixed(4) + "°, " + longitude.toFixed(4) + "°"
                        color: Core.Theme.textPrimary
                        font.pixelSize: Core.Theme.bodySize
                    }
                    Text {
                        text: "Accuracy: ±" + gpsAccuracy.toFixed(0) + "m"
                        color: Core.Theme.textSecondary
                        font.pixelSize: Core.Theme.captionSize
                    }
                }

                Item { Layout.fillWidth: true }

                // Elevation
                Column {
                    visible: hasElevation
                    spacing: 2
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                    Text {
                        text: "⛰️ " + elevation.toFixed(0) + " m"
                        color: Core.Theme.textPrimary
                        font.pixelSize: Core.Theme.bodySize
                        horizontalAlignment: Text.AlignRight
                    }
                    Text {
                        text: "Elevation"
                        color: Core.Theme.textSecondary
                        font.pixelSize: Core.Theme.captionSize
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }

        // Bottom calibration status bar
        Core.Card {
            Layout.fillWidth: true
            Layout.preferredHeight: 56

            RowLayout {
                anchors.fill: parent

                Text {
                    text: "Calibration: " + (calibrated ? "✓ OK" : "⚠ Needed")
                    color: calibrated ? Core.Theme.success : Core.Theme.warning
                    font.pixelSize: Core.Theme.captionSize
                }

                Item { Layout.fillWidth: true }

                Core.Button {
                    text: "Calibrate"
                    size: "small"
                    variant: "secondary"
                    visible: !calibrated
                    onClicked: {
                        if (SensorBridge) {
                            SensorBridge.calibrateCompass()
                        }
                    }
                }
            }
        }
    }

    // Refresh timer for smooth compass updates
    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            if (SensorBridge) {
                SensorBridge.refreshCompass()
            }
        }
    }
}
