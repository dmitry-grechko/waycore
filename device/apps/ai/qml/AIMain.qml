import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import Core as Core

Rectangle {
    id: aiChat
    color: Core.Theme.background

    // Standard app interface
    property string appId: "com.waycore.ai"
    property string appTitle: "AI"
    signal closeRequested()

    // Chat state
    property var messages: []
    property bool isLoading: AIBridge ? AIBridge.isLoading : false
    property string selectedModel: "phi3-mini"
    property var availableModels: []
    property int currentConversationId: 0
    property bool wasLoading: false  // Track loading state transitions

    // Multimodal state - attached image for Visual Q&A
    property string attachedImagePath: ""
    property string attachedImageB64: ""
    property bool hasAttachedImage: attachedImagePath !== "" || attachedImageB64 !== ""

    Component.onCompleted: {
        loadMessages()
        loadModels()
        updateConversationId()
        // Sync loading state from bridge
        if (AIBridge) {
            isLoading = AIBridge.isLoading
        }
    }

    function loadMessages() {
        if (AIBridge) {
            messages = AIBridge.getMessages()
        }
    }

    function loadModels() {
        if (AIBridge) {
            availableModels = AIBridge.getAvailableModels()
            selectedModel = AIBridge.getModelId()
        } else {
            // Mock models
            availableModels = [
                { id: "phi3-mini", name: "Phi-3 Mini" },
                { id: "llama2-7b", name: "Llama 2 7B" }
            ]
        }
    }

    function updateConversationId() {
        if (AIBridge) {
            currentConversationId = AIBridge.currentConversationId
        }
    }

    function sendMessage(text) {
        // Allow sending with just an attached image (no text required)
        if (!text.trim() && !hasAttachedImage) return
        if (isLoading) return

        // Clear input immediately for better UX
        var messageText = text
        messageInput.text = ""
        messageInput.enabled = false

        if (AIBridge) {
            AIBridge.setModelId(selectedModel)
            // Set loading immediately for instant feedback
            wasLoading = true
            isLoading = true

            // Check if we have an attached image for multimodal
            if (hasAttachedImage) {
                // Use multimodal API (image + question)
                if (attachedImagePath) {
                    AIBridge.sendMultimodalChatFromPath(messageText, attachedImagePath)
                } else if (attachedImageB64) {
                    AIBridge.sendMultimodalChat(messageText, attachedImageB64)
                }
                // Clear attached image after sending
                clearAttachedImage()
            } else {
                // Regular text-only chat
                AIBridge.sendChat(messageText)
            }
        } else {
            // Mock: add messages locally
            var userMsg = {
                role: "user",
                content: hasAttachedImage ? "📷 " + messageText : messageText,
                timestamp: new Date().toISOString()
            }
            var assistantMsg = {
                role: "assistant",
                content: hasAttachedImage
                    ? "This is a mock multimodal response. I can see the image you attached."
                    : "This is a mock response. Connect to the AI service for real answers.",
                timestamp: new Date().toISOString()
            }
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
        // Remove file:// prefix if present
        var cleanPath = filePath.toString().replace(/^file:\/\//, "")
        attachedImagePath = cleanPath
        attachedImageB64 = ""
    }

    function clearChat() {
        if (AIBridge) {
            AIBridge.clearMessages()
        }
        messages = []
    }

    function newChat() {
        if (AIBridge) {
            AIBridge.newConversation()
            messages = []
            updateConversationId()
        }
    }

    function openHistory() {
        var shell = aiChat.parent
        while (shell && !shell.hasOwnProperty("navigateTo")) {
            shell = shell.parent
        }
        if (shell && shell.navigateTo) {
            shell.navigateTo("AIHistory")
        }
    }

    function classifyMockImage() {
        if (isLoading) return

        if (AIBridge) {
            wasLoading = true
            isLoading = true
            messageInput.enabled = false
            var mockImageB64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
            AIBridge.classifyImageAndChat(mockImageB64)
        } else {
            var userMsg = {
                role: "user",
                content: "📷 [Image for classification]",
                timestamp: new Date().toISOString()
            }
            var assistantMsg = {
                role: "assistant",
                content: "**Image Classification Results:**\n\n• **Mountain**: 85.0%\n• **Tree**: 72.3%\n• **Rock**: 65.1%",
                timestamp: new Date().toISOString()
            }
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

    function classifyImageDirectly(filePath) {
        if (isLoading || !filePath) return

        if (AIBridge) {
            wasLoading = true
            isLoading = true
            messageInput.enabled = false
            AIBridge.classifyImageFromPath(filePath)
        } else {
            classifyMockImage()
        }
    }

    // Listen to AIBridge signals
    Connections {
        target: AIBridge || null

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
                toast.show(AIBridge.error)
            }
        }

        function onCurrentConversationChanged() {
            updateConversationId()
        }

        function onChatCompleted(result) {
            if (!result.success) {
                toast.show("Error: " + (result.error || "Unknown error"))
            }
            updateConversationId()
        }

        function onImageClassifyCompleted(result) {
            if (!result.success) {
                toast.show("Error: " + (result.error || "Unknown error"))
            }
            updateConversationId()
        }

        function onMultimodalChatCompleted(result) {
            if (!result.success) {
                toast.show("Error: " + (result.error || "Unknown error"))
            }
            updateConversationId()
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

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "🤖 AI Assistant"
                        color: Core.Theme.textPrimary
                        font.pixelSize: Core.Theme.h2Size
                        font.bold: true
                    }

                    Text {
                        text: getModelDisplayName(selectedModel)
                        color: Core.Theme.textSecondary
                        font.pixelSize: Core.Theme.captionSize
                    }
                }

                // History button
                Button {
                    text: "📜"
                    font.pixelSize: 18
                    onClicked: openHistory()

                    ToolTip.visible: hovered
                    ToolTip.text: "Chat history"
                }

                // New chat button
                Button {
                    text: "✨"
                    font.pixelSize: 18
                    onClicked: newChat()

                    ToolTip.visible: hovered
                    ToolTip.text: "New chat"
                }

                // Active model indicator
                Rectangle {
                    id: modelIndicator
                    height: 28
                    width: modelLabel.width + 16
                    color: Core.Theme.surfaceElevated
                    radius: 4
                    border.color: Core.Theme.divider

                    Text {
                        id: modelLabel
                        anchors.centerIn: parent
                        text: getModelDisplayName(selectedModel)
                        color: Core.Theme.textSecondary
                        font.pixelSize: Core.Theme.captionSize
                    }

                    ToolTip.visible: modelMouseArea.containsMouse
                    ToolTip.text: "Active AI model"

                    MouseArea {
                        id: modelMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }

                // Clear chat button
                Button {
                    text: "🗑️"
                    font.pixelSize: 18
                    enabled: messages.length > 0
                    onClicked: clearChatDialog.open()

                    ToolTip.visible: hovered
                    ToolTip.text: "Clear chat"
                }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Core.Theme.divider
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

                property bool isUser: modelData.role === "user"

                Rectangle {
                    id: messageBubble
                    width: Math.min(parent.width * 0.85, messageContent.implicitWidth + 24)
                    height: messageContent.implicitHeight + 16
                    radius: 16
                    color: isUser ? Core.Theme.primary : Core.Theme.surfaceElevated
                    anchors.right: isUser ? parent.right : undefined
                    anchors.left: isUser ? undefined : parent.left
                    anchors.margins: Core.Theme.spacingSmall

                    ColumnLayout {
                        id: messageContent
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 4

                        // Role indicator (for assistant)
                        Text {
                            visible: !isUser
                            text: "🤖 AI"
                            color: Core.Theme.accent
                            font.pixelSize: Core.Theme.captionSize
                            font.bold: true
                        }

                        // Message text
                        Text {
                            text: modelData.content
                            color: isUser ? "#FFFFFF" : Core.Theme.textPrimary
                            font.pixelSize: Core.Theme.bodySize
                            wrapMode: Text.WordWrap
                            Layout.maximumWidth: messageList.width * 0.75

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.IBeamCursor
                                onPressAndHold: {
                                    // Could implement copy functionality here
                                }
                            }
                        }

                        // Timestamp
                        Text {
                            Layout.alignment: Qt.AlignRight
                            text: formatTime(modelData.timestamp)
                            color: isUser ? "#CCCCCC" : Core.Theme.textSecondary
                            font.pixelSize: 10
                        }
                    }
                }
            }

            // Empty state
            Column {
                visible: messages.length === 0
                anchors.centerIn: parent
                spacing: Core.Theme.spacingMedium

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "🤖"
                    font.pixelSize: 64
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "AI Assistant"
                    color: Core.Theme.textPrimary
                    font.pixelSize: Core.Theme.h2Size
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Ask me anything!\nI can help with outdoor tips,\nidentification, and more."
                    color: Core.Theme.textSecondary
                    font.pixelSize: Core.Theme.bodySize
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            onCountChanged: {
                positionViewAtEnd()
            }
        }

        // Loading indicator
        Rectangle {
            id: loadingIndicator
            Layout.fillWidth: true
            Layout.preferredHeight: isLoading ? 48 : 0
            visible: isLoading
            color: Core.Theme.surface
            clip: true

            RowLayout {
                anchors.centerIn: parent
                spacing: Core.Theme.spacingMedium
                visible: isLoading

                Row {
                    spacing: 4
                    Repeater {
                        model: 3
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: Core.Theme.accent
                            opacity: 0.3

                            SequentialAnimation on opacity {
                                running: isLoading
                                loops: Animation.Infinite
                                PauseAnimation { duration: index * 200 }
                                NumberAnimation { to: 1.0; duration: 300 }
                                NumberAnimation { to: 0.3; duration: 300 }
                                PauseAnimation { duration: (2 - index) * 200 }
                            }
                        }
                    }
                }

                Text {
                    text: "Thinking..."
                    color: Core.Theme.textSecondary
                    font.pixelSize: Core.Theme.bodySize
                    font.italic: true
                }
            }

            Behavior on Layout.preferredHeight {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Core.Theme.divider
        }

        // Attached image preview
        Rectangle {
            id: attachmentPreview
            Layout.fillWidth: true
            Layout.preferredHeight: hasAttachedImage ? 80 : 0
            visible: hasAttachedImage
            color: Core.Theme.surfaceElevated
            clip: true

            Behavior on Layout.preferredHeight {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: Core.Theme.spacingSmall
                spacing: Core.Theme.spacingSmall

                Rectangle {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 60
                    radius: 8
                    color: Core.Theme.background
                    clip: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: 2
                        source: attachedImagePath ? "file://" + attachedImagePath : ""
                        fillMode: Image.PreserveAspectCrop
                        visible: attachedImagePath !== ""
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "📷"
                        font.pixelSize: 24
                        visible: attachedImagePath === "" && attachedImageB64 !== ""
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "📎 Image attached"
                        color: Core.Theme.textPrimary
                        font.pixelSize: Core.Theme.bodySize
                        font.bold: true
                    }

                    Text {
                        text: "Type a question or send to analyze"
                        color: Core.Theme.textSecondary
                        font.pixelSize: Core.Theme.captionSize
                    }
                }

                Button {
                    text: "✕"
                    font.pixelSize: 16
                    onClicked: clearAttachedImage()

                    background: Rectangle {
                        color: parent.hovered ? Core.Theme.error : Core.Theme.surface
                        radius: 16
                        implicitWidth: 32
                        implicitHeight: 32
                    }

                    contentItem: Text {
                        text: "✕"
                        color: parent.hovered ? "#FFFFFF" : Core.Theme.textSecondary
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    ToolTip.visible: hovered
                    ToolTip.text: "Remove image"
                }
            }
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

                Button {
                    id: galleryButton
                    text: "🖼️"
                    font.pixelSize: 20
                    enabled: !isLoading && !hasAttachedImage
                    onClicked: openGalleryPicker()

                    ToolTip.visible: hovered
                    ToolTip.text: "Attach image for Visual Q&A"

                    background: Rectangle {
                        color: galleryButton.hovered ? Core.Theme.surfaceElevated : "transparent"
                        radius: 20
                        opacity: galleryButton.enabled ? 1.0 : 0.5
                    }
                }

                Button {
                    id: cameraButton
                    text: "📷"
                    font.pixelSize: 20
                    enabled: !isLoading && !hasAttachedImage
                    onClicked: classifyMockImage()

                    ToolTip.visible: hovered
                    ToolTip.text: "Quick capture & classify"

                    background: Rectangle {
                        color: cameraButton.hovered ? Core.Theme.surfaceElevated : "transparent"
                        radius: 20
                        opacity: cameraButton.enabled ? 1.0 : 0.5
                    }
                }

                TextField {
                    id: messageInput
                    Layout.fillWidth: true
                    placeholderText: hasAttachedImage ? "Ask about this image..." : "Ask me anything..."
                    font.pixelSize: Core.Theme.bodySize
                    enabled: !isLoading

                    background: Rectangle {
                        color: Core.Theme.background
                        radius: 20
                        border.color: messageInput.activeFocus ? Core.Theme.accent : Core.Theme.divider
                        border.width: messageInput.activeFocus ? 2 : 1
                    }

                    leftPadding: 16
                    rightPadding: 16

                    Keys.onReturnPressed: {
                        sendMessage(text)
                    }
                }

                Button {
                    id: sendButton
                    text: isLoading ? "..." : (hasAttachedImage ? "Ask" : "Send")
                    enabled: (messageInput.text.trim().length > 0 || hasAttachedImage) && !isLoading

                    background: Rectangle {
                        color: sendButton.enabled ? Core.Theme.primary : Core.Theme.disabled
                        radius: 20
                    }

                    contentItem: Text {
                        text: sendButton.text
                        color: sendButton.enabled ? "#FFFFFF" : Core.Theme.textDisabled
                        font.pixelSize: Core.Theme.bodySize
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        sendMessage(messageInput.text)
                    }
                }
            }
        }
    }

    // Toast for errors
    Core.Toast {
        id: toast
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 80
    }

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

    // Clear chat confirmation dialog
    Dialog {
        id: clearChatDialog
        title: "Clear Chat"
        modal: true
        anchors.centerIn: parent
        width: 280

        background: Rectangle {
            color: Core.Theme.surface
            radius: 12
        }

        contentItem: ColumnLayout {
            spacing: Core.Theme.spacingMedium

            Text {
                text: "Are you sure you want to clear all messages?"
                color: Core.Theme.textPrimary
                font.pixelSize: Core.Theme.bodySize
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Core.Theme.spacingSmall

                Button {
                    text: "Cancel"
                    Layout.fillWidth: true
                    onClicked: clearChatDialog.close()
                }

                Button {
                    text: "Clear"
                    Layout.fillWidth: true
                    onClicked: {
                        clearChat()
                        clearChatDialog.close()
                    }

                    background: Rectangle {
                        color: Core.Theme.error
                        radius: 4
                    }

                    contentItem: Text {
                        text: "Clear"
                        color: "#FFFFFF"
                        font.pixelSize: Core.Theme.bodySize
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }

    FileDialog {
        id: imageFileDialog
        title: "Select an image to classify"
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
        return hours + ":" + mins
    }

    function getModelDisplayName(modelId) {
        for (var i = 0; i < availableModels.length; i++) {
            if (availableModels[i].id === modelId) {
                return availableModels[i].name
            }
        }
        return modelId
    }

    function getModelIndex(modelId) {
        for (var i = 0; i < availableModels.length; i++) {
            if (availableModels[i].id === modelId) {
                return i
            }
        }
        return 0
    }
}
