import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * Direct Message Conversation with a specific node.
 *
 * Properties:
 *   - node_id: The node ID to have a conversation with
 */
Rectangle {
    id: meshConversation
    color: Core.Theme.background

    signal closeRequested()

    // Node we're chatting with
    property string node_id: ""
    property string node_name: ""
    property string node_alias: ""
    property bool is_favorite: false
    property bool is_online: false

    // Chat state
    property var messages: []

    Component.onCompleted: {
        loadNodeInfo()
        refreshMessages()
    }

    function loadNodeInfo() {
        console.log("MeshConversation: loading info for node", node_id)

        if (MeshBridge && node_id) {
            // Get node info from nodes list
            var nodesResult = MeshBridge.getNodesWithContacts()
            if (nodesResult && nodesResult.nodes) {
                for (var i = 0; i < nodesResult.nodes.length; i++) {
                    if (nodesResult.nodes[i].node_id === node_id) {
                        var node = nodesResult.nodes[i]
                        node_name = node.short_name || node.node_id
                        node_alias = node.alias || ""
                        is_favorite = node.is_favorite || false
                        is_online = node.status === "online"
                        break
                    }
                }
            }

            // Get contact info
            var contactResult = MeshBridge.getContact(node_id)
            if (contactResult && contactResult.contact) {
                node_alias = contactResult.contact.alias || ""
                is_favorite = contactResult.contact.is_favorite || false
            }
        } else {
            // Mock
            node_name = "ALPH"
            node_alias = "Alpha Team"
            is_favorite = true
            is_online = true
        }
    }

    function refreshMessages() {
        console.log("MeshConversation: refreshMessages for", node_id)

        if (MeshBridge && node_id) {
            var result = MeshBridge.getConversation(node_id, 100)
            console.log("MeshConversation: getConversation result =", JSON.stringify(result))
            if (result && result.messages) {
                messages = result.messages
                console.log("MeshConversation: loaded", messages.length, "messages")
            }
        } else {
            // Mock DM messages
            messages = [
                { id: "dm_1", from_node: node_id, text: "Hey, are you at the rally point?", timestamp: new Date(Date.now() - 60000).toISOString(), is_mine: false },
                { id: "dm_2", from_node: "!00000001", text: "Almost there, ETA 5 minutes", timestamp: new Date(Date.now() - 30000).toISOString(), is_mine: true },
                { id: "dm_3", from_node: node_id, text: "Copy that. See you soon.", timestamp: new Date().toISOString(), is_mine: false }
            ]
        }
    }

    function sendMessage(text) {
        if (!text.trim()) return

        // Show sending state
        sendButton.text = "..."
        sendButton.enabled = false

        if (MeshBridge) {
            var result = MeshBridge.sendDirectMessage(text, node_id)
            if (result && result.success) {
                messageInput.text = ""
                refreshMessages()
            }
        } else {
            // Mock: add to local list
            var newMsg = {
                id: "dm_" + Date.now(),
                from_node: "!00000001",
                to_node: node_id,
                text: text,
                timestamp: new Date().toISOString(),
                is_mine: true
            }
            messages = messages.concat([newMsg])
            messageInput.text = ""
        }

        // Reset button state
        sendButton.text = "Send"
        sendButton.enabled = messageInput.text.trim().length > 0

        // Scroll to bottom
        messageList.positionViewAtEnd()
    }

    function toggleFavorite() {
        if (MeshBridge) {
            var result = MeshBridge.toggleFavorite(node_id)
            if (result) {
                is_favorite = result.is_favorite || !is_favorite
            }
        } else {
            is_favorite = !is_favorite
        }
    }

    // Refresh timer
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: refreshMessages()
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

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: (node_alias || node_name || node_id)
                        color: Core.Theme.textPrimary
                        font.pixelSize: Core.Theme.h2Size
                        font.bold: true
                    }

                    RowLayout {
                        spacing: 4

                        // Online status indicator
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: is_online ? Core.Theme.success : Core.Theme.textSecondary
                        }

                        Text {
                            text: is_online ? "Online" : "Offline"
                            color: Core.Theme.textSecondary
                            font.pixelSize: Core.Theme.captionSize
                        }

                        Text {
                            visible: node_alias && node_name
                            text: " · " + node_name
                            color: Core.Theme.textSecondary
                            font.pixelSize: Core.Theme.captionSize
                        }
                    }
                }

                // Favorite button
                Button {
                    text: is_favorite ? "★" : "☆"
                    font.pixelSize: 20
                    onClicked: toggleFavorite()
                }

                // Info button - navigate to node details
                Button {
                    text: "ⓘ"
                    font.pixelSize: 18
                    onClicked: {
                        var shell = meshConversation.parent
                        while (shell && !shell.hasOwnProperty("navigateTo")) {
                            shell = shell.parent
                        }
                        if (shell && shell.navigateTo) {
                            shell.navigateTo("MeshNodeDetails", { node_id: node_id })
                        }
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

        // Encryption badge
        Rectangle {
            Layout.fillWidth: true
            height: 28
            color: Qt.rgba(Core.Theme.primary.r, Core.Theme.primary.g, Core.Theme.primary.b, 0.1)

            Text {
                anchors.centerIn: parent
                text: "🔒 Direct messages are encrypted point-to-point"
                color: Core.Theme.primary
                font.pixelSize: Core.Theme.captionSize
            }
        }

        // Message list
        ListView {
            id: messageList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: Core.Theme.spacingSmall
            verticalLayoutDirection: ListView.TopToBottom

            model: messages

            delegate: Item {
                width: messageList.width
                height: messageBubble.height + Core.Theme.spacingSmall

                property bool isMine: modelData.is_mine || modelData.from_node === "!00000001"

                Rectangle {
                    id: messageBubble
                    width: Math.min(parent.width * 0.8, messageContent.implicitWidth + 24)
                    height: messageContent.implicitHeight + 16
                    radius: 12
                    color: isMine ? Core.Theme.primary : Core.Theme.surface
                    anchors.right: isMine ? parent.right : undefined
                    anchors.left: isMine ? undefined : parent.left
                    anchors.margins: Core.Theme.spacingSmall

                    ColumnLayout {
                        id: messageContent
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 4

                        // Message text
                        Text {
                            text: modelData.text
                            color: isMine ? "#FFFFFF" : Core.Theme.textPrimary
                            font.pixelSize: Core.Theme.bodySize
                            wrapMode: Text.WordWrap
                            Layout.maximumWidth: messageList.width * 0.75
                        }

                        // Timestamp and delivery status
                        RowLayout {
                            Layout.alignment: Qt.AlignRight
                            spacing: 4

                            Text {
                                text: formatTime(modelData.timestamp)
                                color: isMine ? "#CCCCCC" : Core.Theme.textSecondary
                                font.pixelSize: 10
                            }

                            // Delivery status icon (for sent messages)
                            Text {
                                visible: isMine
                                text: getDeliveryIcon(modelData.delivery_status)
                                color: getDeliveryColor(modelData.delivery_status)
                                font.pixelSize: 12
                            }
                        }
                    }
                }
            }

            // Empty state
            Text {
                visible: messages.length === 0
                anchors.centerIn: parent
                text: "No messages yet\n\nStart a private conversation!"
                color: Core.Theme.textSecondary
                font.pixelSize: Core.Theme.bodySize
                horizontalAlignment: Text.AlignHCenter
            }

            // Scroll to bottom on new messages
            onCountChanged: {
                positionViewAtEnd()
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Core.Theme.divider
        }

        // Offline warning
        Rectangle {
            Layout.fillWidth: true
            height: !is_online ? 32 : 0
            visible: !is_online
            color: Core.Theme.warning

            Text {
                anchors.centerIn: parent
                text: "⚠️ Node is offline - message will be delivered when online"
                color: "#000000"
                font.pixelSize: Core.Theme.captionSize
            }

            Behavior on height { NumberAnimation { duration: 200 } }
        }

        // Input bar
        Rectangle {
            Layout.fillWidth: true
            height: 60
            color: Core.Theme.surface

            RowLayout {
                anchors.fill: parent
                anchors.margins: Core.Theme.spacingSmall
                spacing: Core.Theme.spacingSmall

                TextField {
                    id: messageInput
                    Layout.fillWidth: true
                    placeholderText: "Message " + (node_alias || node_name || "...")
                    font.pixelSize: Core.Theme.bodySize

                    Keys.onReturnPressed: {
                        sendMessage(text)
                    }
                }

                Button {
                    id: sendButton
                    text: "Send"
                    enabled: messageInput.text.trim().length > 0
                    onClicked: {
                        sendMessage(messageInput.text)
                    }
                }
            }
        }
    }

    // Helper function to format timestamp
    function formatTime(isoString) {
        if (!isoString) return ""
        var date = new Date(isoString)
        var hours = date.getHours().toString().padStart(2, '0')
        var mins = date.getMinutes().toString().padStart(2, '0')
        return hours + ":" + mins
    }

    // Delivery status icon
    function getDeliveryIcon(status) {
        switch (status) {
            case "pending": return "⏳"
            case "sending": return "⏳"
            case "sent": return "✓"
            case "delivered": return "✓✓"
            case "failed": return "❌"
            default: return "✓"
        }
    }

    // Delivery status color
    function getDeliveryColor(status) {
        switch (status) {
            case "pending": return "#AAAAAA"
            case "sending": return "#AAAAAA"
            case "sent": return "#CCCCCC"
            case "delivered": return "#88FF88"
            case "failed": return Core.Theme.error
            default: return "#CCCCCC"
        }
    }
}
