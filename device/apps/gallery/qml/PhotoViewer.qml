import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

Rectangle {
    id: viewer
    color: Core.Theme.background

    signal closeRequested()

    // Properties passed from Gallery
    property string photoId: ""
    property int photoIndex: 0
    property var photos: []

    // State
    property string currentPhotoUrl: ""
    property var currentPhoto: null
    property bool confirmDelete: false
    property bool isLoading: true
    property bool hasError: false

    // Grid pattern background
    Canvas {
        anchors.fill: parent
        z: 0
        opacity: 0.15

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.strokeStyle = Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
            ctx.lineWidth = 1

            var gridSize = 40

            for (var x = 0; x <= width; x += gridSize) {
                ctx.beginPath()
                ctx.moveTo(x, 0)
                ctx.lineTo(x, height)
                ctx.stroke()
            }

            for (var y = 0; y <= height; y += gridSize) {
                ctx.beginPath()
                ctx.moveTo(0, y)
                ctx.lineTo(width, y)
                ctx.stroke()
            }
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    // Load photo data
    Component.onCompleted: {
        if (typeof CameraBridge !== "undefined" && CameraBridge) {
            photos = CameraBridge.getPhotos()
            updateCurrentPhoto()
        }
    }

    function updateCurrentPhoto() {
        if (photoIndex >= 0 && photoIndex < photos.length) {
            currentPhoto = photos[photoIndex]
            photoId = currentPhoto.id
            isLoading = true
            hasError = false
            if (typeof CameraBridge !== "undefined" && CameraBridge) {
                currentPhotoUrl = CameraBridge.getPhotoUrl(photoId)
            }
        }
    }

    function goToPrevious() {
        if (photoIndex > 0) {
            photoIndex--
            updateCurrentPhoto()
        }
    }

    function goToNext() {
        if (photoIndex < photos.length - 1) {
            photoIndex++
            updateCurrentPhoto()
        }
    }

    function deleteCurrentPhoto() {
        if (typeof CameraBridge !== "undefined" && CameraBridge && photoId) {
            var success = CameraBridge.deletePhoto(photoId)
            if (success) {
                photos = CameraBridge.getPhotos()
                if (photos.length === 0) {
                    closeRequested()
                } else if (photoIndex >= photos.length) {
                    photoIndex = photos.length - 1
                    updateCurrentPhoto()
                } else {
                    updateCurrentPhoto()
                }
            }
        }
        confirmDelete = false
    }

    // === LOADING STATE ===
    Item {
        anchors.fill: parent
        visible: isLoading && !hasError
        z: 5

        Column {
            anchors.centerIn: parent
            spacing: 12

            // Spinner
            Item {
                width: 40
                height: 40
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    anchors.fill: parent
                    radius: 20
                    color: "transparent"
                    border.width: 2
                    border.color: Core.Theme.surface
                }

                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: "transparent"
                    border.width: 2
                    border.color: Core.Theme.warning

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        width: parent.width / 2 + 2
                        height: parent.height
                        color: Core.Theme.background
                    }

                    RotationAnimation on rotation {
                        loops: Animation.Infinite
                        from: 0
                        to: 360
                        duration: 1000
                    }
                }
            }

            Text {
                text: "LOADING ASSET..."
                color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.5)
                font.pixelSize: 10
                font.family: Core.Theme.fontFamilyMono
                font.letterSpacing: 2
                anchors.horizontalCenter: parent.horizontalCenter

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.3; duration: 800 }
                    NumberAnimation { to: 1.0; duration: 800 }
                }
            }
        }
    }

    // === ERROR STATE ===
    Item {
        anchors.fill: parent
        visible: hasError
        z: 15

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(Core.Theme.background.r, Core.Theme.background.g, Core.Theme.background.b, 0.95)
        }

        Column {
            anchors.centerIn: parent
            spacing: 12
            width: parent.width * 0.85

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(280, parent.width)
                height: errorContent.height + 48
                color: Qt.rgba(0.3, 0.1, 0.1, 0.1)
                border.color: Qt.rgba(0.5, 0.2, 0.2, 0.3)
                border.width: 1
                radius: 8

                Column {
                    id: errorContent
                    anchors.centerIn: parent
                    spacing: 12
                    width: parent.width - 48

                    Core.MaterialIcon {
                        name: "image-broken"
                        size: 36
                        iconColor: Qt.rgba(Core.Theme.error.r, Core.Theme.error.g, Core.Theme.error.b, 0.8)
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "LOAD FAILURE"
                        color: Qt.rgba(Core.Theme.error.r, Core.Theme.error.g, Core.Theme.error.b, 0.9)
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        font.letterSpacing: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "ERR_CORRUPTED_FILE_0x84F"
                        color: Qt.rgba(Core.Theme.error.r, Core.Theme.error.g, Core.Theme.error.b, 0.5)
                        font.pixelSize: 10
                        font.family: Core.Theme.fontFamilyMono
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Item { width: 1; height: 8 }

                    Rectangle {
                        width: 100
                        height: 36
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "transparent"
                        border.color: Qt.rgba(Core.Theme.error.r, Core.Theme.error.g, Core.Theme.error.b, 0.3)
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "RETRY"
                            color: Qt.rgba(Core.Theme.error.r, Core.Theme.error.g, Core.Theme.error.b, 0.8)
                            font.pixelSize: 10
                            font.family: Core.Theme.fontFamilyMono
                            font.letterSpacing: 2
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                hasError = false
                                isLoading = true
                                photoImage.source = ""
                                photoImage.source = currentPhotoUrl
                            }
                        }
                    }
                }
            }
        }
    }

    // === PHOTO DISPLAY ===
    Image {
        id: photoImage
        anchors.fill: parent
        z: 10
        source: currentPhotoUrl
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        visible: !hasError

        onStatusChanged: {
            if (status === Image.Ready) {
                isLoading = false
                hasError = false
            } else if (status === Image.Error) {
                isLoading = false
                hasError = true
            }
        }
    }

    // Tap area to toggle controls (not needed anymore - controls always visible)
    MouseArea {
        anchors.fill: parent
        z: 11

        // Swipe gestures
        property real startX: 0
        property real threshold: 100

        onPressed: {
            startX = mouseX
        }

        onReleased: {
            var deltaX = mouseX - startX
            if (Math.abs(deltaX) > threshold) {
                if (deltaX > 0) {
                    goToPrevious()
                } else {
                    goToNext()
                }
            }
        }
    }

    // === NAVIGATION: PREVIOUS ===
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 80
        z: 20
        visible: photoIndex > 0
        color: prevArea.containsMouse ? Qt.rgba(0, 0, 0, 0.6) : "transparent"

        gradient: prevArea.containsMouse ? prevGradient : null

        Gradient {
            id: prevGradient
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.6) }
            GradientStop { position: 1.0; color: "transparent" }
        }

        Core.MaterialIcon {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            name: "chevron-left"
            size: 48
            iconColor: prevArea.containsMouse ? Core.Theme.warning : Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.3)
            scale: prevArea.pressed ? 0.9 : 1.0
            Behavior on iconColor { ColorAnimation { duration: 200 } }
            Behavior on scale { NumberAnimation { duration: 100 } }
        }

        MouseArea {
            id: prevArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: goToPrevious()
        }
    }

    // === NAVIGATION: NEXT ===
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 80
        z: 20
        visible: photoIndex < photos.length - 1
        color: "transparent"

        gradient: nextArea.containsMouse ? nextGradient : null

        Gradient {
            id: nextGradient
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.6) }
        }

        Core.MaterialIcon {
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            name: "chevron-right"
            size: 48
            iconColor: nextArea.containsMouse ? Core.Theme.warning : Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.3)
            scale: nextArea.pressed ? 0.9 : 1.0
            Behavior on iconColor { ColorAnimation { duration: 200 } }
            Behavior on scale { NumberAnimation { duration: 100 } }
        }

        MouseArea {
            id: nextArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: goToNext()
        }
    }

    // === TOP BAR ===
    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        z: 30

        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.95) }
            GradientStop { position: 0.5; color: Qt.rgba(0, 0, 0, 0.7) }
            GradientStop { position: 1.0; color: "transparent" }
        }

        RowLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 16
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            height: 48

            // Back button
            Rectangle {
                width: 48
                height: 48
                radius: 24
                color: backArea.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                Layout.alignment: Qt.AlignVCenter

                Behavior on color { ColorAnimation { duration: 150 } }

                Core.MaterialIcon {
                    anchors.centerIn: parent
                    name: "arrow-left"
                    size: 24
                    iconColor: backArea.containsMouse ? Core.Theme.textPrimary : Core.Theme.textSecondary
                    Behavior on iconColor { ColorAnimation { duration: 150 } }
                }

                MouseArea {
                    id: backArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: closeRequested()
                }
            }

            Item { Layout.fillWidth: true }

            // Photo counter badge
            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                width: counterRow.width + 24
                height: 32
                radius: 16
                color: Qt.rgba(0, 0, 0, 0.4)
                border.color: Qt.rgba(1, 1, 1, 0.05)
                border.width: 1

                Row {
                    id: counterRow
                    anchors.centerIn: parent
                    spacing: 0

                    Text {
                        text: String(photoIndex + 1).padStart(2, '0')
                        color: Core.Theme.warning
                        font.pixelSize: 14
                        font.family: Core.Theme.fontFamilyMono
                        font.weight: Font.Bold
                        font.letterSpacing: 2
                    }

                    Text {
                        text: "/"
                        color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.5)
                        font.pixelSize: 14
                        font.family: Core.Theme.fontFamilyMono
                        leftPadding: 4
                        rightPadding: 4
                    }

                    Text {
                        text: String(photos.length).padStart(2, '0')
                        color: Core.Theme.textPrimary
                        font.pixelSize: 14
                        font.family: Core.Theme.fontFamilyMono
                        font.weight: Font.Bold
                        font.letterSpacing: 2
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Delete button
            Rectangle {
                width: 48
                height: 48
                radius: 24
                color: deleteArea.containsMouse ? Qt.rgba(0.5, 0.1, 0.1, 0.1) : "transparent"
                Layout.alignment: Qt.AlignVCenter

                Behavior on color { ColorAnimation { duration: 150 } }

                Core.MaterialIcon {
                    anchors.centerIn: parent
                    name: "delete"
                    size: 24
                    iconColor: deleteArea.containsMouse ? Core.Theme.error : Core.Theme.textSecondary
                    Behavior on iconColor { ColorAnimation { duration: 150 } }
                }

                MouseArea {
                    id: deleteArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: confirmDelete = true
                }
            }
        }
    }

    // === BOTTOM BAR ===
    Rectangle {
        id: bottomBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 140
        z: 30

        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.3; color: Qt.rgba(0, 0, 0, 0.8) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.95) }
        }

        Column {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottomMargin: 32
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            spacing: 8

            // Filename and RAW badge row
            RowLayout {
                width: parent.width
                spacing: 16

                Text {
                    text: currentPhoto ? currentPhoto.filename : ""
                    color: Core.Theme.textPrimary
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    font.letterSpacing: 1
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                // RAW badge
                Rectangle {
                    visible: currentPhoto && currentPhoto.isRaw
                    width: rawLabel.width + 12
                    height: 24
                    radius: 4
                    color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.1)
                    border.color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.2)
                    border.width: 1

                    Text {
                        id: rawLabel
                        anchors.centerIn: parent
                        text: "RAW"
                        color: Core.Theme.warning
                        font.pixelSize: 10
                        font.family: Core.Theme.fontFamilyMono
                        font.weight: Font.Bold
                        font.letterSpacing: 2
                    }
                }
            }

            // Metadata row
            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(1, 1, 1, 0.1)
            }

            RowLayout {
                width: parent.width
                spacing: 20

                // Date
                Row {
                    spacing: 8

                    Core.MaterialIcon {
                        name: "calendar"
                        size: 16
                        iconColor: Core.Theme.divider
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: currentPhoto ? formatDate(currentPhoto.timestamp) : ""
                        color: Core.Theme.textSecondary
                        font.pixelSize: 12
                        font.family: Core.Theme.fontFamilyMono
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Time
                Row {
                    spacing: 8

                    Core.MaterialIcon {
                        name: "timer"
                        size: 16
                        iconColor: Core.Theme.divider
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: currentPhoto ? formatTime(currentPhoto.timestamp) : ""
                        color: Core.Theme.textSecondary
                        font.pixelSize: 12
                        font.family: Core.Theme.fontFamilyMono
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Item { Layout.fillWidth: true }

                // File size
                Text {
                    text: currentPhoto ? formatFileSize(currentPhoto.size_bytes) : ""
                    color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.7)
                    font.pixelSize: 12
                    font.family: Core.Theme.fontFamilyMono
                    font.weight: Font.Bold
                }
            }
        }
    }

    // === DELETE CONFIRMATION MODAL ===
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.8)
        visible: confirmDelete
        z: 50
        opacity: confirmDelete ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: confirmDelete = false
        }

        Rectangle {
            id: deleteModal
            anchors.centerIn: parent
            width: parent.width * 0.85
            height: modalContent.height + 48
            color: "#0D120D"
            border.color: Core.Theme.surface
            border.width: 1
            scale: confirmDelete ? 1 : 0.95

            Behavior on scale {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }

            // Corner decorations
            Rectangle { anchors.top: parent.top; anchors.left: parent.left; width: 12; height: 2; color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.8) }
            Rectangle { anchors.top: parent.top; anchors.left: parent.left; width: 2; height: 12; color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.8) }
            Rectangle { anchors.top: parent.top; anchors.right: parent.right; width: 12; height: 2; color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.8) }
            Rectangle { anchors.top: parent.top; anchors.right: parent.right; width: 2; height: 12; color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.8) }
            Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; width: 12; height: 2; color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.8) }
            Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; width: 2; height: 12; color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.8) }
            Rectangle { anchors.bottom: parent.bottom; anchors.right: parent.right; width: 12; height: 2; color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.8) }
            Rectangle { anchors.bottom: parent.bottom; anchors.right: parent.right; width: 2; height: 12; color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.8) }

            Column {
                id: modalContent
                anchors.centerIn: parent
                width: parent.width - 48
                spacing: 0

                // Header with icon
                RowLayout {
                    width: parent.width
                    spacing: 12

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 4
                        color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.1)
                        border.color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.2)
                        border.width: 1

                        Core.MaterialIcon {
                            anchors.centerIn: parent
                            name: "alert"
                            size: 24
                            iconColor: Core.Theme.warning
                        }
                    }

                    Column {
                        spacing: 2
                        Layout.fillWidth: true

                        Text {
                            text: "CONFIRM DELETE"
                            color: Core.Theme.textPrimary
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            font.letterSpacing: 2
                        }

                        Text {
                            text: "ACTION IRREVERSIBLE"
                            color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.8)
                            font.pixelSize: 10
                            font.family: Core.Theme.fontFamilyMono
                            font.letterSpacing: 2
                        }
                    }
                }

                // Divider
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.05)
                    anchors.topMargin: 16
                }

                Item { width: 1; height: 20 }

                // Message
                Text {
                    width: parent.width
                    text: "Delete file <font color='" + Core.Theme.textPrimary + "'>" + (currentPhoto ? currentPhoto.filename : "") + "</font> from storage?"
                    color: Core.Theme.textSecondary
                    font.pixelSize: 14
                    textFormat: Text.RichText
                    wrapMode: Text.WordWrap
                }

                Item { width: 1; height: 24 }

                // Buttons
                RowLayout {
                    width: parent.width
                    spacing: 12

                    // Cancel button
                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        color: cancelBtnArea.containsMouse ? Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.2) : Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.1)
                        border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.4)
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: "CANCEL"
                            color: cancelBtnArea.containsMouse ? Core.Theme.textPrimary : Core.Theme.textSecondary
                            font.pixelSize: 12
                            font.family: Core.Theme.fontFamilyMono
                            font.weight: Font.Bold
                            font.letterSpacing: 2

                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        MouseArea {
                            id: cancelBtnArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: confirmDelete = false
                        }
                    }

                    // Delete button
                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        color: deleteBtnArea.containsMouse ? Qt.rgba(0.5, 0.1, 0.1, 0.6) : Qt.rgba(0.3, 0.05, 0.05, 0.4)
                        border.color: deleteBtnArea.containsMouse ? Qt.rgba(Core.Theme.error.r, Core.Theme.error.g, Core.Theme.error.b, 0.5) : Qt.rgba(0.5, 0.2, 0.2, 0.4)
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        Row {
                            anchors.centerIn: parent
                            spacing: 8

                            Core.MaterialIcon {
                                name: "delete"
                                size: 14
                                iconColor: deleteBtnArea.containsMouse ? Qt.rgba(1, 0.8, 0.8, 1) : Qt.rgba(Core.Theme.error.r, Core.Theme.error.g, Core.Theme.error.b, 0.9)
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: "DELETE"
                                color: deleteBtnArea.containsMouse ? Qt.rgba(1, 0.8, 0.8, 1) : Qt.rgba(Core.Theme.error.r, Core.Theme.error.g, Core.Theme.error.b, 0.9)
                                font.pixelSize: 12
                                font.family: Core.Theme.fontFamilyMono
                                font.weight: Font.Bold
                                font.letterSpacing: 2
                                anchors.verticalCenter: parent.verticalCenter

                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }

                        MouseArea {
                            id: deleteBtnArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: deleteCurrentPhoto()
                        }
                    }
                }
            }
        }
    }

    // Helper functions
    function formatDate(timestamp) {
        if (!timestamp) return ""
        var date = new Date(timestamp)
        var year = date.getFullYear()
        var month = String(date.getMonth() + 1).padStart(2, '0')
        var day = String(date.getDate()).padStart(2, '0')
        return year + "-" + month + "-" + day
    }

    function formatTime(timestamp) {
        if (!timestamp) return ""
        var date = new Date(timestamp)
        var hours = String(date.getHours()).padStart(2, '0')
        var minutes = String(date.getMinutes()).padStart(2, '0')
        var seconds = String(date.getSeconds()).padStart(2, '0')
        return hours + ":" + minutes + ":" + seconds
    }

    function formatFileSize(bytes) {
        if (!bytes) return ""
        if (bytes < 1024) return bytes + " B"
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB"
        return (bytes / (1024 * 1024)).toFixed(1) + " MB"
    }
}
