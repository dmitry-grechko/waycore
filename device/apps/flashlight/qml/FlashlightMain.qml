import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * Flashlight - LED flashlight control with brightness and modes
 */
Rectangle {
    id: flashlight
    color: Core.Theme.background

    // Standard app interface
    property string appId: "com.waycore.flashlight"
    property string appTitle: "Flashlight"
    signal closeRequested()

    // Flashlight state
    property bool isOn: false
    property int brightness: 80  // 0-100
    property string currentMode: "normal"  // normal, sos, strobe, boost

    // Calculated values
    property int lumens: Math.round(1500 * (brightness / 100))
    property int colorTemp: 5500
    property int batteryLevel: 84
    property string estimatedRuntime: calculateRuntime()

    function calculateRuntime() {
        // Rough estimate: 5 hours at 50% brightness
        var baseHours = 5
        var factor = (100 - brightness) / 50 + 0.5
        var totalMinutes = Math.round(baseHours * 60 * factor)
        var hours = Math.floor(totalMinutes / 60)
        var mins = totalMinutes % 60
        return hours + "H " + mins + "M"
    }

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
            title: "Flashlight"
            showBack: true
            onBackClicked: closeRequested()
        }

        // Main content
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Core.Theme.spacingMedium
                spacing: Core.Theme.spacingLarge

                // Power button section
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 280
                    Layout.alignment: Qt.AlignHCenter

                    // Outer dashed rotating ring
                    Rectangle {
                        anchors.centerIn: parent
                        width: 240
                        height: 240
                        radius: 120
                        color: "transparent"
                        border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
                        border.width: 1

                        RotationAnimation on rotation {
                            from: 0
                            to: 360
                            duration: 10000
                            loops: Animation.Infinite
                            running: true
                        }
                    }

                    // Inner static ring
                    Rectangle {
                        anchors.centerIn: parent
                        width: 208
                        height: 208
                        radius: 104
                        color: "transparent"
                        border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.5)
                        border.width: 1
                    }

                    // Glow effect when on (concentric circles for soft glow)
                Rectangle {
                        visible: isOn
                        anchors.centerIn: parent
                        width: 260
                        height: 260
                        radius: 130
                        color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.03)
                    }

                    Rectangle {
                        visible: isOn
                        anchors.centerIn: parent
                        width: 240
                        height: 240
                        radius: 120
                        color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.05)
                    }

                    Rectangle {
                        visible: isOn
                        anchors.centerIn: parent
                        width: 220
                        height: 220
                        radius: 110
                        color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.08)
                    }

                    // Main power button
                    Rectangle {
                        id: powerButton
                        anchors.centerIn: parent
                        width: 192
                        height: 192
                        radius: 96

                        gradient: Gradient {
                            GradientStop { position: 0.0; color: isOn ? Core.Theme.surface : Core.Theme.surface }
                            GradientStop { position: 1.0; color: isOn ? Core.Theme.background : Core.Theme.background }
                        }

                        border.color: isOn ? Core.Theme.warning : Core.Theme.divider
                        border.width: isOn ? 3 : 2

                        Behavior on border.color {
                            ColorAnimation { duration: 150 }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: Core.Theme.spacingSmall
                            z: 10

                            // Power icon - use lightbulb icons
                            Core.MaterialIcon {
                                anchors.horizontalCenter: parent.horizontalCenter
                                name: isOn ? "lightbulb-on" : "lightbulb"
                                size: 64
                                iconColor: isOn ? Core.Theme.warning : Core.Theme.textSecondary

                                Behavior on iconColor {
                                    ColorAnimation { duration: 150 }
                                }
                            }

                            // ON/OFF indicator
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: isOn ? "ON" : "OFF"
                                color: isOn ? Core.Theme.warning : Core.Theme.textSecondary
                                font.pixelSize: Core.Theme.bodySmallSize
                                font.family: Core.Theme.fontFamilyMono
                                font.weight: Font.Bold
                                font.letterSpacing: 3

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }
                        }

                        // Press animation
                        scale: powerButtonArea.pressed ? 0.95 : 1.0
                        Behavior on scale {
                            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                        }

                        MouseArea {
                            id: powerButtonArea
                            anchors.fill: parent
                            onClicked: {
                                isOn = !isOn
                                if (!isOn) {
                                    currentMode = "normal"
                                }
                            }
                        }
                    }

                    // State label below button
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: powerButton.bottom
                        anchors.topMargin: Core.Theme.spacingLarge
                        text: "STATE: " + (isOn ? "ACTIVE" : "STANDBY")
                        color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.5)
                        font.pixelSize: Core.Theme.tinySize
                        font.family: Core.Theme.fontFamilyMono
                        font.letterSpacing: 3
                    }
                }

                // Stats row
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24

                    Text {
                        text: "LUMENS: "
                        color: Core.Theme.textSecondary
                        font.pixelSize: Core.Theme.smallSize
                        font.family: Core.Theme.fontFamilyMono
                        font.letterSpacing: 2
                    }
                    Text {
                        text: isOn ? lumens.toString() : "0"
                        color: Core.Theme.textPrimary
                        font.pixelSize: Core.Theme.smallSize
                        font.family: Core.Theme.fontFamilyMono
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "TEMP: "
                        color: Core.Theme.textSecondary
                        font.pixelSize: Core.Theme.smallSize
                        font.family: Core.Theme.fontFamilyMono
                        font.letterSpacing: 2
                    }
                    Text {
                        text: colorTemp + "K"
                        color: Core.Theme.textPrimary
                        font.pixelSize: Core.Theme.smallSize
                        font.family: Core.Theme.fontFamilyMono
                    }
                }

                // Brightness control section
                Column {
                    Layout.fillWidth: true
                    spacing: Core.Theme.spacingSmall

                    // Label
                    Text {
                        text: "BRIGHTNESS LEVEL"
                        color: Core.Theme.textSecondary
                        font.pixelSize: Core.Theme.tinySize
                        font.weight: Font.Bold
                        font.letterSpacing: 3
                    }

                    // Slider row
                    RowLayout {
                        width: parent.width
                        spacing: Core.Theme.spacingMedium

                        // Low brightness icon (outlined sun)
                        Core.MaterialIcon {
                            name: "weather-sunny-off"
                            size: 20
                            iconColor: Core.Theme.textSecondary
                        }

                        // Custom slider
                        Item {
                            Layout.fillWidth: true
                            height: 40

                            // Track background
                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                height: 8
                                radius: 4
                                color: Core.Theme.surface
                                border.color: Core.Theme.divider
                                border.width: 1

                                // Fill
                                Rectangle {
                                    width: parent.width * (brightness / 100)
                                    height: parent.height
                                    radius: parent.radius
                                    color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.8)
                                }

                                // Tick marks
                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 2

                                    Repeater {
                                        model: 11
                                        Item {
                                            width: parent.width / 10
                                            height: parent.height
                                            visible: index < 10

                                            Rectangle {
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: 1
                                                height: 12
                                                color: Qt.rgba(Core.Theme.background.r, Core.Theme.background.g, Core.Theme.background.b, 0.5)
                                            }
                                        }
                                    }
                                }
                            }

                            // Slider thumb
                            Rectangle {
                                id: sliderThumb
                                x: (parent.width - width) * (brightness / 100)
                                anchors.verticalCenter: parent.verticalCenter
                                width: 16
                                height: 32
                                radius: 2
                                color: Core.Theme.warning

                                // Glow effect
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: -4
                                    radius: parent.radius + 2
                                    color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.3)
                                    z: -1
                                }
                            }

                            // Drag area
                            MouseArea {
                                anchors.fill: parent
                                onPositionChanged: {
                                    var newBrightness = Math.round((mouse.x / width) * 100)
                                    brightness = Math.max(0, Math.min(100, newBrightness))
                                }
                                onPressed: {
                                    var newBrightness = Math.round((mouse.x / width) * 100)
                                    brightness = Math.max(0, Math.min(100, newBrightness))
                                }
                            }
                        }

                        // High brightness icon
                        Core.MaterialIcon {
                            name: "weather-sunny"
                            size: 20
                            iconColor: isOn ? Core.Theme.warning : Core.Theme.textSecondary
                        }
                    }

                    // Percentage labels
                    RowLayout {
                        width: parent.width
                        spacing: 0

                        Item { width: 36 }  // Space for left icon

                        Text {
                            text: "0%"
                            color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.6)
                            font.pixelSize: Core.Theme.tinySize
                            font.family: Core.Theme.fontFamilyMono
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "50%"
                            color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.6)
                            font.pixelSize: Core.Theme.tinySize
                            font.family: Core.Theme.fontFamilyMono
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "100%"
                            color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.6)
                            font.pixelSize: Core.Theme.tinySize
                            font.family: Core.Theme.fontFamilyMono
                        }

                        Item { width: 36 }  // Space for right icon
                    }
                }

                // Mode buttons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Core.Theme.spacingSmall

                    // SOS mode
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 72
                        radius: Core.Theme.borderRadius
                        color: currentMode === "sos" ? Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.1) : Core.Theme.surface
                        border.color: currentMode === "sos" ? Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.5) : Core.Theme.divider
                        border.width: 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 4

                            Core.MaterialIcon {
                                anchors.horizontalCenter: parent.horizontalCenter
                                name: "alert"
                                size: 24
                                iconColor: currentMode === "sos" ? Core.Theme.warning : Core.Theme.textSecondary
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "SOS"
                                color: currentMode === "sos" ? Core.Theme.warning : Core.Theme.textSecondary
                                font.pixelSize: Core.Theme.tinySize
                                font.weight: Font.Bold
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (currentMode === "sos") {
                                    currentMode = "normal"
                                } else {
                                    currentMode = "sos"
                                    isOn = true
                                }
                            }
                        }

                        Behavior on color { ColorAnimation { duration: Core.Theme.animationFast } }
                    }

                    // Strobe mode
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 72
                        radius: Core.Theme.borderRadius
                        color: currentMode === "strobe" ? Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.1) : Core.Theme.surface
                        border.color: currentMode === "strobe" ? Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.5) : Core.Theme.divider
                        border.width: 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 4

                            Core.MaterialIcon {
                                anchors.horizontalCenter: parent.horizontalCenter
                                name: "flash"
                                size: 24
                                iconColor: currentMode === "strobe" ? Core.Theme.warning : Core.Theme.textSecondary
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "STROBE"
                                color: currentMode === "strobe" ? Core.Theme.warning : Core.Theme.textSecondary
                                font.pixelSize: Core.Theme.tinySize
                                font.weight: Font.Bold
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (currentMode === "strobe") {
                                    currentMode = "normal"
                                } else {
                                    currentMode = "strobe"
                                    isOn = true
                                }
                            }
                        }

                        Behavior on color { ColorAnimation { duration: Core.Theme.animationFast } }
                    }

                }

                Item { Layout.fillHeight: true }

                // Bottom spacing for quick select menu
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140
                }
            }
        }

        // Footer with battery info
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: Core.Theme.background

            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: Core.Theme.divider
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: Core.Theme.spacingMedium

                // Battery info
                Row {
                    spacing: Core.Theme.spacingSmall

                    Core.MaterialIcon {
                        name: "battery_5_bar"
                        size: 16
                        iconColor: Core.Theme.textSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "BATTERY: " + batteryLevel + "%"
                        color: Core.Theme.textSecondary
                        font.pixelSize: Core.Theme.smallSize
                        font.family: Core.Theme.fontFamilyMono
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Item { Layout.fillWidth: true }

                // Runtime estimate
                Text {
                    text: "EST. RUNTIME: " + (isOn ? estimatedRuntime : "--")
                    color: Core.Theme.textSecondary
                    font.pixelSize: Core.Theme.smallSize
                    font.family: Core.Theme.fontFamilyMono
                }
            }
        }
    }

    // Strobe animation timer
    Timer {
        id: strobeTimer
        interval: 100
        running: isOn && currentMode === "strobe"
        repeat: true
        property bool strobeState: false
        onTriggered: {
            strobeState = !strobeState
            // In production, this would toggle the actual LED
        }
    }

    // SOS pattern timer
    Timer {
        id: sosTimer
        running: isOn && currentMode === "sos"
        repeat: true
        property int patternIndex: 0
        property var pattern: [150, 150, 150, 150, 150, 450, 450, 150, 450, 150, 450, 450, 150, 150, 150, 150, 150, 1050]
        interval: pattern[patternIndex]
        onTriggered: {
            patternIndex = (patternIndex + 1) % pattern.length
            interval = pattern[patternIndex]
            // In production, this would toggle the actual LED
        }
    }
}
