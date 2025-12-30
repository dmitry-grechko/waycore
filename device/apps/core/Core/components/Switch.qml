import QtQuick 2.15
import ".." as Core

/**
 * Switch - Tactical styled toggle switch
 *
 * Matches the HTML design with:
 * - Semi-transparent track with border
 * - Accent color when checked
 * - Smooth transition animations
 *
 * Usage:
 *   Core.Switch {
 *       checked: true
 *       onToggled: console.log("Switched to:", checked)
 *   }
 */
Item {
    id: switchControl

    property bool checked: false
    property bool enabled: true

    signal toggled(bool value)

    width: 48
    height: 28
    opacity: enabled ? 1.0 : 0.5

    // Track background
    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: switchControl.checked ?
               Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.8) :
               Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.3)
        border.color: switchControl.checked ? Core.Theme.warning : Core.Theme.divider
        border.width: 1

        Behavior on color {
            ColorAnimation { duration: 200 }
        }
        Behavior on border.color {
            ColorAnimation { duration: 200 }
        }
    }

    // Thumb/knob
    Rectangle {
        id: thumb
        width: 20
        height: 20
        radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        x: switchControl.checked ? parent.width - width - 4 : 4

        // Color changes based on state
        color: switchControl.checked ? Core.Theme.warning : Core.Theme.textSecondary
        border.color: switchControl.checked ? Core.Theme.warning : Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.5)
        border.width: 1

        Behavior on x {
            NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
        }
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
        Behavior on border.color {
            ColorAnimation { duration: 200 }
        }

        // Subtle glow when checked
        Rectangle {
            visible: switchControl.checked
            anchors.centerIn: parent
            width: parent.width + 4
            height: parent.height + 4
            radius: width / 2
            color: "transparent"
            border.color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.4)
            border.width: 2
            opacity: 0.6
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: switchControl.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            switchControl.checked = !switchControl.checked
            switchControl.toggled(switchControl.checked)
        }
    }
}
