import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

Rectangle {
    id: viewer
    color: "#000000"

    signal closeRequested()

    // Properties passed from Gallery
    property string photoId: ""
    property int photoIndex: 0
    property var photos: []

    // State
    property string currentPhotoUrl: ""
    property var currentPhoto: null
    property bool showControls: true
    property bool confirmDelete: false

    // Load photo data
    Component.onCompleted: {
        if (CameraBridge) {
            photos = CameraBridge.getPhotos()
            updateCurrentPhoto()
        }
    }

    function updateCurrentPhoto() {
        if (photoIndex >= 0 && photoIndex < photos.length) {
            currentPhoto = photos[photoIndex]
            photoId = currentPhoto.id
            if (CameraBridge) {
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
        if (CameraBridge && photoId) {
            var success = CameraBridge.deletePhoto(photoId)
            if (success) {
                // Refresh and navigate
                photos = CameraBridge.getPhotos()
                if (photos.length === 0) {
                    // Go back to gallery
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

    // Photo display
    Image {
        id: photoImage
        anchors.fill: parent
        source: currentPhotoUrl
        fillMode: Image.PreserveAspectFit
        asynchronous: true

        // Loading state
        BusyIndicator {
            anchors.centerIn: parent
            running: photoImage.status === Image.Loading
            visible: photoImage.status === Image.Loading
        }

        // Error state
        Column {
            anchors.centerIn: parent
            visible: photoImage.status === Image.Error
            spacing: Core.Theme.spacingSmall

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "⚠️"
                font.pixelSize: 48
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Failed to load photo"
                color: Core.Theme.warning
                font.pixelSize: 16
            }
        }
    }

    // Tap to toggle controls
    MouseArea {
        anchors.fill: parent
        onClicked: {
            showControls = !showControls
        }

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

    // Top bar (controls)
    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: Qt.rgba(0, 0, 0, 0.7)
        opacity: showControls ? 1 : 0
        z: 10

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: Core.Theme.spacingSmall

            Button {
                text: "← Back"
                background: Rectangle {
                    color: Qt.rgba(1, 1, 1, 0.2)
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: closeRequested()
            }

            Item { Layout.fillWidth: true }

            Text {
                text: (photoIndex + 1) + " / " + photos.length
                color: "white"
                font.pixelSize: 14
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "🗑️ Delete"
                background: Rectangle {
                    color: Qt.rgba(1, 0, 0, 0.3)
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    confirmDelete = true
                }
            }
        }
    }

    // Bottom bar (metadata)
    Rectangle {
        id: bottomBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: Qt.rgba(0, 0, 0, 0.7)
        opacity: showControls ? 1 : 0
        z: 10

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: Core.Theme.spacingSmall

            Column {
                spacing: 2

                Text {
                    text: currentPhoto ? currentPhoto.filename : ""
                    color: "white"
                    font.pixelSize: 14
                }

                Text {
                    text: currentPhoto ? formatTimestamp(currentPhoto.timestamp) : ""
                    color: Core.Theme.textSecondary
                    font.pixelSize: 12
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: currentPhoto ? formatFileSize(currentPhoto.size_bytes) : ""
                color: Core.Theme.textSecondary
                font.pixelSize: 12
            }
        }
    }

    // Navigation arrows
    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 50
        height: 80
        color: Qt.rgba(0, 0, 0, 0.3)
        radius: 4
        visible: showControls && photoIndex > 0
        z: 10

        Text {
            anchors.centerIn: parent
            text: "◀"
            color: "white"
            font.pixelSize: 24
        }

        MouseArea {
            anchors.fill: parent
            onClicked: goToPrevious()
        }
    }

    Rectangle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 50
        height: 80
        color: Qt.rgba(0, 0, 0, 0.3)
        radius: 4
        visible: showControls && photoIndex < photos.length - 1
        z: 10

        Text {
            anchors.centerIn: parent
            text: "▶"
            color: "white"
            font.pixelSize: 24
        }

        MouseArea {
            anchors.fill: parent
            onClicked: goToNext()
        }
    }

    // Delete confirmation dialog
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.8)
        visible: confirmDelete
        z: 100

        MouseArea {
            anchors.fill: parent
            onClicked: confirmDelete = false
        }

        Rectangle {
            anchors.centerIn: parent
            width: 280
            height: 160
            color: Core.Theme.surface
            radius: 12

            Column {
                anchors.fill: parent
                anchors.margins: Core.Theme.spacingMedium
                spacing: Core.Theme.spacingMedium

                Text {
                    text: "Delete this photo?"
                    color: Core.Theme.textPrimary
                    font.pixelSize: Core.Theme.h3Size
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "This action cannot be undone."
                    color: Core.Theme.textSecondary
                    font.pixelSize: Core.Theme.bodySize
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                RowLayout {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Core.Theme.spacingMedium

                    Button {
                        text: "Cancel"
                        onClicked: confirmDelete = false
                    }

                    Button {
                        text: "Delete"
                        background: Rectangle {
                            color: Core.Theme.error
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: deleteCurrentPhoto()
                    }
                }
            }
        }
    }

    // Helper functions
    function formatTimestamp(timestamp) {
        if (!timestamp) return ""
        var date = new Date(timestamp)
        return date.toLocaleDateString() + " " + date.toLocaleTimeString()
    }

    function formatFileSize(bytes) {
        if (!bytes) return ""
        if (bytes < 1024) return bytes + " B"
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB"
        return (bytes / (1024 * 1024)).toFixed(1) + " MB"
    }
}
