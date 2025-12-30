import QtQuick 2.15
import ".." as Core

/**
 * Icon - Emoji or text-based icon display
 *
 * Provides consistent icon rendering with size presets and
 * automatic color inheritance from the theme.
 *
 * Usage:
 *   Core.Icon {
 *       name: "🧭"
 *       size: "large"
 *       color: Core.Theme.accent
 *   }
 */
Text {
    id: icon

    property string name: ""
    property string size: "medium"  // small | medium | large | xl
    property color iconColor: Core.Theme.textPrimary

    text: name
    color: iconColor
    font.pixelSize: sizeValue

    readonly property int sizeValue: {
        switch(size) {
            case "small": return Core.Theme.iconSizeSmall
            case "large": return Core.Theme.iconSizeLarge
            case "xl": return Core.Theme.iconSizeXL
            default: return Core.Theme.iconSizeMedium
        }
    }
}
