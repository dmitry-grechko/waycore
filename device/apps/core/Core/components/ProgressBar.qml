import QtQuick 2.15
import ".." as Core

/**
 * ProgressBar - Tactical styled progress indicator
 *
 * Matches the HTML design with:
 * - Dark background with subtle border
 * - Accent/warning color fill
 * - Subtle glow effect on fill
 *
 * Usage:
 *   Core.ProgressBar {
 *       value: 0.52
 *       variant: "warning"
 *   }
 */
Item {
    id: progressBar

    property real value: 0.0  // 0.0 to 1.0
    property bool indeterminate: false
    property string variant: "default"  // default | success | warning | error
    property color barColor: {
        switch (variant) {
            case "error": return Core.Theme.error
            case "warning": return Core.Theme.warning
            case "success": return Core.Theme.success
            default: return Core.Theme.warning  // Use warning/accent as default for tactical
        }
    }

    height: 10
    implicitHeight: 10
    implicitWidth: 200

    // Track with border
    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: Qt.rgba(Core.Theme.background.r, Core.Theme.background.g, Core.Theme.background.b, 0.5)
        border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
        border.width: 1
        clip: true

        // Fill bar
        Rectangle {
            id: fill
            visible: !progressBar.indeterminate
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 1
            width: Math.max(0, (parent.width - 2) * Math.min(1.0, Math.max(0.0, progressBar.value)))
            radius: track.radius - 1
            color: progressBar.barColor

            Behavior on width {
                NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
            }

            // Subtle glow effect inside fill
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.15) }
                    GradientStop { position: 0.5; color: "transparent" }
                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.1) }
                }
            }
        }

        // Indeterminate animation
        Rectangle {
            id: indeterminateFill
            visible: progressBar.indeterminate
            width: parent.width * 0.3
            height: parent.height - 2
            y: 1
            radius: track.radius - 1
            color: progressBar.barColor

            SequentialAnimation on x {
                loops: Animation.Infinite
                running: progressBar.indeterminate
                NumberAnimation {
                    from: -indeterminateFill.width
                    to: progressBar.width
                    duration: 1000
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
