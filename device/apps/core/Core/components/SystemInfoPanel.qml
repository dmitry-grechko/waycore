import QtQuick 2.15
import QtQuick.Layouts 1.15
import ".." as Core

/**
 * SystemInfoPanel - Displays CPU and Memory statistics in tactical style
 *
 * Shows system health metrics with progress bars in a dashed border container.
 */
Rectangle {
    id: panel

    // System metrics (from SensorBridge or mocked)
    property int cpuTemp: (SensorBridge && typeof SensorBridge.cpuTemperature !== "undefined") ? SensorBridge.cpuTemperature : 42
    property real memUsedGB: 1.2
    property real memTotalGB: 8.0
    property real memPercent: memUsedGB / memTotalGB

    color: Qt.rgba(0, 0, 0, 0.2)  // bg-black/20
    radius: Core.Theme.borderRadiusLarge
    border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.5)
    border.width: 1
    implicitHeight: content.implicitHeight + Core.Theme.spacingMedium * 2

    // Dashed border effect using Canvas
    Canvas {
        id: dashedBorder
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.strokeStyle = Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.5)
            ctx.lineWidth = 1
            ctx.setLineDash([4, 4])
            ctx.beginPath()
            ctx.roundedRect(0.5, 0.5, width - 1, height - 1, Core.Theme.borderRadiusLarge, Core.Theme.borderRadiusLarge)
            ctx.stroke()
        }
    }

    Column {
        id: content
        anchors.fill: parent
        anchors.margins: Core.Theme.spacingMedium
        spacing: Core.Theme.spacingSmall

        // CPU Temperature
        Column {
            width: parent.width
            spacing: 4

            RowLayout {
                width: parent.width

                Text {
                    text: "CPU TEMP"
                    color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.7)
                    font.pixelSize: Core.Theme.tinySize
                    font.family: Core.Theme.fontFamilyMono
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: cpuTemp + "°C"
                    color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.7)
                    font.pixelSize: Core.Theme.tinySize
                    font.family: Core.Theme.fontFamilyMono
                }
            }

            // Progress bar
            Rectangle {
                width: parent.width
                height: 4
                radius: 2
                color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)

                Rectangle {
                    width: parent.width * Math.min(1.0, cpuTemp / 100)
                    height: parent.height
                    radius: 2
                    color: Core.Theme.primary

                    Behavior on width {
                        NumberAnimation { duration: Core.Theme.animationNormal }
                    }
                }
            }
        }

        // Memory Load
        Column {
            width: parent.width
            spacing: 4

            RowLayout {
                width: parent.width

                Text {
                    text: "MEM LOAD"
                    color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.7)
                    font.pixelSize: Core.Theme.tinySize
                    font.family: Core.Theme.fontFamilyMono
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: memUsedGB.toFixed(1) + "GB / " + memTotalGB.toFixed(0) + "GB"
                    color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.7)
                    font.pixelSize: Core.Theme.tinySize
                    font.family: Core.Theme.fontFamilyMono
                }
            }

            // Progress bar
            Rectangle {
                width: parent.width
                height: 4
                radius: 2
                color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)

                Rectangle {
                    width: parent.width * Math.min(1.0, memPercent)
                    height: parent.height
                    radius: 2
                    color: Core.Theme.primary

                    Behavior on width {
                        NumberAnimation { duration: Core.Theme.animationNormal }
                    }
                }
            }
        }
    }
}
