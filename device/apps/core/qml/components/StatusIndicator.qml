import QtQuick 2.15
import ".." as Core

Item {
    id: indicator

    property string icon: ""
    property bool active: false
    property string tooltip: ""
    property color activeColor: Core.Theme.textPrimary
    property color inactiveColor: Core.Theme.textDisabled

    width: Core.Theme.iconSizeMedium
    height: Core.Theme.iconSizeMedium

    Text {
        anchors.centerIn: parent
        text: indicator.icon
        font.pixelSize: Core.Theme.iconSizeMedium - 4
        opacity: indicator.active ? 1.0 : 0.3
        color: indicator.active ? indicator.activeColor : indicator.inactiveColor

        Behavior on opacity {
            NumberAnimation { duration: Core.Theme.animationNormal }
        }
    }

    MouseArea {
        anchors.fill: parent
        onPressAndHold: {
            if (indicator.tooltip !== "") {
                tooltipPopup.open()
            }
        }
    }

    // Simple tooltip (shown on long press)
    Rectangle {
        id: tooltipPopup
        visible: false
        width: tooltipText.width + Core.Theme.spacingSmall * 2
        height: tooltipText.height + Core.Theme.spacingXS * 2
        color: Core.Theme.surface
        border.color: Core.Theme.divider
        radius: 4
        anchors.bottom: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: Core.Theme.spacingXS

        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: indicator.tooltip
            color: Core.Theme.textPrimary
            font.pixelSize: Core.Theme.captionSize
        }

        function open() {
            visible = true
            hideTimer.restart()
        }

        Timer {
            id: hideTimer
            interval: 2000
            onTriggered: tooltipPopup.visible = false
        }
    }
}
