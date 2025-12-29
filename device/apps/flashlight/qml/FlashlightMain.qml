import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

Rectangle {
    id: flashlight
    color: isOn ? "#FFFFFF" : Core.Theme.background

    // Standard app interface
    property string appId: "com.waycore.flashlight"
    property string appTitle: "Flashlight"
    signal closeRequested()

    // Flashlight state
    property bool isOn: false

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header bar
        Rectangle {
            Layout.fillWidth: true
            height: 56
            color: isOn ? Qt.rgba(0, 0, 0, 0.1) : Core.Theme.surface

            RowLayout {
                anchors.fill: parent
                anchors.margins: Core.Theme.spacingSmall
                spacing: Core.Theme.spacingSmall

                Button {
                    text: "←"
                    font.pixelSize: 20
                    onClicked: closeRequested()
                }

                Text {
                    Layout.fillWidth: true
                    text: "🔦 Flashlight"
                    color: isOn ? "#000000" : Core.Theme.textPrimary
                    font.pixelSize: Core.Theme.h2Size
                    font.bold: true
                }

                Text {
                    text: isOn ? "ON" : "OFF"
                    color: isOn ? Core.Theme.success : Core.Theme.textSecondary
                    font.pixelSize: Core.Theme.bodySize
                    font.bold: true
                }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: isOn ? Qt.rgba(0, 0, 0, 0.1) : Core.Theme.divider
        }

        // Main content - big toggle button
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Column {
                anchors.centerIn: parent
                spacing: Core.Theme.spacingLarge

                // Big flashlight icon/button
                Rectangle {
                    width: 200
                    height: 200
                    radius: 100
                    color: isOn ? Core.Theme.warning : Core.Theme.surface
                    border.color: isOn ? "#FFD700" : Core.Theme.divider
                    border.width: 4
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "🔦"
                        font.pixelSize: 80
                        opacity: isOn ? 1.0 : 0.5
                    }

                    // Glow effect when on
                    Rectangle {
                        visible: isOn
                        anchors.centerIn: parent
                        width: parent.width + 40
                        height: parent.height + 40
                        radius: (width / 2)
                        color: "transparent"
                        border.color: "#FFD700"
                        border.width: 2
                        opacity: 0.5
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            isOn = !isOn
                        }
                    }

                    // Pulse animation when on
                    SequentialAnimation on scale {
                        running: isOn
                        loops: Animation.Infinite
                        NumberAnimation { to: 1.05; duration: 1000; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: 1.0; duration: 1000; easing.type: Easing.InOutQuad }
                    }
                }

                // Status text
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: isOn ? "Tap to turn off" : "Tap to turn on"
                    color: isOn ? "#000000" : Core.Theme.textSecondary
                    font.pixelSize: Core.Theme.bodySize
                }

                // Battery warning
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "⚠️ Using flashlight drains battery"
                    color: isOn ? Qt.rgba(0, 0, 0, 0.5) : Core.Theme.textSecondary
                    font.pixelSize: Core.Theme.captionSize
                    visible: isOn
                }
            }
        }
    }

    // Screen stays awake when flashlight is on
    // Note: In production, this would prevent screen dimming
    Timer {
        interval: 1000
        running: isOn
        repeat: true
        onTriggered: {
            // Keep-alive timer - in production would prevent screen sleep
        }
    }
}
