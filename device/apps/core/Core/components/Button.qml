import QtQuick 2.15
import QtQuick.Layouts 1.15
import ".." as Core
import "." as Components

Rectangle {
    id: btn

    property string text: ""
    property string variant: "contained" // contained | outlined | text | secondary | danger | ghost | primary | tactical | tacticalSecondary
    property bool enabled: true
    property string icon: ""        // Emoji icon (legacy)
    property string iconName: ""    // Material icon name
    property bool loading: false
    property bool fullWidth: false
    property string size: "medium"  // small | medium | large

    signal clicked()

    height: size === "small" ? Core.Theme.touchTargetSmall : (size === "large" ? Core.Theme.touchTargetLarge : Core.Theme.buttonHeight)
    implicitWidth: contentRow.implicitWidth + Core.Theme.spacingLarge * 2
    Layout.fillWidth: fullWidth
    radius: Core.Theme.borderRadius
    opacity: enabled ? 1.0 : 0.5

    color: {
        if (!enabled) return Core.Theme.disabled
        if (variant === "contained" || variant === "primary") {
            return mouseArea.pressed ? Core.Theme.primaryDark : Core.Theme.primary
        }
        if (variant === "tactical") {
            return mouseArea.pressed ? Qt.darker(Core.Theme.warning, 1.1) : Core.Theme.warning
        }
        if (variant === "tacticalSecondary") {
            return mouseArea.pressed ? Core.Theme.surfaceHighlight : Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.2)
        }
        if (variant === "secondary") {
            return mouseArea.pressed ? Core.Theme.surfaceHighlight : Core.Theme.surfaceElevated
        }
        if (variant === "danger") {
            return mouseArea.pressed ? Qt.darker(Core.Theme.error, 1.2) : Core.Theme.error
        }
        if (variant === "ghost") {
            return mouseArea.pressed ? Core.Theme.surfaceHighlight : "transparent"
        }
        if (mouseArea.pressed) return Core.Theme.surfaceHighlight
        return "transparent"
    }

    border.color: {
        if (variant === "outlined") return Core.Theme.primaryLight
        if (variant === "secondary") return Core.Theme.divider
        if (variant === "tacticalSecondary") {
            // Hover shows accent border, otherwise divider
            return mouseArea.containsMouse ? Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.5) : Core.Theme.divider
        }
        if (variant === "danger") return Core.Theme.error
        return "transparent"
    }
    border.width: (variant === "outlined" || variant === "secondary" || variant === "tacticalSecondary") ? 1 : 0

    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: Core.Theme.spacingSmall

        // Loading indicator
        Rectangle {
            visible: btn.loading
            width: Core.Theme.iconSizeMedium
            height: Core.Theme.iconSizeMedium
            radius: width / 2
            color: "transparent"
            border.color: Core.Theme.textPrimary
            border.width: 2
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                width: parent.width / 2
                height: parent.height / 2
                color: Core.Theme.textPrimary
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
            }

            RotationAnimator on rotation {
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
                running: btn.loading
            }
        }

        // Material Icon
        Components.MaterialIcon {
            visible: btn.iconName !== "" && !btn.loading
            name: btn.iconName
            size: btn.size === "small" ? Core.Theme.iconSizeSmall : Core.Theme.iconSizeMedium
            iconColor: {
                if (variant === "tactical") return Core.Theme.background
                if (variant === "tacticalSecondary") {
                    return mouseArea.containsMouse ? Core.Theme.textPrimary : Core.Theme.textSecondary
                }
                return Core.Theme.textPrimary
            }
            anchors.verticalCenter: parent.verticalCenter
        }

        // Emoji Icon (legacy)
        Text {
            visible: btn.icon !== "" && btn.iconName === "" && !btn.loading
            text: btn.icon
            font.pixelSize: Core.Theme.iconSizeMedium
            anchors.verticalCenter: parent.verticalCenter
        }

        // Label
        Text {
            visible: !btn.loading
            text: btn.text.toUpperCase()
            color: {
                if (variant === "tactical") return Core.Theme.background
                if (variant === "tacticalSecondary") {
                    return mouseArea.containsMouse ? Core.Theme.textPrimary : Core.Theme.textSecondary
                }
                return Core.Theme.textPrimary
            }
            font.pixelSize: size === "small" ? Core.Theme.smallSize : Core.Theme.bodySize
            font.weight: Core.Theme.fontWeightBold
            font.letterSpacing: 1
            font.family: Core.Theme.fontFamilyMono
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: btn.enabled && !btn.loading
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }

    // Press animation for tactical variants
    scale: (variant === "tactical" || variant === "tacticalSecondary") && mouseArea.pressed ? 0.98 : 1.0

    Behavior on scale {
        NumberAnimation { duration: 100 }
    }

    Behavior on color {
        ColorAnimation { duration: Core.Theme.animationFast }
    }

    Behavior on opacity {
        NumberAnimation { duration: Core.Theme.animationFast }
    }
}
