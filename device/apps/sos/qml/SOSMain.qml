import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * SOS Emergency Beacon
 *
 * Provides emergency distress signaling via:
 * - LoRa mesh broadcast
 * - Optical beacon (flashlight SOS pattern)
 * - Acoustic beacon (speaker SOS pattern)
 */
Rectangle {
    id: sos
    color: Core.Theme.background

    // Standard app interface
    property string appId: "com.waycore.sos"
    property string appTitle: "SOS"
    signal closeRequested()

    // SOS state
    property bool sosActive: false
    property bool opticalBeaconEnabled: true
    property bool acousticBeaconEnabled: true
    property bool isHolding: false
    property real holdProgress: 0.0
    property int holdDuration: 3000 // 3 seconds to activate

    // Status
    property bool meshOnline: true
    property string meshFrequency: "868MHz"
    property string gpsCoords: "34.05N, 118.24W"
    property bool hasGpsFix: true

    // Tactical grid background
    Core.TacticalBackground {
        anchors.fill: parent
        gridOpacity: 0.15
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header bar
        Core.PageHeader {
            Layout.fillWidth: true
            title: sosActive ? "SOS ACTIVE" : "SOS BEACON"
            subtitle: sosActive ? "EMERGENCY MODE" : ""
            showBack: !sosActive
            onBackClicked: closeRequested()
        }

        // Emergency broadcast system badge
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.1)
            border.color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.3)
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "EMERGENCY BROADCAST SYSTEM"
                color: Core.Theme.warning
                font.pixelSize: Core.Theme.tinySize
                font.family: Core.Theme.fontFamilyMono
                font.letterSpacing: 3
                font.weight: Font.Bold
            }
        }

        // Description
        Text {
            Layout.fillWidth: true
            Layout.margins: Core.Theme.spacingMedium
            text: "Device will broadcast distress signal via <b>LoRa Mesh</b> and activate sensory beacons."
            color: Core.Theme.textSecondary
            font.pixelSize: Core.Theme.bodySmallSize
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        // Main content area
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // SOS button container (centered)
            Item {
                anchors.centerIn: parent
                width: 280
                height: 280

                // Ping animation (outer ring)
                Rectangle {
                    visible: sosActive
                    anchors.centerIn: parent
                    width: 280
                    height: 280
                    radius: 140
                    color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.2)

                    SequentialAnimation on scale {
                        running: sosActive
                        loops: Animation.Infinite
                        NumberAnimation { to: 1.3; duration: 1500; easing.type: Easing.OutQuad }
                        NumberAnimation { to: 1.0; duration: 0 }
                    }

                    SequentialAnimation on opacity {
                        running: sosActive
                        loops: Animation.Infinite
                        NumberAnimation { to: 0; duration: 1500; easing.type: Easing.OutQuad }
                        NumberAnimation { to: 0.2; duration: 0 }
                    }
                }

                // Dashed rotating ring
                Rectangle {
                    anchors.centerIn: parent
                    width: 256
                    height: 256
                    radius: 128
                    color: "transparent"
                    border.color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.3)
                    border.width: 1

                    // Dashed border effect via rotation
                    RotationAnimation on rotation {
                        running: true
                        from: 0
                        to: 360
                        duration: 12000
                        loops: Animation.Infinite
                    }
                }

                // Inner ring
                Rectangle {
                    anchors.centerIn: parent
                    width: 232
                    height: 232
                    radius: 116
                    color: "transparent"
                    border.color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.5)
                    border.width: 1
                }

                // Main SOS button
                Rectangle {
                    id: sosButton
                    anchors.centerIn: parent
                    width: 224
                    height: 224
                    radius: 112

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: sosActive ? "#DC2626" : "#D4A574" }
                        GradientStop { position: 1.0; color: sosActive ? "#991B1B" : "#8B5A2B" }
                    }

                    border.color: sosActive ? "#7F1D1D" : "#5c3a1e"
                    border.width: 4

                    // Stripe pattern overlay
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        opacity: 0.1
                        color: "transparent"

                        // Simulated stripe pattern with gradient
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "transparent" }
                                GradientStop { position: 0.1; color: Qt.rgba(0, 0, 0, 0.1) }
                                GradientStop { position: 0.2; color: "transparent" }
                                GradientStop { position: 0.3; color: Qt.rgba(0, 0, 0, 0.1) }
                                GradientStop { position: 0.4; color: "transparent" }
                                GradientStop { position: 0.5; color: Qt.rgba(0, 0, 0, 0.1) }
                                GradientStop { position: 0.6; color: "transparent" }
                                GradientStop { position: 0.7; color: Qt.rgba(0, 0, 0, 0.1) }
                                GradientStop { position: 0.8; color: "transparent" }
                                GradientStop { position: 0.9; color: Qt.rgba(0, 0, 0, 0.1) }
                                GradientStop { position: 1.0; color: "transparent" }
                            }
                        }
                    }

                    // Progress ring (during hold)
                    Rectangle {
                        visible: isHolding && !sosActive
                        anchors.centerIn: parent
                        width: parent.width + 16
                        height: parent.height + 16
                        radius: width / 2
                        color: "transparent"
                        border.color: Core.Theme.warning
                        border.width: 4
                        opacity: holdProgress

                        Behavior on opacity {
                            NumberAnimation { duration: 100 }
                        }
                    }

                    // Button content
                    Column {
                        anchors.centerIn: parent
                        spacing: Core.Theme.spacingSmall

                        // SOS icon
                        Core.MaterialIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            name: "alert"
                            size: 64
                            iconColor: sosActive ? "#FFFFFF" : "#2a1805"
                        }

                        // Action text
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: sosActive ? "DEACTIVATE" : "ACTIVATE"
                            color: sosActive ? "#FFFFFF" : "#2a1805"
                            font.pixelSize: Core.Theme.h2Size
                            font.weight: Font.Black
                            font.letterSpacing: 4
                        }

                        // Hold instruction
                        Column {
                            visible: !sosActive
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 4

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "PRESS & HOLD 3S"
                                color: "#4a2e12"
                                font.pixelSize: Core.Theme.tinySize
                                font.family: Core.Theme.fontFamilyMono
                                font.weight: Font.Bold
                                font.letterSpacing: 2
                            }

                            // Progress dots
                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 4

                                Repeater {
                                    model: 3
                                    Rectangle {
                                        width: 6
                                        height: 6
                                        radius: 3
                                        color: holdProgress > (index / 3) ? "#2a1805" : Qt.rgba(0.29, 0.18, 0.07, 0.3 + index * 0.2)
                                    }
                                }
                            }
                        }
                    }

                    // Scale animation on press
                    scale: sosButtonArea.pressed ? 0.95 : 1.0
                    Behavior on scale {
                        NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                    }

                    MouseArea {
                        id: sosButtonArea
                        anchors.fill: parent

                        onPressed: {
                            if (sosActive) {
                                // Deactivate immediately
                                sosActive = false
                                holdProgress = 0
                            } else {
                                // Start hold timer
                                isHolding = true
                                holdTimer.start()
                            }
                        }

                        onReleased: {
                            if (!sosActive) {
                                isHolding = false
                                holdProgress = 0
                                holdTimer.stop()
                            }
                        }

                        onCanceled: {
                            isHolding = false
                            holdProgress = 0
                            holdTimer.stop()
                        }
                    }
                }
            }
        }

        // Beacon toggles
        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: Core.Theme.spacingMedium
            spacing: Core.Theme.spacingSmall

            // Optical beacon
            Core.Card {
                Layout.fillWidth: true
                minHeight: 72

                RowLayout {
                    anchors.fill: parent
                    spacing: Core.Theme.spacingMedium

                    // Icon
                    Rectangle {
                        width: 40
                        height: 40
                        radius: Core.Theme.borderRadius
                        color: Core.Theme.background
                        border.color: Core.Theme.divider
                        border.width: 1

                        Core.MaterialIcon {
                            anchors.centerIn: parent
                            name: "flashlight"
                            size: 24
                            iconColor: Core.Theme.warning
                        }
                    }

                    // Labels
                    Column {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "OPTICAL BEACON"
                            color: Core.Theme.textPrimary
                            font.pixelSize: Core.Theme.bodySmallSize
                            font.weight: Font.Bold
                            font.letterSpacing: 1
                        }

                        Text {
                            text: "HIGH-LUMEN SOS PATTERN"
                            color: Core.Theme.textSecondary
                            font.pixelSize: Core.Theme.tinySize
                            font.family: Core.Theme.fontFamilyMono
                        }
                    }

                    // Toggle
                    Core.Switch {
                        checked: opticalBeaconEnabled
                        onToggled: opticalBeaconEnabled = value
                    }
                }
            }

            // Acoustic beacon
            Core.Card {
                Layout.fillWidth: true
                minHeight: 72

                RowLayout {
                    anchors.fill: parent
                    spacing: Core.Theme.spacingMedium

                    // Icon
                    Rectangle {
                        width: 40
                        height: 40
                        radius: Core.Theme.borderRadius
                        color: Core.Theme.background
                        border.color: Core.Theme.divider
                        border.width: 1

                        Core.MaterialIcon {
                            anchors.centerIn: parent
                            name: "volume-high"
                            size: 24
                            iconColor: Core.Theme.warning
                        }
                    }

                    // Labels
                    Column {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "ACOUSTIC BEACON"
                            color: Core.Theme.textPrimary
                            font.pixelSize: Core.Theme.bodySmallSize
                            font.weight: Font.Bold
                            font.letterSpacing: 1
                        }

                        Text {
                            text: "110dB MORSE ALARM"
                            color: Core.Theme.textSecondary
                            font.pixelSize: Core.Theme.tinySize
                            font.family: Core.Theme.fontFamilyMono
                        }
                    }

                    // Toggle
                    Core.Switch {
                        checked: acousticBeaconEnabled
                        onToggled: acousticBeaconEnabled = value
                    }
                }
            }
        }

        // Status footer
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: "transparent"

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Core.Theme.divider
                opacity: 0.5
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: Core.Theme.spacingMedium

                // LoRA status
                Column {
                    spacing: 2

                    Text {
                        text: "LORA STATUS"
                        color: Core.Theme.textSecondary
                        font.pixelSize: Core.Theme.tinySize
                        font.family: Core.Theme.fontFamilyMono
                        font.letterSpacing: 2
                    }

                    Row {
                        spacing: Core.Theme.spacingSmall

                        // Pulsing dot
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: meshOnline ? Core.Theme.warning : Core.Theme.error
                            anchors.verticalCenter: parent.verticalCenter

                            SequentialAnimation on opacity {
                                running: meshOnline
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.4; duration: 500 }
                                NumberAnimation { to: 1.0; duration: 500 }
                            }
                        }

                        Text {
                            text: meshOnline ? "MESH ONLINE (" + meshFrequency + ")" : "OFFLINE"
                            color: Core.Theme.warning
                            font.pixelSize: Core.Theme.smallSize
                            font.family: Core.Theme.fontFamilyMono
                            font.weight: Font.Bold
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // GPS coords
                Column {
                    spacing: 2

                    Text {
                        text: "GPS COORDS"
                        color: Core.Theme.textSecondary
                        font.pixelSize: Core.Theme.tinySize
                        font.family: Core.Theme.fontFamilyMono
                        font.letterSpacing: 2
                        horizontalAlignment: Text.AlignRight
                        anchors.right: parent.right
                    }

                    Text {
                        text: hasGpsFix ? gpsCoords : "NO FIX"
                        color: hasGpsFix ? Core.Theme.textPrimary : Core.Theme.error
                        font.pixelSize: Core.Theme.smallSize
                        font.family: Core.Theme.fontFamilyMono
                        font.weight: Font.Bold
                        horizontalAlignment: Text.AlignRight
                        anchors.right: parent.right
                    }
                }
            }
        }
    }

    // Hold timer for activation
    Timer {
        id: holdTimer
        interval: 50
        repeat: true
        onTriggered: {
            holdProgress = Math.min(1.0, holdProgress + (interval / holdDuration))
            if (holdProgress >= 1.0) {
                sosActive = true
                isHolding = false
                holdProgress = 0
                stop()
            }
        }
    }

    // Block back navigation while SOS is active
    Keys.onBackPressed: {
        if (sosActive) {
            event.accepted = true
        } else {
            closeRequested()
        }
    }
}
