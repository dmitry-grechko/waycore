import QtQuick 2.15
import QtQuick.Controls 2.15
import ".." as Core

/**
 * Slider - Tactical styled value slider
 *
 * Matches the HTML design with:
 * - Dark track with highlight color
 * - Rectangular accent-colored handle
 * - Subtle glow effect on handle
 *
 * Usage:
 *   Core.Slider {
 *       from: 0
 *       to: 100
 *       value: 85
 *       onValueChanged: updateBrightness(value)
 *   }
 */
Slider {
    id: slider

    property bool showLabel: false
    property string labelFormat: "%1"
    property int labelDecimals: 0

    from: 0
    to: 100
    stepSize: 1

    implicitWidth: 200
    implicitHeight: 32

    // Track background
    background: Rectangle {
        x: slider.leftPadding
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: slider.availableWidth
        height: 4
        radius: 2
        color: Core.Theme.surface

        // Filled portion
        Rectangle {
            width: slider.visualPosition * parent.width
            height: parent.height
            radius: 2
            color: Core.Theme.warning

            // Subtle gradient for depth
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.2) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }
    }

    // Handle - rectangular tactical style
    handle: Rectangle {
        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: 12
        height: 20
        radius: 2
        color: Core.Theme.warning

        // Glow effect
        Rectangle {
            anchors.centerIn: parent
            width: parent.width + 4
            height: parent.height + 4
            radius: 3
            color: "transparent"
            border.color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, slider.pressed ? 0.6 : 0.3)
            border.width: 2
            opacity: 0.8

            Behavior on border.color {
                ColorAnimation { duration: 150 }
            }
        }

        // Inner highlight
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 1
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.3) }
                GradientStop { position: 0.5; color: "transparent" }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.2) }
            }
        }

        scale: slider.pressed ? 1.05 : 1.0
        Behavior on scale {
            NumberAnimation { duration: 100 }
        }
    }

    // Value label (optional)
    Text {
        visible: slider.showLabel
        anchors.horizontalCenter: slider.handle.horizontalCenter
        anchors.bottom: slider.handle.top
        anchors.bottomMargin: 4

        text: slider.labelFormat.arg(slider.value.toFixed(slider.labelDecimals))
        color: Core.Theme.textSecondary
        font.pixelSize: Core.Theme.tinySize
        font.family: Core.Theme.fontFamilyMono
    }
}
