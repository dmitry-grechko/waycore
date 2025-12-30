import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * AIConversationList - Tactical-styled AI chat history view (modular app)
 */
Rectangle {
    id: conversationList
    color: Core.Theme.background

    property var conversations: []

    signal conversationSelected(int conversationId)
    signal newChatRequested()
    signal closeRequested()

    Component.onCompleted: {
        loadConversations()
    }

    function loadConversations() {
        if (typeof AIBridge !== "undefined" && AIBridge) {
            conversations = AIBridge.getConversations()
        } else {
            // Mock data
            conversations = [
                { id: 1, title: "Field operations query", model_id: "phi3-mini", message_count: 4, updated_at: new Date().toISOString() },
                { id: 2, title: "Weather analysis", model_id: "phi3-mini", message_count: 2, updated_at: new Date(Date.now() - 3600000).toISOString() },
                { id: 3, title: "Navigation assistance", model_id: "phi3-mini", message_count: 8, updated_at: new Date(Date.now() - 86400000).toISOString() },
            ]
        }
    }

    // Listen to AIBridge signals
    Connections {
        target: typeof AIBridge !== "undefined" ? AIBridge : null
        enabled: typeof AIBridge !== "undefined" && AIBridge !== null

        function onConversationsChanged() {
            loadConversations()
        }
    }

    // Tactical background
    Core.TacticalBackground {
        anchors.fill: parent
        z: 0
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        z: 10

        // Header
        Rectangle {
            Layout.fillWidth: true
            height: Core.Theme.appBarHeight
            color: Qt.rgba(Core.Theme.background.r, Core.Theme.background.g, Core.Theme.background.b, 0.95)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Core.Theme.spacingSmall
                anchors.rightMargin: Core.Theme.spacingSmall
                spacing: Core.Theme.spacingSmall

                // Back button
                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: backArea.containsMouse ? Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.5) : "transparent"
                    Layout.alignment: Qt.AlignVCenter

                    Core.MaterialIcon {
                        anchors.centerIn: parent
                        name: "arrow-left"
                        size: 24
                        iconColor: backArea.containsMouse ? Core.Theme.textPrimary : Core.Theme.textSecondary
                    }

                    MouseArea {
                        id: backArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: closeRequested()
                    }
                }

                // Title
                Column {
                    Layout.fillWidth: true
                    spacing: 2

                    Row {
                        spacing: 8

                        Text {
                            text: "🤖"
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "CHAT HISTORY"
                            color: Core.Theme.textPrimary
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            font.letterSpacing: 2
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        text: conversations.length + " CONVERSATIONS"
                        color: Core.Theme.textSecondary
                        font.pixelSize: 10
                        font.family: Core.Theme.fontFamilyMono
                        font.letterSpacing: 2
                    }
                }

                // New chat button
                Rectangle {
                    width: 36
                    height: 36
                    radius: Core.Theme.borderRadius
                    color: newChatBtnArea.containsMouse ? Core.Theme.primary : Core.Theme.surface
                    border.color: newChatBtnArea.containsMouse ? Core.Theme.primary : Core.Theme.divider
                    border.width: 1
                    Layout.alignment: Qt.AlignVCenter

                    Core.MaterialIcon {
                        anchors.centerIn: parent
                        name: "plus"
                        size: 20
                        iconColor: newChatBtnArea.containsMouse ? Core.Theme.textPrimary : Core.Theme.textSecondary
                    }

                    MouseArea {
                        id: newChatBtnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: newChatRequested()
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
            }
        }

        // Conversation list
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Core.Theme.spacingSmall
            clip: true
            spacing: Core.Theme.spacingSmall

            model: conversations

            delegate: Rectangle {
                width: listView.width
                height: 80
                color: mouseArea.containsMouse ? Core.Theme.surface : Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.3)
                radius: Core.Theme.borderRadius
                border.color: mouseArea.containsMouse ? Core.Theme.divider : Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
                border.width: 1

                Behavior on color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Core.Theme.spacingMedium
                    spacing: Core.Theme.spacingMedium

                    // Conversation icon
                    Rectangle {
                        width: 44
                        height: 44
                        radius: 12
                        color: Core.Theme.surface
                        border.color: Core.Theme.divider
                        border.width: 1

                        Core.MaterialIcon {
                            anchors.centerIn: parent
                            name: "message-text"
                            size: 22
                            iconColor: Core.Theme.primary
                        }
                    }

                    // Conversation info
                    Column {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            width: parent.width
                            text: (modelData.title || "New Chat").toUpperCase()
                            color: Core.Theme.textPrimary
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            font.letterSpacing: 1
                            elide: Text.ElideRight
                        }

                        Row {
                            spacing: Core.Theme.spacingSmall

                            Rectangle {
                                width: msgLabel.width + 12
                                height: 18
                                radius: 9
                                color: Qt.rgba(Core.Theme.primary.r, Core.Theme.primary.g, Core.Theme.primary.b, 0.2)

                                Text {
                                    id: msgLabel
                                    anchors.centerIn: parent
                                    text: modelData.message_count + " MSG"
                                    color: Core.Theme.primary
                                    font.pixelSize: 9
                                    font.family: Core.Theme.fontFamilyMono
                                    font.weight: Font.Bold
                                }
                            }

                            Text {
                                text: "•"
                                color: Core.Theme.textSecondary
                                font.pixelSize: 10
                                anchors.verticalCenter: parent.verticalCenter
                                opacity: 0.5
                            }

                            Text {
                                text: formatRelativeTime(modelData.updated_at)
                                color: Core.Theme.textSecondary
                                font.pixelSize: 10
                                font.family: Core.Theme.fontFamilyMono
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    // Delete button
                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: deleteBtnArea.containsMouse ? Qt.rgba(0.5, 0.1, 0.1, 0.3) : "transparent"
                        Layout.alignment: Qt.AlignVCenter

                        Core.MaterialIcon {
                            anchors.centerIn: parent
                            name: "delete"
                            size: 18
                            iconColor: deleteBtnArea.containsMouse ? Core.Theme.error : Core.Theme.textSecondary
                        }

                        MouseArea {
                            id: deleteBtnArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                deleteDialog.conversationId = modelData.id
                                deleteDialog.conversationTitle = modelData.title || "New Chat"
                                deleteDialog.visible = true
                            }
                        }
                    }

                    // Chevron
                    Core.MaterialIcon {
                        name: "chevron-right"
                        size: 20
                        iconColor: Core.Theme.textSecondary
                        opacity: 0.5
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        conversationSelected(modelData.id)
                    }
                }
            }

            // Empty state
            Column {
                visible: conversations.length === 0
                anchors.centerIn: parent
                spacing: Core.Theme.spacingMedium
                width: parent.width * 0.8
                opacity: 0.6

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 80
                    height: 80
                    radius: 20
                    color: Core.Theme.surface
                    border.color: Core.Theme.divider
                    border.width: 1

                    Core.MaterialIcon {
                        anchors.centerIn: parent
                        name: "message-text-outline"
                        size: 36
                        iconColor: Core.Theme.textSecondary
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "NO HISTORY"
                    color: Core.Theme.textPrimary
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    font.letterSpacing: 3
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Start a new conversation to begin\nchatting with the tactical AI."
                    color: Core.Theme.textSecondary
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    lineHeight: 1.4
                }

                Item { width: 1; height: 8 }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 160
                    height: 44
                    radius: Core.Theme.borderRadius
                    color: startNewArea.pressed ? Qt.darker(Core.Theme.primary, 1.1) : (startNewArea.containsMouse ? Core.Theme.primary : Core.Theme.surface)
                    border.color: startNewArea.containsMouse ? Core.Theme.primary : Core.Theme.divider
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        Core.MaterialIcon {
                            name: "plus"
                            size: 18
                            iconColor: Core.Theme.textPrimary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "NEW CHAT"
                            color: Core.Theme.textPrimary
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            font.letterSpacing: 1
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: startNewArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: newChatRequested()
                    }
                }
            }
        }
    }

    // Delete confirmation dialog
    Rectangle {
        id: deleteDialog
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.8)
        visible: false
        z: 100

        property int conversationId: 0
        property string conversationTitle: ""

        MouseArea {
            anchors.fill: parent
            onClicked: deleteDialog.visible = false
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.9
            height: deleteContent.height + 32
            color: Core.Theme.background
            border.color: Core.Theme.error
            border.width: 1
            radius: Core.Theme.borderRadius

            // Corner decorations
            Rectangle { anchors.top: parent.top; anchors.left: parent.left; width: 6; height: 2; color: Core.Theme.error }
            Rectangle { anchors.top: parent.top; anchors.left: parent.left; width: 2; height: 6; color: Core.Theme.error }
            Rectangle { anchors.top: parent.top; anchors.right: parent.right; width: 6; height: 2; color: Core.Theme.error }
            Rectangle { anchors.top: parent.top; anchors.right: parent.right; width: 2; height: 6; color: Core.Theme.error }
            Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; width: 6; height: 2; color: Core.Theme.error }
            Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; width: 2; height: 6; color: Core.Theme.error }
            Rectangle { anchors.bottom: parent.bottom; anchors.right: parent.right; width: 6; height: 2; color: Core.Theme.error }
            Rectangle { anchors.bottom: parent.bottom; anchors.right: parent.right; width: 2; height: 6; color: Core.Theme.error }

            Column {
                id: deleteContent
                anchors.centerIn: parent
                width: parent.width - 32
                spacing: 12

                Row {
                    spacing: 8

                    Core.MaterialIcon {
                        name: "alert"
                        size: 24
                        iconColor: Core.Theme.error
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "DELETE CONVERSATION?"
                        color: Core.Theme.textPrimary
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        font.letterSpacing: 2
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Text {
                    width: parent.width
                    text: "This will permanently delete \"" + deleteDialog.conversationTitle + "\" and all associated messages."
                    color: Core.Theme.textSecondary
                    font.pixelSize: 13
                    wrapMode: Text.WordWrap
                }

                Item { width: 1; height: 8 }

                RowLayout {
                    width: parent.width
                    spacing: 12

                    Rectangle {
                        Layout.fillWidth: true
                        height: 44
                        radius: Core.Theme.borderRadius
                        color: cancelDeleteArea.containsMouse ? Core.Theme.surface : "transparent"
                        border.color: Core.Theme.divider
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "CANCEL"
                            color: Core.Theme.textPrimary
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            font.letterSpacing: 1
                        }

                        MouseArea {
                            id: cancelDeleteArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: deleteDialog.visible = false
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 44
                        radius: Core.Theme.borderRadius
                        color: confirmDeleteArea.containsMouse ? Qt.rgba(0.5, 0.1, 0.1, 0.4) : Qt.rgba(0.3, 0.05, 0.05, 0.2)
                        border.color: Qt.rgba(0.5, 0.2, 0.2, 0.5)
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "DELETE"
                            color: Core.Theme.error
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            font.letterSpacing: 1
                        }

                        MouseArea {
                            id: confirmDeleteArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (typeof AIBridge !== "undefined" && AIBridge) {
                                    AIBridge.deleteConversation(deleteDialog.conversationId)
                                }
                                deleteDialog.visible = false
                            }
                        }
                    }
                }
            }
        }
    }

    // Helper function
    function formatRelativeTime(isoString) {
        if (!isoString) return ""
        var date = new Date(isoString)
        var now = new Date()
        var diff = now - date

        var minutes = Math.floor(diff / 60000)
        var hours = Math.floor(diff / 3600000)
        var days = Math.floor(diff / 86400000)

        if (minutes < 1) return "NOW"
        if (minutes < 60) return minutes + "M AGO"
        if (hours < 24) return hours + "H AGO"
        if (days < 7) return days + "D AGO"

        return date.toLocaleDateString().toUpperCase()
    }
}
