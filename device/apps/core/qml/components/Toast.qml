import QtQuick 2.15
import ".." as Core

Rectangle {
    id: toast

    property string message: ""
    property int duration: 3000
    property string position: "bottom"  // bottom | top
    property string actionText: ""

    signal actionClicked()

    visible: false
    color: Core.Theme.surface
    border.color: Core.Theme.divider
    radius: Core.Theme.borderRadiusLarge
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined

    // Position based on property
    anchors.bottom: position === "bottom" && parent ? parent.bottom : undefined
    anchors.top: position === "top" && parent ? parent.top : undefined
    anchors.bottomMargin: position === "bottom" ? Core.Theme.spacingLarge : 0
    anchors.topMargin: position === "top" ? Core.Theme.spacingLarge : 0

    width: Math.min(
        Math.max(contentRow.implicitWidth + Core.Theme.spacingLarge * 2, 200),
        parent ? parent.width - Core.Theme.spacingLarge * 2 : 320
    )
    height: Core.Theme.touchTargetLarge

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: Core.Theme.spacingMedium

        Text {
            id: msg
            text: toast.message
            color: Core.Theme.textPrimary
            font.pixelSize: Core.Theme.bodySize
            anchors.verticalCenter: parent.verticalCenter
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
            maximumLineCount: 1
        }

        // Action button (optional)
        Text {
            visible: toast.actionText !== ""
            text: toast.actionText.toUpperCase()
            color: Core.Theme.accent
            font.pixelSize: Core.Theme.bodySize
            font.weight: Core.Theme.fontWeightBold
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                anchors.margins: -Core.Theme.spacingSmall
                onClicked: {
                    toast.actionClicked()
                    hide()
                }
            }
        }
    }

    function show(text, actionLabel) {
        toast.message = text
        toast.actionText = actionLabel || ""
        toast.visible = true
        toast.opacity = 1.0
        timer.restart()
    }

    function hide() {
        hideAnimation.start()
    }

    Timer {
        id: timer
        interval: toast.duration
        onTriggered: hide()
    }

    // Fade in animation
    opacity: 0
    Behavior on opacity {
        NumberAnimation { duration: Core.Theme.animationNormal }
    }

    // Slide + fade out
    SequentialAnimation {
        id: hideAnimation
        NumberAnimation {
            target: toast
            property: "opacity"
            to: 0
            duration: Core.Theme.animationNormal
        }
        ScriptAction {
            script: toast.visible = false
        }
    }

    // Swipe to dismiss
    MouseArea {
        anchors.fill: parent
        drag.target: toast
        drag.axis: Drag.YAxis
        drag.minimumY: position === "bottom" ? 0 : -toast.height
        drag.maximumY: position === "bottom" ? toast.height : 0

        onReleased: {
            if (Math.abs(toast.y) > toast.height / 2) {
                hide()
            } else {
                toast.y = 0
            }
        }
    }
}
