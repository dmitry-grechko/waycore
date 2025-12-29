import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

Rectangle {
    id: gallery
    color: Core.Theme.background

    // Standard app interface
    property string appId: "com.waycore.gallery"
    property string appTitle: "Gallery"
    signal closeRequested()

    property var photos: []
    property bool isLoading: false

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            height: 60
            color: Core.Theme.surface

            RowLayout {
                anchors.fill: parent
                anchors.margins: Core.Theme.spacingSmall

                Button {
                    text: "← Back"
                    onClicked: closeRequested()
                }

                Text {
                    text: "Gallery"
                    color: Core.Theme.textPrimary
                    font.pixelSize: Core.Theme.h2Size
                    font.bold: true
                    Layout.fillWidth: true
                }

                Text {
                    text: photos.length + " photos"
                    color: Core.Theme.textSecondary
                    font.pixelSize: Core.Theme.captionSize
                }
            }
        }

        // Loading indicator
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: isLoading

            BusyIndicator {
                anchors.centerIn: parent
                running: isLoading
            }
        }

        // Empty state
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !isLoading && photos.length === 0

            Column {
                anchors.centerIn: parent
                spacing: Core.Theme.spacingMedium

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "📷"
                    font.pixelSize: 64
                    opacity: 0.5
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "No photos yet"
                    color: Core.Theme.textSecondary
                    font.pixelSize: Core.Theme.h3Size
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Capture your first photo"
                    color: Core.Theme.textSecondary
                    font.pixelSize: Core.Theme.bodySize
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "📷 Open Camera"
                    onClicked: {
                        var shell = gallery.parent
                        while (shell && !shell.hasOwnProperty("navigateTo")) {
                            shell = shell.parent
                        }
                        if (shell && shell.navigateTo) {
                            shell.navigateTo("Camera")
                        }
                    }
                }
            }
        }

        // Photo grid
        GridView {
            id: photoGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Core.Theme.spacingSmall
            visible: !isLoading && photos.length > 0
            clip: true

            cellWidth: Math.floor(width / 3)
            cellHeight: cellWidth

            model: photos.length

            delegate: Rectangle {
                width: photoGrid.cellWidth - 4
                height: photoGrid.cellHeight - 4
                color: Core.Theme.surface
                radius: 4

                Image {
                    id: thumbnail
                    anchors.fill: parent
                    anchors.margins: 2
                    fillMode: Image.PreserveAspectCrop
                    source: getPhotoUrl(index)
                    asynchronous: true

                    // Loading placeholder
                    Rectangle {
                        anchors.fill: parent
                        color: Core.Theme.surfaceElevated
                        visible: thumbnail.status === Image.Loading

                        Text {
                            anchors.centerIn: parent
                            text: "🖼️"
                            font.pixelSize: 24
                            opacity: 0.5
                        }
                    }

                    // Error state
                    Rectangle {
                        anchors.fill: parent
                        color: Core.Theme.surfaceElevated
                        visible: thumbnail.status === Image.Error

                        Text {
                            anchors.centerIn: parent
                            text: "⚠️"
                            font.pixelSize: 24
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        openPhotoViewer(index)
                    }
                }
            }
        }
    }

    function getPhotoUrl(index) {
        if (index >= 0 && index < photos.length) {
            var photo = photos[index]
            if (CameraBridge) {
                return CameraBridge.getPhotoUrl(photo.id)
            }
        }
        return ""
    }

    function openPhotoViewer(index) {
        if (index >= 0 && index < photos.length) {
            var photo = photos[index]
            var shell = gallery.parent
            while (shell && !shell.hasOwnProperty("openPhotoViewer")) {
                shell = shell.parent
            }
            if (shell && shell.openPhotoViewer) {
                shell.openPhotoViewer(photo.id, index)
            }
        }
    }

    function refreshPhotos() {
        isLoading = true
        if (CameraBridge) {
            photos = CameraBridge.getPhotos()
        }
        isLoading = false
    }

    // Connect to photo changes
    Connections {
        target: CameraBridge

        function onPhotosChanged() {
            refreshPhotos()
        }
    }

    Component.onCompleted: {
        refreshPhotos()
    }
}
