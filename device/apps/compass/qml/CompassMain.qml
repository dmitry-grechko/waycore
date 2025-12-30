import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * CompassMain - Tactical navigation compass with bearing and position display
 *
 * Uses standardized Core components:
 * - TacticalBackground for grid + vignette
 * - Theme colors for consistency
 *
 * Features:
 * - Large heading display with cardinal direction
 * - Rotating compass rose with cardinal markers
 * - GPS coordinates and altitude display
 */
Rectangle {
    id: root
    color: Core.Theme.background

    // Standard app interface
    signal closeRequested()
    property string appId: "com.waycore.compass"
    property string appTitle: "Compass"

    // Compass data from SensorBridge
    property real heading: SensorBridge ? SensorBridge.compassHeading : 320
    property string cardinal: SensorBridge ? SensorBridge.compassCardinal : "NW"
    property bool calibrated: SensorBridge ? SensorBridge.compassCalibrated : true
    property bool connected: SensorBridge ? SensorBridge.connected : false

    // GPS data
    property bool hasGps: SensorBridge ? SensorBridge.hasGpsFix : true
    property real latitude: SensorBridge ? SensorBridge.gpsLatitude : 34.05
    property real longitude: SensorBridge ? SensorBridge.gpsLongitude : -118.25
    property real gpsAccuracy: SensorBridge ? SensorBridge.gpsAccuracy : 5

    // Elevation data
    property bool hasElevation: SensorBridge ? SensorBridge.hasElevation : true
    property real elevation: SensorBridge ? SensorBridge.elevationMeters : 124

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

        // Header using PageHeader with custom GPS status
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Core.Theme.appBarHeight

            Core.PageHeader {
                anchors.fill: parent
                title: "Compass"
                showBack: true
                onBackClicked: root.closeRequested()
            }

            // GPS Status indicator (overlaid on right side)
            Row {
                anchors.right: parent.right
                anchors.rightMargin: Core.Theme.spacingMedium
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                z: 10

                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: Core.Theme.warning
                    opacity: hasGps ? 1.0 : 0.4

                    SequentialAnimation on opacity {
                        running: hasGps
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.5; duration: 1000 }
                        NumberAnimation { to: 1.0; duration: 1000 }
                    }
                }
                Text {
                    text: "GPS"
                    color: Core.Theme.warning
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    font.family: Core.Theme.fontFamilyMono
                    font.letterSpacing: 0.5
                }
            }
        }

        // Scrollable content area
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: contentColumn.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: contentColumn
                width: parent.width
                spacing: Core.Theme.spacingMedium

                // Main content with max width constraint
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: headingSection.height + compassSection.height + dataSection.height + Core.Theme.spacingMedium * 2
                    Layout.alignment: Qt.AlignHCenter

                    ColumnLayout {
                        id: mainContent
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Math.min(parent.width - 32, 400)
                        spacing: Core.Theme.spacingMedium

                        // Heading display section
                        Item {
                            id: headingSection
                            Layout.fillWidth: true
                            Layout.preferredHeight: 100
                            Layout.topMargin: 24

                            Column {
                                anchors.centerIn: parent
                                spacing: 8

                                // Large heading with cardinal
                                Item {
                                    width: headingText.width + cardinalText.width + 60
                                    height: headingText.height
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    // North indicator
                                    Text {
                                        anchors.right: headingText.left
                                        anchors.rightMargin: 12
                                        anchors.top: parent.top
                                        anchors.topMargin: 8
                                        text: "▲"
                                        color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.5)
                                        font.pixelSize: 20
                                    }

                                    Text {
                                        id: headingText
                                        anchors.centerIn: parent
                                        text: Math.round(heading)
                                        color: Core.Theme.textPrimary
                                        font.pixelSize: 64
                                        font.family: "JetBrains Mono, Consolas, monospace"
                                        font.weight: Font.Bold
                                        font.letterSpacing: -2

                                        Text {
                                            anchors.left: parent.right
                                            anchors.top: parent.top
                                            anchors.topMargin: 4
                                            text: "°"
                                            color: Core.Theme.warning
                                            font.pixelSize: 32
                                        }
                                    }

                                    Text {
                                        id: cardinalText
                                        anchors.left: headingText.right
                                        anchors.leftMargin: 32
                                        anchors.bottom: headingText.bottom
                                        anchors.bottomMargin: 8
                                        text: cardinal
                                        color: Core.Theme.warning
                                        font.pixelSize: 28
                                        font.weight: Font.Bold
                                        font.letterSpacing: 3
                                    }
                                }

                                // Decorative divider
                                Rectangle {
                                    width: 128
                                    height: 2
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    gradient: Gradient {
                                        orientation: Gradient.Horizontal
                                        GradientStop { position: 0.0; color: "transparent" }
                                        GradientStop { position: 0.5; color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.5) }
                                        GradientStop { position: 1.0; color: "transparent" }
                                    }
                                }
                            }
                        }

                        // Compass rose section
                        Item {
                            id: compassSection
                            Layout.fillWidth: true
                            Layout.preferredHeight: width
                            Layout.maximumHeight: 320
                            Layout.alignment: Qt.AlignHCenter

                            Item {
                                id: compassContainer
                                width: Math.min(parent.width, 288)
                                height: width
                                anchors.centerIn: parent

                                // Fixed top arrow indicator
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottom: outerRing.top
                                    anchors.bottomMargin: -8
                                    text: "▼"
                                    color: Core.Theme.warning
                                    font.pixelSize: 32
                                    z: 20
                                }

                                // Outer dashed rotating ring
                                Rectangle {
                                    id: outerRing
                                    anchors.fill: parent
                                    radius: width / 2
                                    color: "transparent"
                                    border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.4)
                                    border.width: 2

                                    RotationAnimation on rotation {
                                        from: 0
                                        to: 360
                                        duration: 60000
                                        loops: Animation.Infinite
                                        running: true
                                    }
                                }

                                // Inner ring
            Rectangle {
                anchors.centerIn: parent
                                    width: parent.width - 24
                height: width
                radius: width / 2
                                    color: "transparent"
                                    border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.2)
                                    border.width: 1
                                }

                                // Rotating compass rose with cardinal directions
                Item {
                                    id: compassRose
                    anchors.fill: parent
                    rotation: -heading

                    Behavior on rotation {
                        NumberAnimation {
                            duration: Core.Theme.animationNormal
                            easing.type: Easing.OutQuad
                        }
                    }

                                    // North marker
                                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                                        anchors.topMargin: 16
                                        spacing: 2

                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: "N"
                                            color: Core.Theme.warning
                                            font.pixelSize: 18
                                            font.weight: Font.Bold
                                            font.family: "JetBrains Mono, Consolas, monospace"
                                        }
                                        Rectangle {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            width: 2
                                            height: 6
                                            color: Core.Theme.warning
                                        }
                                    }

                                    // South marker
                                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 16
                                        spacing: 2

                                        Rectangle {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            width: 2
                                            height: 6
                                            color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.5)
                                        }
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: "S"
                                            color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.5)
                                            font.pixelSize: 14
                                            font.weight: Font.Bold
                                            font.family: "JetBrains Mono, Consolas, monospace"
                                        }
                                    }

                                    // West marker
                                    Row {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 16
                                        spacing: 4

                    Text {
                                            text: "W"
                                            color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.5)
                                            font.pixelSize: 14
                                            font.weight: Font.Bold
                                            font.family: "JetBrains Mono, Consolas, monospace"
                                        }
                                        Rectangle {
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: 6
                                            height: 2
                                            color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.5)
                                        }
                                    }

                                    // East marker
                                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                                        anchors.rightMargin: 16
                                        spacing: 4

                                        Rectangle {
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: 6
                                            height: 2
                                            color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.5)
                                        }
                    Text {
                                            text: "E"
                                            color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.5)
                                            font.pixelSize: 14
                                            font.weight: Font.Bold
                                            font.family: "JetBrains Mono, Consolas, monospace"
                                        }
                                    }

                                    // Intercardinal dots (NE, NW, SE, SW)
                    Repeater {
                                        model: 4
                                        Rectangle {
                                            width: 4
                                            height: 4
                                            radius: 2
                                            color: Core.Theme.divider
                                            x: compassRose.width / 2 + Math.cos((45 + index * 90) * Math.PI / 180) * (compassRose.width / 2 - 32) - 2
                                            y: compassRose.height / 2 + Math.sin((45 + index * 90) * Math.PI / 180) * (compassRose.height / 2 - 32) - 2
                                        }
                                    }
                                }

                                // Center compass face
                                Rectangle {
                                    id: compassFace
                                    anchors.centerIn: parent
                                    width: 176
                                    height: 176
                                    radius: 88
                                    color: Core.Theme.surface
                                    border.color: Core.Theme.divider
                                    border.width: 1

                                    // Inner shadow effect
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: parent.radius
                                        color: "transparent"

                                        Rectangle {
                                            anchors.fill: parent
                                            radius: parent.radius
                                            gradient: Gradient {
                                                GradientStop { position: 0.0; color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.2) }
                                                GradientStop { position: 0.4; color: "transparent" }
                                            }
                                            opacity: 0.4
                                        }
                                    }

                                    // Horizontal crosshair line
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width
                                        height: 1
                                        color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.8)
                                    }

                                    // Upper tick mark
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                                        anchors.topMargin: parent.height * 0.35 - 0.5
                                        width: 48
                                        height: 1
                                        color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.3)
                                    }

                                    // Lower tick mark
                                    Rectangle {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: parent.height * 0.35 - 0.5
                                        width: 48
                                        height: 1
                                        color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.3)
                                    }

                                    // Center crosshair symbol
                                    Text {
                                        anchors.centerIn: parent
                                        text: "+"
                                        color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.9)
                                        font.pixelSize: 28
                                    }
                                }
                            }
                        }

                        // Data cards section - Coordinates and Altitude side by side
                        Item {
                            id: dataSection
                            Layout.fillWidth: true
                            Layout.preferredHeight: 72
                            Layout.bottomMargin: 240  // Space for quick access bar

                            RowLayout {
                                anchors.fill: parent
                                spacing: 12

                                // Coordinates card
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: parent.width * 0.6
                                    Layout.fillHeight: true
                                    color: Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.5)
                                    border.color: Core.Theme.divider
                                    border.width: 1
                                    radius: 4

                                    Column {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 4

                                        Row {
                                            spacing: 8
                                            Text {
                                                text: "◎"
                                                color: Core.Theme.textSecondary
                                                font.pixelSize: 12
                                            }
                                            Text {
                                                text: "COORDINATES"
                                                color: Core.Theme.textSecondary
                                                font.pixelSize: 10
                                                font.weight: Font.Bold
                                                font.letterSpacing: 2
                                            }
                                        }
                                        Text {
                                            text: formatCoordinate(latitude, "N", "S") + " " + formatCoordinate(longitude, "E", "W")
                                            color: Core.Theme.textPrimary
                                            font.pixelSize: 14
                                            font.family: "JetBrains Mono, Consolas, monospace"
                                            font.weight: Font.Medium
                                            font.letterSpacing: -0.5
                                        }
                                    }
                                }

                                // Altitude card
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: parent.width * 0.4
                                    Layout.fillHeight: true
                                    color: Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.5)
                                    border.color: Core.Theme.divider
                                    border.width: 1
                                    radius: 4

                                    Column {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 4

                                        Text {
                                            text: "ALTITUDE"
                                            color: Core.Theme.textSecondary
                                            font.pixelSize: 10
                                            font.weight: Font.Bold
                                            font.letterSpacing: 2
                                        }
                                        Row {
                                            spacing: 4
                                            Text {
                                                text: hasElevation ? Math.round(elevation) : "--"
                                                color: Core.Theme.textPrimary
                                                font.pixelSize: 20
                                                font.family: "JetBrains Mono, Consolas, monospace"
                                                font.weight: Font.Medium
                                            }
                                            Text {
                                                anchors.bottom: parent.bottom
                                                anchors.bottomMargin: 2
                                                text: "M"
                                                color: Core.Theme.divider
                                                font.pixelSize: 12
                                                font.weight: Font.Bold
                                                font.family: "JetBrains Mono, Consolas, monospace"
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Helper function to format coordinates
    function formatCoordinate(value, positive, negative) {
        var direction = value >= 0 ? positive : negative
        var absValue = Math.abs(value)
        var degrees = Math.floor(absValue)
        var minutes = Math.floor((absValue - degrees) * 60)
        return degrees + "°" + (minutes < 10 ? "0" : "") + minutes + "'" + direction
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
