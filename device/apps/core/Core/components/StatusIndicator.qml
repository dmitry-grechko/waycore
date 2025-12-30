import QtQuick 2.15
import ".." as Core

Item {
    id: indicator

    // Primary properties
    property string status: "inactive"  // active | inactive | success | warning | error
    property int size: Core.Theme.iconSizeMedium

    // Legacy properties for backward compatibility
    property string icon: ""
    property bool active: status === "active" || status === "success"
    property string tooltip: ""
    property color activeColor: Core.Theme.textPrimary
    property color inactiveColor: Core.Theme.textDisabled

    width: size
    height: size

    // Determine color based on status
    readonly property color statusColor: {
        switch(status) {
            case "active": return Core.Theme.success
            case "success": return Core.Theme.success
            case "warning": return Core.Theme.warning
            case "error": return Core.Theme.error
            default: return Core.Theme.textSecondary
        }
    }

    // Simple dot indicator (when no icon is set)
    Rectangle {
        visible: indicator.icon === ""
        anchors.centerIn: parent
        width: indicator.size
        height: indicator.size
        radius: indicator.size / 2
        color: indicator.statusColor
        opacity: indicator.status === "inactive" ? 0.4 : 1.0

        // Pulse animation for active status
        SequentialAnimation on opacity {
            running: indicator.status === "active"
            loops: Animation.Infinite
            NumberAnimation { to: 0.4; duration: 1000 }
            NumberAnimation { to: 1.0; duration: 1000 }
        }
    }

    // Icon indicator (when icon is set)
    Text {
        visible: indicator.icon !== ""
        anchors.centerIn: parent
        text: indicator.icon
        font.pixelSize: indicator.size - 4
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
