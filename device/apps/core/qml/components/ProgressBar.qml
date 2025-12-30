import QtQuick 2.15
import ".." as Core

Item {
    id: progressBar

    property real value: 0.0  // 0.0 to 1.0
    property bool indeterminate: false
    property color barColor: Core.Theme.success

    height: 8
    implicitHeight: 8

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: Core.Theme.surfaceElevated
    }

    Rectangle {
        id: fill
        visible: !progressBar.indeterminate
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * Math.min(1.0, Math.max(0.0, progressBar.value))
        radius: track.radius
        color: progressBar.barColor

        Behavior on width {
            NumberAnimation { duration: Core.Theme.animationNormal }
        }
    }

    // Indeterminate animation
    Rectangle {
        id: indeterminateFill
        visible: progressBar.indeterminate
        width: parent.width * 0.3
        height: parent.height
        radius: track.radius
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

    // Clip to track bounds
    clip: true
}
