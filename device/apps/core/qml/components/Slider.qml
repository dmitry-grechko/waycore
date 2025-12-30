import QtQuick 2.15
import QtQuick.Controls 2.15
import ".." as Core

/**
 * Slider - Enhanced value slider
 *
 * Usage:
 *   Core.Slider {
 *       from: 0
 *       to: 100
 *       value: 50
 *       showLabel: true
 *       onValueChanged: updateVolume(value)
 *   }
 */
Slider {
    id: slider

    property bool showLabel: false
    property string labelFormat: "%1"  // Format string for label
    property int labelDecimals: 0

    from: 0
    to: 100
    stepSize: 1

    background: Rectangle {
        x: slider.leftPadding
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: slider.availableWidth
        height: 6
        radius: 3
        color: Core.Theme.surfaceHighlight

        Rectangle {
            width: slider.visualPosition * parent.width
            height: parent.height
            radius: 3
            color: slider.pressed ? Core.Theme.primaryDark : Core.Theme.primary

            Behavior on color {
                ColorAnimation { duration: Core.Theme.animationFast }
            }
        }
    }

    handle: Rectangle {
        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: Core.Theme.iconSizeLarge
        height: Core.Theme.iconSizeLarge
        radius: width / 2
        color: slider.pressed ? Core.Theme.primary : Core.Theme.textPrimary
        border.color: Core.Theme.primary
        border.width: 2

        // Larger hit area for gloves
        Rectangle {
            anchors.fill: parent
            anchors.margins: -Core.Theme.spacingSmall
            color: "transparent"
        }

        Behavior on scale {
            NumberAnimation { duration: Core.Theme.animationFast }
        }

        scale: slider.pressed ? 1.1 : 1.0
    }

    // Value label
    Text {
        visible: slider.showLabel
        anchors.horizontalCenter: slider.handle.horizontalCenter
        anchors.bottom: slider.handle.top
        anchors.bottomMargin: Core.Theme.spacingXS

        text: slider.labelFormat.arg(slider.value.toFixed(slider.labelDecimals))
        color: Core.Theme.textSecondary
        font.pixelSize: Core.Theme.captionSize
    }

    implicitWidth: 200
    implicitHeight: Core.Theme.touchTarget
}
