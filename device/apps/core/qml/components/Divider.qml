import QtQuick 2.15
import ".." as Core

Rectangle {
    id: divider

    property bool vertical: false
    property string variant: "full"  // full | inset | middle

    color: Core.Theme.divider
    width: vertical ? 1 : parent ? parent.width : 100
    height: vertical ? (parent ? parent.height : 100) : 1

    anchors.leftMargin: {
        if (!vertical) {
            switch(variant) {
                case "inset": return Core.Theme.spacingLarge
                case "middle": return Core.Theme.spacingLarge * 2
                default: return 0
            }
        }
        return 0
    }

    anchors.rightMargin: {
        if (!vertical) {
            switch(variant) {
                case "middle": return Core.Theme.spacingLarge * 2
                default: return 0
            }
        }
        return 0
    }
}
