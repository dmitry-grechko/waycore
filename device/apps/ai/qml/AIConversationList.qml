import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

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
        if (AIBridge) {
            conversations = AIBridge.getConversations()
        } else {
            // Mock data
            conversations = [
                { id: 1, title: "Hello conversation", model_id: "phi3-mini", message_count: 4, updated_at: new Date().toISOString() },
                { id: 2, title: "What is the weather?", model_id: "phi3-mini", message_count: 2, updated_at: new Date(Date.now() - 3600000).toISOString() },
            ]
        }
    }

    // Listen to AIBridge signals
    Connections {
        target: AIBridge || null

        function onConversationsChanged() {
            loadConversations()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header bar
        Rectangle {
            Layout.fillWidth: true
            height: 56
            color: Core.Theme.surface

            RowLayout {
                anchors.fill: parent
                anchors.margins: Core.Theme.spacingSmall
                spacing: Core.Theme.spacingSmall

                Button {
                    text: "←"
                    font.pixelSize: 20
                    onClicked: closeRequested()
                }

                Text {
                    Layout.fillWidth: true
                    text: "🤖 Chat History"
                    color: Core.Theme.textPrimary
                    font.pixelSize: Core.Theme.h2Size
                    font.bold: true
                }

                Button {
                    text: "➕ New"
                    onClicked: {
                        newChatRequested()
                    }

                    background: Rectangle {
                        color: Core.Theme.primary
                        radius: 4
                    }

                    contentItem: Text {
                        text: "➕ New"
                        color: "#FFFFFF"
                        font.pixelSize: Core.Theme.bodySize
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Core.Theme.divider
        }

        // Conversation list
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 1

            model: conversations

            delegate: Rectangle {
                width: listView.width
                height: 72
                color: mouseArea.containsMouse ? Core.Theme.surfaceElevated : Core.Theme.surface

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Core.Theme.spacingMedium
                    spacing: Core.Theme.spacingMedium

                    // Conversation icon
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: Core.Theme.primary

                        Text {
                            anchors.centerIn: parent
                            text: "💬"
                            font.pixelSize: 20
                        }
                    }

                    // Conversation info
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            Layout.fillWidth: true
                            text: modelData.title || "New Chat"
                            color: Core.Theme.textPrimary
                            font.pixelSize: Core.Theme.bodySize
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        RowLayout {
                            spacing: Core.Theme.spacingSmall

                            Text {
                                text: modelData.message_count + " messages"
                                color: Core.Theme.textSecondary
                                font.pixelSize: Core.Theme.captionSize
                            }

                            Text {
                                text: "•"
                                color: Core.Theme.textSecondary
                                font.pixelSize: Core.Theme.captionSize
                            }

                            Text {
                                text: formatRelativeTime(modelData.updated_at)
                                color: Core.Theme.textSecondary
                                font.pixelSize: Core.Theme.captionSize
                            }
                        }
                    }

                    // Delete button
                    Button {
                        text: "🗑️"
                        font.pixelSize: 16
                        onClicked: {
                            deleteDialog.conversationId = modelData.id
                            deleteDialog.conversationTitle = modelData.title || "New Chat"
                            deleteDialog.open()
                        }

                        background: Rectangle {
                            color: "transparent"
                        }
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

                // Bottom border
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: Core.Theme.divider
                }
            }

            // Empty state
            Column {
                visible: conversations.length === 0
                anchors.centerIn: parent
                spacing: Core.Theme.spacingMedium

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "💬"
                    font.pixelSize: 64
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "No Conversations"
                    color: Core.Theme.textPrimary
                    font.pixelSize: Core.Theme.h2Size
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Start a new chat to begin!"
                    color: Core.Theme.textSecondary
                    font.pixelSize: Core.Theme.bodySize
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "➕ New Chat"
                    onClicked: newChatRequested()

                    background: Rectangle {
                        color: Core.Theme.primary
                        radius: 8
                    }

                    contentItem: Text {
                        text: "➕ New Chat"
                        color: "#FFFFFF"
                        font.pixelSize: Core.Theme.bodySize
                        horizontalAlignment: Text.AlignHCenter
                        leftPadding: Core.Theme.spacingMedium
                        rightPadding: Core.Theme.spacingMedium
                    }
                }
            }
        }
    }

    // Delete confirmation dialog
    Dialog {
        id: deleteDialog
        title: "Delete Conversation"
        modal: true
        anchors.centerIn: parent
        width: 280

        property int conversationId: 0
        property string conversationTitle: ""

        background: Rectangle {
            color: Core.Theme.surface
            radius: 12
        }

        contentItem: ColumnLayout {
            spacing: Core.Theme.spacingMedium

            Text {
                text: "Delete \"" + deleteDialog.conversationTitle + "\"?"
                color: Core.Theme.textPrimary
                font.pixelSize: Core.Theme.bodySize
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Text {
                text: "This action cannot be undone."
                color: Core.Theme.textSecondary
                font.pixelSize: Core.Theme.captionSize
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Core.Theme.spacingSmall

                Button {
                    text: "Cancel"
                    Layout.fillWidth: true
                    onClicked: deleteDialog.close()
                }

                Button {
                    text: "Delete"
                    Layout.fillWidth: true
                    onClicked: {
                        if (AIBridge) {
                            AIBridge.deleteConversation(deleteDialog.conversationId)
                        }
                        deleteDialog.close()
                    }

                    background: Rectangle {
                        color: Core.Theme.error
                        radius: 4
                    }

                    contentItem: Text {
                        text: "Delete"
                        color: "#FFFFFF"
                        font.pixelSize: Core.Theme.bodySize
                        horizontalAlignment: Text.AlignHCenter
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

        if (minutes < 1) return "Just now"
        if (minutes < 60) return minutes + "m ago"
        if (hours < 24) return hours + "h ago"
        if (days < 7) return days + "d ago"

        return date.toLocaleDateString()
    }
}
