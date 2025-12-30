import QtQuick 2.15
import ".." as Core

/**
 * TacticalBackground - Standardized tactical grid background with vignette
 *
 * Usage:
 *   TacticalBackground {
 *       anchors.fill: parent
 *   }
 *
 * Properties:
 *   - gridSize: Size of grid squares (default: Theme.gridSize = 40)
 *   - gridOpacity: Opacity of grid lines (default: 0.1)
 *   - showVignette: Whether to show vignette effect (default: true)
 *   - vignetteOpacity: Opacity of vignette (default: 0.3)
 */
Item {
    id: root

    property int gridSize: Core.Theme.gridSize
    property real gridOpacity: 0.1
    property bool showVignette: true
    property real vignetteOpacity: 0.3

    // Grid pattern
    Canvas {
        id: gridPattern
        anchors.fill: parent
        z: 0

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.strokeStyle = Core.Theme.divider
            ctx.lineWidth = 1

            for (var x = 0; x <= width; x += root.gridSize) {
                ctx.beginPath()
                ctx.moveTo(x, 0)
                ctx.lineTo(x, height)
                ctx.stroke()
            }

            for (var y = 0; y <= height; y += root.gridSize) {
                ctx.beginPath()
                ctx.moveTo(0, y)
                ctx.lineTo(width, y)
                ctx.stroke()
            }
        }

        opacity: root.gridOpacity

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    // Vignette overlay
    Item {
        anchors.fill: parent
        z: 1
        visible: root.showVignette

        // Top edge gradient
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height * 0.25
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, root.vignetteOpacity) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        // Bottom edge gradient
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height * 0.25
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, root.vignetteOpacity) }
            }
        }
    }
}
