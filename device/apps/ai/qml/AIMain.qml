import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import Core as Core

/**
 * AIMain - Tactical-styled AI chat interface (modular app)
 */
Rectangle {
    id: aiChat
    color: Core.Theme.background

    // Standard app interface
    property string appId: "com.waycore.ai"
    property string appTitle: "AI"
    signal closeRequested()

    // Chat state
    property var messages: []
    property bool isLoading: typeof AIBridge !== "undefined" && AIBridge ? AIBridge.isLoading : false
    property string selectedModel: "phi3-mini"
    property var availableModels: []
    property int currentConversationId: 0
    property bool wasLoading: false

    // Multimodal state
    property string attachedImagePath: ""
    property string attachedImageB64: ""
    property bool hasAttachedImage: attachedImagePath !== "" || attachedImageB64 !== ""

    Component.onCompleted: {
        loadModels()
        loadMostRecentConversation()
        if (typeof AIBridge !== "undefined" && AIBridge) {
            isLoading = AIBridge.isLoading
        }
    }

    function loadMostRecentConversation() {
        if (typeof AIBridge !== "undefined" && AIBridge) {
            // Check if there's already a current conversation
            var currentId = AIBridge.currentConversationId
            if (currentId && currentId > 0) {
                // Already has a conversation, just load messages
                messages = AIBridge.getMessages()
                currentConversationId = currentId
                console.log("AI: Loaded existing conversation", currentId, "with", messages.length, "messages")
            } else {
                // No current conversation, try to load the most recent one
                var conversations = AIBridge.getConversations()
                console.log("AI: Found", conversations.length, "conversations in history")
                if (conversations.length > 0) {
                    var mostRecent = conversations[0]  // Already sorted by updated_at DESC
                    console.log("AI: Loading most recent conversation:", mostRecent.id, mostRecent.title)
                    AIBridge.loadConversation(mostRecent.id)
                    messages = AIBridge.getMessages()
                    currentConversationId = mostRecent.id
                    console.log("AI: Loaded", messages.length, "messages")
                } else {
                    console.log("AI: No conversations found, starting fresh")
                    messages = []
                    currentConversationId = 0
                }
            }
        }
    }

    function loadMessages() {
        if (typeof AIBridge !== "undefined" && AIBridge) {
            messages = AIBridge.getMessages()
            console.log("AI: Reloaded messages:", messages.length)
        }
    }

    function loadModels() {
        if (typeof AIBridge !== "undefined" && AIBridge) {
            availableModels = AIBridge.getAvailableModels()
            selectedModel = AIBridge.getModelId()
        } else {
            availableModels = [
                { id: "phi3-mini", name: "Phi-3 Mini" },
                { id: "llama2-7b", name: "Llama 2 7B" }
            ]
        }
    }

    function updateConversationId() {
        if (typeof AIBridge !== "undefined" && AIBridge) {
            currentConversationId = AIBridge.currentConversationId
        }
    }

    function sendMessage(text) {
        if (!text.trim() && !hasAttachedImage) return
        if (isLoading) return

        var messageText = text
        messageInput.text = ""
        messageInput.enabled = false

        if (typeof AIBridge !== "undefined" && AIBridge) {
            AIBridge.setModelId(selectedModel)
            wasLoading = true
            isLoading = true

            if (hasAttachedImage) {
                if (attachedImagePath) {
                    AIBridge.sendMultimodalChatFromPath(messageText, attachedImagePath)
                } else if (attachedImageB64) {
                    AIBridge.sendMultimodalChat(messageText, attachedImageB64)
                }
                clearAttachedImage()
            } else {
                AIBridge.sendChat(messageText)
            }
        } else {
            var userMsg = { role: "user", content: hasAttachedImage ? "📷 " + messageText : messageText, timestamp: new Date().toISOString() }
            var assistantMsg = { role: "assistant", content: hasAttachedImage ? "This is a mock multimodal response." : "This is a mock response.", timestamp: new Date().toISOString() }
            messages = messages.concat([userMsg, assistantMsg])
            clearAttachedImage()
            messageInput.enabled = true
        }
    }

    function clearAttachedImage() {
        attachedImagePath = ""
        attachedImageB64 = ""
    }

    function attachImageFromPath(filePath) {
        var cleanPath = filePath.toString().replace(/^file:\/\//, "")
        attachedImagePath = cleanPath
        attachedImageB64 = ""
    }

    function clearChat() {
        if (typeof AIBridge !== "undefined" && AIBridge) {
            AIBridge.clearMessages()
        }
        messages = []
    }

    function newChat() {
        if (typeof AIBridge !== "undefined" && AIBridge) {
            AIBridge.newConversation()
            messages = []
            updateConversationId()
        }
    }

    function openHistory() {
        historyView.visible = true
    }

    function classifyMockImage() {
        if (isLoading) return
        if (typeof AIBridge !== "undefined" && AIBridge) {
            wasLoading = true
            isLoading = true
            messageInput.enabled = false
            var mockImageB64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
            AIBridge.classifyImageAndChat(mockImageB64)
        } else {
            var userMsg = { role: "user", content: "📷 [Image for classification]", timestamp: new Date().toISOString() }
            var assistantMsg = { role: "assistant", content: "**Image Classification Results:**\n\n• **Mountain**: 85.0%", timestamp: new Date().toISOString() }
            messages = messages.concat([userMsg, assistantMsg])
        }
    }

    function openGalleryPicker() {
        if (isLoading) return
        imageFileDialog.open()
    }

    function classifyImageFromFile(filePath) {
        if (isLoading || !filePath) return
        attachImageFromPath(filePath)
    }

    // Listen to AIBridge signals
    Connections {
        target: typeof AIBridge !== "undefined" ? AIBridge : null
        enabled: typeof AIBridge !== "undefined" && AIBridge !== null

        function onLoadingChanged() {
            var newLoading = AIBridge.isLoading
            if (wasLoading && !newLoading) {
                messageInput.enabled = true
                focusTimer.start()
            }
            wasLoading = newLoading
            isLoading = newLoading
        }

        function onMessagesChanged() {
            messages = AIBridge.getMessages()
            messageList.positionViewAtEnd()
        }

        function onErrorChanged() {
            if (AIBridge.error) {
                console.error("AI Error:", AIBridge.error)
            }
        }

        function onCurrentConversationChanged() {
            updateConversationId()
        }

        function onChatCompleted(result) {
            if (!result.success) {
                console.error("Chat error:", result.error)
            }
            updateConversationId()
        }

        function onImageClassifyCompleted(result) {
            if (!result.success) {
                console.error("Classify error:", result.error)
            }
            updateConversationId()
        }

        function onMultimodalChatCompleted(result) {
            if (!result.success) {
                console.error("Multimodal error:", result.error)
            }
            updateConversationId()
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

                // Back button (matching PageHeader style)
                Rectangle {
                    width: 48
                    height: 48
                    color: "transparent"
                    Layout.alignment: Qt.AlignVCenter

                    Core.MaterialIcon {
                        anchors.centerIn: parent
                        name: "chevron-left"
                        size: 28
                        iconColor: backArea.containsMouse ? Core.Theme.warning : Core.Theme.textSecondary

                        Behavior on iconColor {
                            ColorAnimation { duration: 150 }
                        }

                        // Hover animation
                        x: backArea.containsMouse ? -2 : 0
                        Behavior on x {
                            NumberAnimation { duration: 150 }
                        }
                    }

                    MouseArea {
                        id: backArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: closeRequested()
                    }
                }

                // Title section
                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 2

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "AI ASSISTANT"
                        color: Core.Theme.warning
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        font.letterSpacing: 4
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "MODEL: " + getModelDisplayName(selectedModel).toUpperCase()
                        color: Core.Theme.divider
                        font.pixelSize: 10
                        font.family: Core.Theme.fontFamilyMono
                        font.letterSpacing: 2
                        opacity: 0.8
                    }
                }

                // Action buttons
                Row {
                    spacing: 4
                    Layout.alignment: Qt.AlignVCenter

                    // History
                    Rectangle {
                        width: 36
                        height: 36
                        radius: Core.Theme.borderRadius
                        color: historyBtnArea.containsMouse ? Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.5) : "transparent"

                        Core.MaterialIcon {
                            anchors.centerIn: parent
                            name: "timer"
                            size: 20
                            iconColor: historyBtnArea.containsMouse ? Core.Theme.textPrimary : Core.Theme.textSecondary
                        }

                        MouseArea {
                            id: historyBtnArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: openHistory()
                        }
                    }

                    // New chat
                    Rectangle {
                        width: 36
                        height: 36
                        radius: Core.Theme.borderRadius
                        color: newChatBtnArea.containsMouse ? Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.5) : "transparent"

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
                            onClicked: newChat()
                        }
                    }

                    // Clear chat
                    Rectangle {
                        width: 36
                        height: 36
                        radius: Core.Theme.borderRadius
                        color: clearBtnArea.containsMouse ? Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.5) : "transparent"
                        opacity: messages.length > 0 ? 1.0 : 0.5

                        Core.MaterialIcon {
                            anchors.centerIn: parent
                            name: "delete"
                            size: 20
                            iconColor: clearBtnArea.containsMouse ? Core.Theme.warning : Core.Theme.textSecondary
                        }

                        MouseArea {
                            id: clearBtnArea
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: messages.length > 0
                            onClicked: clearChatDialog.visible = true
                        }
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

        // Message list
        ListView {
            id: messageList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Core.Theme.spacingMedium
            clip: true
            spacing: Core.Theme.spacingLarge

            model: messages

            header: Item {
                width: messageList.width
                height: messages.length === 0 ? welcomeBanner.height + 32 : 0
                visible: messages.length === 0

                Column {
                    id: welcomeBanner
                    anchors.centerIn: parent
                    spacing: Core.Theme.spacingMedium
                    width: parent.width
                    opacity: 0.6

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 64
                        height: 64
                        radius: 16
                        color: Core.Theme.surface
                        border.color: Core.Theme.divider
                        border.width: 1

                        Core.MaterialIcon {
                            anchors.centerIn: parent
                            name: "robot"
                            size: 36
                            iconColor: Core.Theme.primary
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "WAYCORE AI"
                        color: Core.Theme.textPrimary
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        font.letterSpacing: 3
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Secure local multimodal assistant ready.\nAsk questions or analyze tactical data."
                        color: Core.Theme.textSecondary
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        lineHeight: 1.4
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width * 0.8
                        height: 1
                        color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
                    }
                }
            }

            delegate: Item {
                width: messageList.width
                height: messageColumn.height

                property bool isUser: modelData.role === "user"

                Column {
                    id: messageColumn
                    width: parent.width
                    spacing: 4

                    Row {
                        visible: !isUser
                        spacing: 8
                        anchors.left: parent.left

                        Core.MaterialIcon {
                            name: "robot"
                            size: 14
                            iconColor: Core.Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "AI SYSTEM"
                            color: Core.Theme.textSecondary
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            font.letterSpacing: 2
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Rectangle {
                        width: Math.min(parent.width * 0.9, messageText.implicitWidth + 24)
                        height: messageText.implicitHeight + 24
                        radius: 16
                        color: isUser ? Core.Theme.primary : Core.Theme.surface
                        border.color: isUser ? Core.Theme.primary : Core.Theme.divider
                        border.width: 1
                        anchors.right: isUser ? parent.right : undefined
                        anchors.left: isUser ? undefined : parent.left

                        Rectangle {
                            visible: !isUser
                            anchors.top: parent.top
                            anchors.left: parent.left
                            width: 16
                            height: 16
                            color: parent.color
                        }

                        Rectangle {
                            visible: isUser
                            anchors.top: parent.top
                            anchors.right: parent.right
                            width: 16
                            height: 16
                            color: parent.color
                        }

                        Text {
                            id: messageText
                            anchors.fill: parent
                            anchors.margins: 12
                            text: modelData.content
                            color: isUser ? "#FFFFFF" : Core.Theme.textPrimary
                            font.pixelSize: 14
                            wrapMode: Text.WordWrap
                            lineHeight: 1.4
                        }
                    }

                    Text {
                        text: formatTime(modelData.timestamp)
                        color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.5)
                        font.pixelSize: 10
                        font.family: Core.Theme.fontFamilyMono
                        anchors.right: isUser ? parent.right : undefined
                        anchors.left: isUser ? undefined : parent.left
                        anchors.margins: 4
                    }
                }
            }

            onCountChanged: {
                positionViewAtEnd()
            }
        }

        // Loading indicator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: isLoading ? 56 : 0
            Layout.leftMargin: Core.Theme.spacingMedium
            Layout.rightMargin: Core.Theme.spacingMedium
            visible: isLoading
            color: Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.5)
            radius: 16
            clip: true

            Behavior on Layout.preferredHeight {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Core.MaterialIcon {
                    name: "robot"
                    size: 14
                    iconColor: Core.Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Thinking"
                    color: Core.Theme.textSecondary
                    font.pixelSize: 12
                    font.family: Core.Theme.fontFamilyMono
                    anchors.verticalCenter: parent.verticalCenter
                }

                Row {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    Repeater {
                        model: 3
                        Rectangle {
                            width: 4
                            height: 4
                            radius: 2
                            color: Core.Theme.textSecondary

                            SequentialAnimation on y {
                                running: isLoading
                                loops: Animation.Infinite
                                NumberAnimation { to: -4; duration: 300; easing.type: Easing.OutQuad }
                                NumberAnimation { to: 0; duration: 300; easing.type: Easing.InQuad }
                                PauseAnimation { duration: index * 100 }
                            }
                        }
                    }
                }
            }
        }

        // Attached image preview
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: hasAttachedImage ? 64 : 0
            visible: hasAttachedImage
            color: Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.3)
            clip: true

            Behavior on Layout.preferredHeight {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.5)
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: Core.Theme.spacingSmall
                spacing: Core.Theme.spacingSmall

                Rectangle {
                    width: 48
                    height: 48
                    radius: Core.Theme.borderRadius
                    color: Core.Theme.background
                    border.color: Core.Theme.divider
                    border.width: 1
                    clip: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: 2
                        source: attachedImagePath ? "file://" + attachedImagePath : ""
                        fillMode: Image.PreserveAspectCrop
                        visible: attachedImagePath !== ""
                    }

                    Core.MaterialIcon {
                        anchors.centerIn: parent
                        name: "image"
                        size: 24
                        iconColor: Core.Theme.textSecondary
                        visible: attachedImagePath === ""
                    }
                }

                Column {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: attachedImagePath ? attachedImagePath.split('/').pop() : "Image attached"
                        color: Core.Theme.textPrimary
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        elide: Text.ElideMiddle
                        width: parent.width
                    }

                    Text {
                        text: "PENDING"
                        color: Core.Theme.textSecondary
                        font.pixelSize: 10
                        font.family: Core.Theme.fontFamilyMono
                    }
                }

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: removeImgArea.containsMouse ? Qt.rgba(0.5, 0.1, 0.1, 0.5) : "transparent"
                    Layout.alignment: Qt.AlignVCenter

                    Core.MaterialIcon {
                        anchors.centerIn: parent
                        name: "close"
                        size: 18
                        iconColor: removeImgArea.containsMouse ? Core.Theme.error : Core.Theme.textSecondary
                    }

                    MouseArea {
                        id: removeImgArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: clearAttachedImage()
                    }
                }
            }
        }

        // Input bar
        Rectangle {
            Layout.fillWidth: true
            height: 72
            color: Core.Theme.background

            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: Core.Theme.divider
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: Core.Theme.spacingSmall
                anchors.bottomMargin: Core.Theme.spacingLarge
                spacing: Core.Theme.spacingSmall

                Rectangle {
                    width: 46
                    height: 46
                    radius: Core.Theme.borderRadius
                    color: galleryBtnArea.containsMouse ? Core.Theme.divider : Core.Theme.surface
                    border.color: Core.Theme.divider
                    border.width: 1
                    opacity: (!isLoading && !hasAttachedImage) ? 1.0 : 0.5
                    Layout.alignment: Qt.AlignVCenter

                    Core.MaterialIcon {
                        anchors.centerIn: parent
                        name: "image-multiple"
                        size: 20
                        iconColor: galleryBtnArea.containsMouse ? Core.Theme.textPrimary : Core.Theme.textSecondary
                    }

                    MouseArea {
                        id: galleryBtnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: !isLoading && !hasAttachedImage
                        onClicked: openGalleryPicker()
                    }
                }

                Rectangle {
                    width: 46
                    height: 46
                    radius: Core.Theme.borderRadius
                    color: cameraBtnArea.containsMouse ? Core.Theme.divider : Core.Theme.surface
                    border.color: Core.Theme.divider
                    border.width: 1
                    opacity: (!isLoading && !hasAttachedImage) ? 1.0 : 0.5
                    Layout.alignment: Qt.AlignVCenter

                    Core.MaterialIcon {
                        anchors.centerIn: parent
                        name: "camera"
                        size: 20
                        iconColor: cameraBtnArea.containsMouse ? Core.Theme.textPrimary : Core.Theme.textSecondary
                    }

                    MouseArea {
                        id: cameraBtnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: !isLoading && !hasAttachedImage
                        onClicked: classifyMockImage()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Core.Theme.borderRadius
                    color: Core.Theme.background
                    border.color: messageInput.activeFocus ? Core.Theme.primary : Core.Theme.divider
                    border.width: 1

                    TextArea {
                        id: messageInput
                        anchors.fill: parent
                        anchors.margins: 8
                        placeholderText: hasAttachedImage ? "Ask about this image..." : "Message tactical AI..."
                        placeholderTextColor: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.5)
                        color: Core.Theme.textPrimary
                        font.pixelSize: 14
                        wrapMode: TextEdit.Wrap
                        enabled: !isLoading
                        background: null

                        Keys.onReturnPressed: {
                            if (!(event.modifiers & Qt.ShiftModifier)) {
                                sendMessage(text)
                                event.accepted = true
                            }
                        }
                    }
                }

                Rectangle {
                    width: 46
                    height: 46
                    radius: Core.Theme.borderRadius
                    color: sendBtnArea.enabled ? (sendBtnArea.pressed ? Qt.darker(Core.Theme.primary, 1.1) : Core.Theme.primary) : Core.Theme.surface
                    border.color: Core.Theme.divider
                    border.width: sendBtnArea.enabled ? 0 : 1
                    Layout.alignment: Qt.AlignVCenter

                    property bool canSend: (messageInput.text.trim().length > 0 || hasAttachedImage) && !isLoading

                    Core.MaterialIcon {
                        anchors.centerIn: parent
                        name: "send"
                        size: 20
                        iconColor: parent.canSend ? Core.Theme.textPrimary : Core.Theme.textSecondary
                    }

                    MouseArea {
                        id: sendBtnArea
                        anchors.fill: parent
                        enabled: parent.canSend
                        onClicked: sendMessage(messageInput.text)
                    }
                }
            }
        }
    }

    // Focus timer
    Timer {
        id: focusTimer
        interval: 100
        repeat: false
        onTriggered: {
            if (messageInput.enabled) {
                messageInput.forceActiveFocus()
            }
        }
    }

    // Clear chat dialog
    Rectangle {
        id: clearChatDialog
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.8)
        visible: false
        z: 100

        MouseArea {
            anchors.fill: parent
            onClicked: clearChatDialog.visible = false
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.9
            height: clearContent.height + 32
            color: Core.Theme.background
            border.color: Core.Theme.warning
            border.width: 1
            radius: Core.Theme.borderRadius

            Rectangle { anchors.top: parent.top; anchors.left: parent.left; width: 6; height: 2; color: Core.Theme.warning }
            Rectangle { anchors.top: parent.top; anchors.left: parent.left; width: 2; height: 6; color: Core.Theme.warning }
            Rectangle { anchors.top: parent.top; anchors.right: parent.right; width: 6; height: 2; color: Core.Theme.warning }
            Rectangle { anchors.top: parent.top; anchors.right: parent.right; width: 2; height: 6; color: Core.Theme.warning }
            Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; width: 6; height: 2; color: Core.Theme.warning }
            Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; width: 2; height: 6; color: Core.Theme.warning }
            Rectangle { anchors.bottom: parent.bottom; anchors.right: parent.right; width: 6; height: 2; color: Core.Theme.warning }
            Rectangle { anchors.bottom: parent.bottom; anchors.right: parent.right; width: 2; height: 6; color: Core.Theme.warning }

            Column {
                id: clearContent
                anchors.centerIn: parent
                width: parent.width - 32
                spacing: 12

                Row {
                    spacing: 8

                    Core.MaterialIcon {
                        name: "alert"
                        size: 24
                        iconColor: Core.Theme.warning
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "CLEAR HISTORY?"
                        color: Core.Theme.textPrimary
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        font.letterSpacing: 2
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Text {
                    width: parent.width
                    text: "This will permanently delete all local chat logs. This action cannot be undone."
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
                        color: cancelClearArea.containsMouse ? Core.Theme.surface : "transparent"
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
                            id: cancelClearArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: clearChatDialog.visible = false
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 44
                        radius: Core.Theme.borderRadius
                        color: confirmClearArea.containsMouse ? Qt.rgba(0.5, 0.1, 0.1, 0.4) : Qt.rgba(0.3, 0.05, 0.05, 0.2)
                        border.color: Qt.rgba(0.5, 0.2, 0.2, 0.5)
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "CONFIRM DELETE"
                            color: Core.Theme.error
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            font.letterSpacing: 1
                        }

                        MouseArea {
                            id: confirmClearArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                clearChat()
                                clearChatDialog.visible = false
                            }
                        }
                    }
                }
            }
        }
    }

    // History view with conversation list
    Rectangle {
        id: historyView
        anchors.fill: parent
        color: Core.Theme.background
        visible: false
        z: 50

        property var historyConversations: []

        function loadHistoryConversations() {
            if (typeof AIBridge !== "undefined" && AIBridge) {
                historyConversations = AIBridge.getConversations()
                console.log("AI History: Loaded", historyConversations.length, "conversations")
            }
        }

        onVisibleChanged: {
            if (visible) {
                loadHistoryConversations()
            }
        }

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
                color: Qt.rgba(Core.Theme.background.r, Core.Theme.background.g, Core.Theme.background.b, 0.9)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Core.Theme.spacingMedium
                    anchors.rightMargin: Core.Theme.spacingMedium
                    spacing: Core.Theme.spacingMedium

                    // Back button (matching PageHeader style)
                    Rectangle {
                        width: 48
                        height: 48
                        color: "transparent"
                        Layout.alignment: Qt.AlignVCenter

                        Core.MaterialIcon {
                            anchors.centerIn: parent
                            name: "chevron-left"
                            size: 28
                            iconColor: historyBackArea.containsMouse ? Core.Theme.warning : Core.Theme.textSecondary

                            Behavior on iconColor {
                                ColorAnimation { duration: 150 }
                            }

                            // Hover animation
                            x: historyBackArea.containsMouse ? -2 : 0
                            Behavior on x {
                                NumberAnimation { duration: 150 }
                            }
                        }

                        MouseArea {
                            id: historyBackArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: historyView.visible = false
                        }
                    }

                    // Title section
                    Column {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 2

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "CHAT HISTORY"
                            color: Core.Theme.warning
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            font.letterSpacing: 4
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: historyView.historyConversations.length + " CONVERSATIONS"
                            color: Core.Theme.divider
                            font.pixelSize: 10
                            font.family: Core.Theme.fontFamilyMono
                            font.letterSpacing: 2
                            opacity: 0.8
                        }
                    }

                    // New chat button
                    Rectangle {
                        width: 36
                        height: 36
                        radius: Core.Theme.borderRadius
                        color: newChatHistoryArea.containsMouse ? Core.Theme.primary : Core.Theme.surface
                        border.color: newChatHistoryArea.containsMouse ? Core.Theme.primary : Core.Theme.divider
                        border.width: 1
                        Layout.alignment: Qt.AlignVCenter

                        Core.MaterialIcon {
                            anchors.centerIn: parent
                            name: "plus"
                            size: 20
                            iconColor: newChatHistoryArea.containsMouse ? Core.Theme.textPrimary : Core.Theme.textSecondary
                        }

                        MouseArea {
                            id: newChatHistoryArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                newChat()
                                historyView.visible = false
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: Core.Theme.divider
                }
            }

            // Conversation list
            ListView {
                id: historyListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: Core.Theme.spacingSmall
                clip: true
                spacing: Core.Theme.spacingSmall

                model: historyView.historyConversations

                delegate: Rectangle {
                    width: historyListView.width
                    height: 80
                    color: historyItemArea.containsMouse ? Core.Theme.surface : Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.3)
                    radius: Core.Theme.borderRadius
                    border.color: historyItemArea.containsMouse ? Core.Theme.divider : Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
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
                                    width: msgCountLabel.width + 12
                                    height: 18
                                    radius: 9
                                    color: Qt.rgba(Core.Theme.primary.r, Core.Theme.primary.g, Core.Theme.primary.b, 0.2)

                                    Text {
                                        id: msgCountLabel
                                        anchors.centerIn: parent
                                        text: (modelData.message_count || 0) + " MSG"
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
                            color: historyDeleteArea.containsMouse ? Qt.rgba(0.5, 0.1, 0.1, 0.3) : "transparent"
                            Layout.alignment: Qt.AlignVCenter

                            Core.MaterialIcon {
                                anchors.centerIn: parent
                                name: "delete"
                                size: 18
                                iconColor: historyDeleteArea.containsMouse ? Core.Theme.error : Core.Theme.textSecondary
                            }

                            MouseArea {
                                id: historyDeleteArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    if (typeof AIBridge !== "undefined" && AIBridge) {
                                        AIBridge.deleteConversation(modelData.id)
                                        historyView.loadHistoryConversations()
                                        // If we deleted the current conversation, reload
                                        if (modelData.id === currentConversationId) {
                                            loadMostRecentConversation()
                                        }
                                    }
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
                        id: historyItemArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (typeof AIBridge !== "undefined" && AIBridge) {
                                console.log("AI History: Loading conversation", modelData.id)
                                AIBridge.loadConversation(modelData.id)
                                messages = AIBridge.getMessages()
                                currentConversationId = modelData.id
                                console.log("AI History: Loaded", messages.length, "messages")
                            }
                            historyView.visible = false
                        }
                    }
                }

                // Empty state
                Column {
                    visible: historyView.historyConversations.length === 0
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
                            name: "message-text"
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
                        text: "Start a new conversation to begin."
                        color: Core.Theme.textSecondary
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }

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

    // File dialog
    FileDialog {
        id: imageFileDialog
        title: "Select an image"
        nameFilters: ["Image files (*.jpg *.jpeg *.png *.gif *.webp)", "All files (*)"]
        fileMode: FileDialog.OpenFile

        onAccepted: {
            classifyImageFromFile(selectedFile.toString())
        }
    }

    // Helper functions
    function formatTime(isoString) {
        if (!isoString) return ""
        var date = new Date(isoString)
        var hours = date.getHours().toString().padStart(2, '0')
        var mins = date.getMinutes().toString().padStart(2, '0')
        var secs = date.getSeconds().toString().padStart(2, '0')
        return hours + ":" + mins + ":" + secs
    }

    function getModelDisplayName(modelId) {
        for (var i = 0; i < availableModels.length; i++) {
            if (availableModels[i].id === modelId) {
                return availableModels[i].name
            }
        }
        return modelId
    }
}
