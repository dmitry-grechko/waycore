import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * MeshChat - Channel Chat screen with tactical design
 */
Rectangle {
    id: meshChat
    color: Core.Theme.background

    // Chat state
    property bool isConnected: false
    property string channelName: "LongFast"
    property int onlineNodeCount: 0

    // Use ListModel for proper QML reactivity
    ListModel {
        id: messagesModel
    }

    Component.onCompleted: {
        refreshMessages()
        refreshStatus()
    }

    function refreshMessages() {
        messagesModel.clear()
        var msgArray = []

        if (typeof MeshBridge !== "undefined" && MeshBridge) {
            var result = MeshBridge.getMessages(50)
            if (result && result.messages) {
                // Ensure all properties are defined
                for (var i = 0; i < result.messages.length; i++) {
                    var msg = result.messages[i]
                    msgArray.push({
                        id: msg.id || "",
                        from_node: msg.from_node || "",
                        from_name: msg.from_name || "",
                        text: msg.text || "",
                        timestamp: msg.timestamp || "",
                        is_mine: msg.is_mine || false,
                        is_system: msg.is_system || false,
                        delivery_status: msg.delivery_status || ""
                    })
                }
            }
        } else {
            // Mock data for development - all properties defined
            msgArray = [
                { id: "1", from_node: "!a1b2c3d4", from_name: "KILO-1", text: "Radio check. We've established a perimeter at the northern ridge. Anyone copying?", timestamp: new Date(Date.now() - 300000).toISOString(), is_mine: false, is_system: false, delivery_status: "" },
                { id: "2", from_node: "!00000001", from_name: "WAYC", text: "Solid copy, Kilo-1. Signal strength is good. Proceed to waypoint Charlie.", timestamp: new Date(Date.now() - 180000).toISOString(), is_mine: true, is_system: false, delivery_status: "delivered" },
                { id: "3", from_node: "!b2c3d4e5", from_name: "ROVER-2", text: "Interference detected in sector 4. Moving to higher ground for better LOS.", timestamp: new Date(Date.now() - 120000).toISOString(), is_mine: false, is_system: false, delivery_status: "" },
                { id: "4", from_node: "!00000001", from_name: "WAYC", text: "Understood. Keep us posted on battery levels.", timestamp: new Date(Date.now() - 60000).toISOString(), is_mine: true, is_system: false, delivery_status: "pending" },
                { id: "5", from_node: "system", from_name: "SYSTEM", text: "Node ROVER-2 lost connection.", timestamp: new Date().toISOString(), is_mine: false, is_system: true, delivery_status: "" }
            ]
        }

        for (var j = 0; j < msgArray.length; j++) {
            messagesModel.append(msgArray[j])
        }
    }

    function refreshStatus() {
        if (typeof MeshBridge !== "undefined" && MeshBridge) {
            var status = MeshBridge.getStatus()
            if (status) {
                isConnected = status.connected !== undefined ? status.connected : true
                channelName = status.channel_name || "LongFast"
                onlineNodeCount = status.nodes ? status.nodes.online : 0
            }
        } else {
            isConnected = true
            channelName = "LongFast"
            onlineNodeCount = 12
        }
    }

    function sendMessage(text) {
        if (!text.trim()) return

        if (typeof MeshBridge !== "undefined" && MeshBridge) {
            var result = MeshBridge.sendMessage(text)
            if (result && result.success) {
                messageInput.text = ""
                refreshMessages()
            }
        } else {
            messagesModel.append({
                id: "mock_" + Date.now(),
                from_node: "!00000001",
                from_name: "WAYC",
                text: text,
                timestamp: new Date().toISOString(),
                is_mine: true,
                is_system: false,
                delivery_status: "pending"
            })
            messageInput.text = ""
        }
        messageList.positionViewAtEnd()
    }

    function navigateToNodes() {
        var p = meshChat.parent
        while (p && !p.navigateTo) p = p.parent
        if (p) p.navigateTo("MeshNodes")
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            refreshMessages()
            refreshStatus()
        }
    }

    Core.TacticalBackground { anchors.fill: parent; z: 0 }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        z: 10

        // Header using PageHeader pattern
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Core.Theme.appBarHeight

            Core.PageHeader {
                anchors.fill: parent
                title: channelName
                subtitle: onlineNodeCount + " Nodes Online"
                showBack: true
                rightIcon: "account-group"
                onBackClicked: {
                    var p = meshChat.parent
                    while (p && !p.navigateBack) p = p.parent
                    if (p) p.navigateBack()
                }
                onRightClicked: navigateToNodes()
            }
        }

        // Message list
        ListView {
            id: messageList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Core.Theme.spacingMedium
            clip: true
            spacing: 12
            verticalLayoutDirection: ListView.TopToBottom

            model: messagesModel

            delegate: Item {
                width: messageList.width
                height: contentCol.height

                property bool isMine: model.is_mine || model.from_node === "!00000001"
                property bool isSystem: model.is_system || model.from_node === "system"

                Column {
                    id: contentCol
                    width: parent.width
                    spacing: 4

                    // Sender info (received messages only)
                    Row {
                        visible: !isMine && !isSystem
                        spacing: 8

                        Text {
                            text: model.from_name || model.from_node
                            color: getSenderColor(model.from_name)
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            font.family: Core.Theme.fontFamilyMono

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var p = meshChat.parent
                                    while (p && !p.openConversation) p = p.parent
                                    if (p) p.openConversation(model.from_node)
                                }
                            }
                        }
                        Text {
                            text: formatTime(model.timestamp)
                            color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.5)
                            font.pixelSize: 10
                            font.family: Core.Theme.fontFamilyMono
                        }
                    }

                    // System message
                    Rectangle {
                        visible: isSystem
                        width: sysContent.width + 16
                        height: sysContent.height + 12
                        color: Qt.rgba(0, 0, 0, 0.4)
                        border.color: Core.Theme.divider
                        border.width: 1
                        radius: 8
                        opacity: 0.6

                        Row {
                            id: sysContent
                            anchors.centerIn: parent
                            spacing: 8

                            Core.MaterialIcon {
                                name: "alert"
                                size: 14
                                iconColor: Core.Theme.warning
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: model.text
                                color: Core.Theme.textSecondary
                                font.pixelSize: 12
                                font.family: Core.Theme.fontFamilyMono
                            }
                        }
                    }

                    // Regular message bubble - aligned left or right
                    Rectangle {
                        id: bubble
                        visible: !isSystem
                        anchors.left: isMine ? undefined : parent.left
                        anchors.right: isMine ? parent.right : undefined
                        width: Math.min(parent.width * 0.85, msgText.implicitWidth + 24)
                        height: msgText.height + 24
                        color: isMine ? Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3) : Core.Theme.tacticalCard
                        border.color: Core.Theme.divider
                        border.width: 1
                        radius: 8

                        // Small corner for sent messages (top-right)
                        Rectangle {
                            visible: isMine
                            anchors.top: parent.top
                            anchors.right: parent.right
                            width: 4; height: 4
                            color: parent.color
                        }
                        // Small corner for received messages (top-left)
                        Rectangle {
                            visible: !isMine
                            anchors.top: parent.top
                            anchors.left: parent.left
                            width: 4; height: 4
                            color: parent.color
                        }

                        Text {
                            id: msgText
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.margins: 12
                            width: Math.min(implicitWidth, parent.parent.width * 0.85 - 24)
                            text: model.text
                            color: isMine ? "#FFFFFF" : "#E5E7EB"
                            font.pixelSize: 14
                            wrapMode: Text.WordWrap
                            lineHeight: 1.4
                        }
                    }

                    // Timestamp for sent messages (below bubble, right-aligned)
                    Row {
                        visible: isMine && !isSystem
                        anchors.right: parent.right
                        spacing: 4
                        opacity: 0.8

                        Text {
                            text: formatTime(model.timestamp)
                            color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.5)
                            font.pixelSize: 10
                            font.family: Core.Theme.fontFamilyMono
                        }

                        // Delivery status icon (using text for reliability at small sizes)
                        Text {
                            text: model.delivery_status === "delivered" ? "✓✓" : (model.delivery_status === "pending" ? "◷" : "✓")
                            color: model.delivery_status === "delivered" ? Core.Theme.success : Core.Theme.textSecondary
                            font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            Text {
                visible: messagesModel.count === 0
                anchors.centerIn: parent
                text: "No messages yet\n\nSend a message to start!"
                color: Core.Theme.textSecondary
                font.pixelSize: Core.Theme.bodySize
                horizontalAlignment: Text.AlignHCenter
            }

            onCountChanged: positionViewAtEnd()
        }

        // Input footer
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            color: Qt.rgba(Core.Theme.background.r, Core.Theme.background.g, Core.Theme.background.b, 0.95)

            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: Core.Theme.divider
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: Core.Theme.spacingMedium
                spacing: Core.Theme.spacingSmall

                // Input field
                Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    radius: 8
                    color: Core.Theme.background
                    border.color: messageInput.activeFocus ? Core.Theme.primary : Core.Theme.divider
                    border.width: 1

                    TextInput {
                        id: messageInput
                        anchors.fill: parent
                        anchors.margins: 12
                        verticalAlignment: TextInput.AlignVCenter
                        color: Core.Theme.textPrimary
                        font.pixelSize: 14
                        font.family: Core.Theme.fontFamilyMono
                        clip: true

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            text: "Broadcast to " + channelName + "..."
                            color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.3)
                            font: messageInput.font
                            visible: !messageInput.text && !messageInput.activeFocus
                        }

                        Keys.onReturnPressed: sendMessage(text)
                    }
                }

                // Send button (icon only)
                Rectangle {
                    width: 44
                    height: 44
                    radius: 8
                    color: sendMouse.pressed ? Qt.darker(Core.Theme.primary, 1.1) : Core.Theme.primary
                    border.color: Qt.rgba(Core.Theme.primary.r, Core.Theme.primary.g, Core.Theme.primary.b, 0.5)

                    Core.MaterialIcon {
                        anchors.centerIn: parent
                        name: "send"
                        size: 20
                        iconColor: Core.Theme.textPrimary
                    }

                    MouseArea {
                        id: sendMouse
                        anchors.fill: parent
                        onClicked: sendMessage(messageInput.text)
                    }
                }
            }
        }
    }

    function formatTime(isoString) {
        if (!isoString) return ""
        var date = new Date(isoString)
        var hours = date.getHours().toString().padStart(2, '0')
        var mins = date.getMinutes().toString().padStart(2, '0')
        return hours + ":" + mins
    }

    function getSenderColor(name) {
        if (!name) return Core.Theme.warning
        var colors = ["#D4A574", "#60A5FA", "#34D399", "#F472B6", "#A78BFA"]
        var hash = 0
        for (var i = 0; i < name.length; i++) {
            hash = name.charCodeAt(i) + ((hash << 5) - hash)
        }
        return colors[Math.abs(hash) % colors.length]
    }
}
