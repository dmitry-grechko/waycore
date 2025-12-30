import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * MeshConversation - Direct Message screen with tactical design
 */
Rectangle {
    id: meshConversation
    color: Core.Theme.background

    property string node_id: ""
    property string node_name: ""
    property string node_alias: ""
    property bool is_favorite: false
    property bool is_online: false

    ListModel {
        id: messagesModel
    }

    Component.onCompleted: {
        loadNodeInfo()
        refreshMessages()
    }

    function loadNodeInfo() {
        if (typeof MeshBridge !== "undefined" && MeshBridge && node_id) {
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

            var contactResult = MeshBridge.getContact(node_id)
            if (contactResult && contactResult.contact) {
                node_alias = contactResult.contact.alias || ""
                is_favorite = contactResult.contact.is_favorite || false
            }
        } else {
            node_name = "RANGER-Alpha"
            node_alias = ""
            is_favorite = false
            is_online = true
        }
    }

    function refreshMessages() {
        messagesModel.clear()
        var msgArray = []

        if (typeof MeshBridge !== "undefined" && MeshBridge && node_id) {
            var result = MeshBridge.getConversation(node_id, 100)
            if (result && result.messages) {
                // Ensure all properties are defined
                for (var i = 0; i < result.messages.length; i++) {
                    var msg = result.messages[i]
                    msgArray.push({
                        id: msg.id || "",
                        from_node: msg.from_node || "",
                        text: msg.text || "",
                        timestamp: msg.timestamp || "",
                        is_mine: msg.is_mine || false,
                        delivery_status: msg.delivery_status || ""
                    })
                }
            }
        } else {
            msgArray = [
                { id: "dm_1", from_node: node_id, text: "Sitrep on waypoint charlie? Any movement observed in the north sector?", timestamp: new Date(Date.now() - 180000).toISOString(), is_mine: false, delivery_status: "" },
                { id: "dm_2", from_node: "!00000001", text: "Negative contact. North sector is clear. Proceeding to observation point Delta.", timestamp: new Date(Date.now() - 120000).toISOString(), is_mine: true, delivery_status: "delivered" },
                { id: "dm_3", from_node: node_id, text: "Copy that. Establishing relay position.", timestamp: new Date(Date.now() - 60000).toISOString(), is_mine: false, delivery_status: "" },
                { id: "dm_4", from_node: "!00000001", text: "Understood. ETA 15 mikes.", timestamp: new Date().toISOString(), is_mine: true, delivery_status: "pending" }
            ]
        }

        for (var j = 0; j < msgArray.length; j++) {
            messagesModel.append(msgArray[j])
        }
    }

    function sendMessage(text) {
        if (!text.trim()) return

        if (typeof MeshBridge !== "undefined" && MeshBridge) {
            var result = MeshBridge.sendDirectMessage(text, node_id)
            if (result && result.success) {
                messageInput.text = ""
                refreshMessages()
            }
        } else {
            messagesModel.append({
                id: "dm_" + Date.now(),
                from_node: "!00000001",
                text: text,
                timestamp: new Date().toISOString(),
                is_mine: true,
                delivery_status: "pending"
            })
            messageInput.text = ""
        }
        messageList.positionViewAtEnd()
    }

    function toggleFavorite() {
        if (typeof MeshBridge !== "undefined" && MeshBridge) {
            var result = MeshBridge.toggleFavorite(node_id)
            if (result) {
                is_favorite = result.is_favorite
            }
        } else {
            is_favorite = !is_favorite
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: refreshMessages()
    }

    Core.TacticalBackground { anchors.fill: parent; z: 0 }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        z: 10

        // Header using PageHeader pattern with custom right content
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Core.Theme.appBarHeight

            Core.PageHeader {
                anchors.fill: parent
                title: node_alias || node_name || node_id
                subtitle: is_online ? "Online" : "Offline"
                showBack: true
                rightIcon: "information"
                onBackClicked: {
                    var p = meshConversation.parent
                    while (p && !p.navigateBack) p = p.parent
                    if (p) p.navigateBack()
                }
                onRightClicked: {
                    var p = meshConversation.parent
                    while (p && !p.openNodeDetails) p = p.parent
                    if (p) p.openNodeDetails(node_id)
                }
            }

            // Favorite star button (overlaid on right side before info button)
            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: 56  // Make room for info button
                anchors.verticalCenter: parent.verticalCenter
                width: 40
                height: 40
                radius: 20
                color: favMouse.containsMouse ? Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.1) : "transparent"
                z: 10

                Core.MaterialIcon {
                    anchors.centerIn: parent
                    name: is_favorite ? "star" : "star-outline"
                    size: 22
                    iconColor: is_favorite ? Core.Theme.warning : Core.Theme.textSecondary
                }

                MouseArea {
                    id: favMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: toggleFavorite()
                }
            }
        }

        // Encryption banner
        Rectangle {
            Layout.fillWidth: true
            height: 24
            color: Qt.rgba(Core.Theme.success.r, Core.Theme.success.g, Core.Theme.success.b, 0.1)

            Row {
                anchors.centerIn: parent
                spacing: Core.Theme.spacingSmall
                Core.MaterialIcon {
                    name: "lock"
                    size: 12
                    iconColor: Core.Theme.success
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "ENCRYPTED"
                    color: Core.Theme.success
                    font.pixelSize: 10
                    font.family: Core.Theme.fontFamilyMono
                    font.letterSpacing: 1
                }
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

                Column {
                    id: contentCol
                    width: parent.width
                    spacing: 4

                    // Message bubble - aligned left or right
                    Rectangle {
                        id: bubble
                        anchors.left: isMine ? undefined : parent.left
                        anchors.right: isMine ? parent.right : undefined
                        width: Math.min(parent.width * 0.85, msgText.implicitWidth + 24)
                        height: msgText.height + 24
                        color: isMine ? Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3) : Core.Theme.tacticalCard
                        border.color: isMine ? Qt.rgba(Core.Theme.success.r, Core.Theme.success.g, Core.Theme.success.b, 0.4) : Core.Theme.divider
                        border.width: 1
                        radius: 8
                        opacity: model.delivery_status === "sending" ? 0.7 : 1.0

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

                    // Timestamp (below bubble)
                    Row {
                        anchors.left: isMine ? undefined : parent.left
                        anchors.right: isMine ? parent.right : undefined
                        spacing: 4
                        opacity: 0.8

                        Text {
                            text: model.delivery_status === "sending" ? "Sending..." : formatTime(model.timestamp)
                            color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.5)
                            font.pixelSize: 10
                            font.family: Core.Theme.fontFamilyMono
                        }

                        // Delivery status icon (sent messages only, using text for reliability)
                        Text {
                            visible: isMine
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
                text: "No messages yet\n\nStart a conversation!"
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
                            text: "Message " + (node_alias || node_name || "...") + "..."
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
}
