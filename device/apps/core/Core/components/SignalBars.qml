import QtQuick 2.15
import QtQuick.Controls 2.15
import ".." as Core

/**
 * SignalBars - Visual signal quality indicator
 *
 * Shows 4 bars representing signal quality based on SNR:
 * - 4 bars (excellent): SNR > 5 dB
 * - 3 bars (good): SNR > 0 dB
 * - 2 bars (fair): SNR > -5 dB
 * - 1 bar (weak): SNR > -10 dB
 * - 0 bars (very weak): SNR <= -10 dB
 *
 * Usage:
 *   Core.SignalBars {
 *       snr: 8.5
 *       size: "medium"
 *   }
 */
Item {
    id: signalBars

    property real snr: 0
    property bool hasSignal: !isNaN(snr) && snr !== null
    property int barCount: calculateBars(snr)
    property string size: "medium"  // small | medium | large
    property bool compact: false  // Hide tooltip

    width: sizeValue
    height: sizeValue * 0.67

    readonly property int sizeValue: {
        switch(size) {
            case "small": return 16
            case "large": return 32
            default: return 24
        }
    }

    function calculateBars(snrValue) {
        if (!hasSignal) return 0
        if (snrValue > 5) return 4
        if (snrValue > 0) return 3
        if (snrValue > -5) return 2
        if (snrValue > -10) return 1
        return 0
    }

    function getColor() {
        if (!hasSignal) return Core.Theme.textTertiary
        if (barCount === 4) return Core.Theme.success
        if (barCount === 3) return Core.Theme.success
        if (barCount === 2) return Core.Theme.warning
        if (barCount === 1) return Core.Theme.error
        return Core.Theme.error
    }

    Row {
        anchors.fill: parent
        anchors.bottom: parent.bottom
        spacing: 2
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: 4

            Rectangle {
                property int barIndex: index
                property bool isActive: barIndex < signalBars.barCount

                width: (signalBars.width - 6) / 4  // 4 bars with 3 gaps
                height: {
                    // Bars increase in height: 25%, 50%, 75%, 100%
                    var baseHeight = signalBars.height
                    return baseHeight * (0.25 + (barIndex * 0.25))
                }
                anchors.bottom: parent.bottom
                radius: 1

                color: isActive ? signalBars.getColor() : Core.Theme.surfaceHighlight
                opacity: isActive ? 1.0 : 0.5

                Behavior on color {
                    ColorAnimation { duration: Core.Theme.animationNormal }
                }

                Behavior on opacity {
                    NumberAnimation { duration: Core.Theme.animationNormal }
                }
            }
        }
    }

    // Tooltip with actual values
    ToolTip {
        id: tooltip
        visible: !signalBars.compact && mouseArea.containsMouse
        text: hasSignal ? "SNR: " + snr.toFixed(1) + " dB" : "No signal data"
        delay: 500
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }
}
