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

    // Tactical background
    Core.TacticalBackground {
        anchors.fill: parent
        z: 0
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        z: 10

        // Header using PageHeader component
        Core.PageHeader {
            Layout.fillWidth: true
            title: "Gallery"
            showBack: true
            onBackClicked: closeRequested()
        }

        // Status bar
        Rectangle {
            Layout.fillWidth: true
            height: 24
            color: Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.2)

            Row {
                anchors.centerIn: parent
                spacing: 6

                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: Core.Theme.warning
                    anchors.verticalCenter: parent.verticalCenter

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.4; duration: 1000 }
                        NumberAnimation { to: 1.0; duration: 1000 }
                    }
                }

                Text {
                    text: photos.length + " photos"
                    color: Core.Theme.textSecondary
                    font.pixelSize: 10
                    font.family: Core.Theme.fontFamilyMono
                    font.letterSpacing: 2
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // Main content
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Loading state
            Item {
                anchors.fill: parent
                visible: isLoading

                Core.LoadingIndicator {
                    anchors.centerIn: parent
                    size: "large"
                    color: Core.Theme.warning
                }
            }

            // Empty state
            Core.EmptyState {
                anchors.fill: parent
                anchors.margins: Core.Theme.spacingLarge
                visible: !isLoading && photos.length === 0

                iconName: "camera"
                title: "No Photos Yet"
                message: "Gallery database is empty. Initialize camera sensor to capture first tactical asset."
                actionText: "Open Camera"
                actionIcon: "camera-iris"

                onActionClicked: {
                    var shell = gallery.parent
                    while (shell && !shell.hasOwnProperty("navigateTo")) {
                        shell = shell.parent
                    }
                    if (shell && shell.navigateTo) {
                        shell.navigateTo("Camera")
                    }
                }
            }

            // Photo grid
            GridView {
                id: photoGrid
                anchors.fill: parent
                visible: !isLoading && photos.length > 0
                clip: true

                // Minimal gap like in the HTML design
                cellWidth: Math.floor(width / 3)
                cellHeight: cellWidth

                model: photos

                delegate: Item {
                    width: photoGrid.cellWidth
                    height: photoGrid.cellHeight

                    PhotoTile {
                        anchors.fill: parent
                        anchors.margins: 1  // 0.5 gap equivalent

                        photo: modelData
                        photoIndex: index

                        onClicked: {
                            openPhotoViewer(index)
                        }
                    }
                }
            }
        }
    }

    // Photo tile component
    component PhotoTile: Rectangle {
        id: tile

        property var photo: null
        property int photoIndex: 0
        property string photoUrl: ""
        property string status: photo ? (photo.status || "ready") : "loading"

        signal clicked()

        color: Core.Theme.surface
        clip: true

        // Get photo URL
        Component.onCompleted: {
            if (photo && CameraBridge) {
                photoUrl = CameraBridge.getPhotoUrl(photo.id)
            }
        }

        // Normal photo state
        Image {
            id: thumbnail
            anchors.fill: parent
            visible: tile.status === "ready" || tile.status === undefined
            source: tile.photoUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            opacity: mouseArea.containsMouse ? 1.0 : 0.9

            // Scale on hover
            scale: mouseArea.containsMouse ? 1.05 : 1.0
            Behavior on scale {
                NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
            }
            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }

            // Hover overlay gradient
            Rectangle {
                anchors.fill: parent
                opacity: mouseArea.containsMouse ? 1.0 : 0.0
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: "transparent" }
                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.8) }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 300 }
                }
            }
        }

        // Loading state (while image loads)
        Item {
            anchors.fill: parent
            visible: thumbnail.status === Image.Loading

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.2)
                border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.1)
                border.width: 1

                // Pulse animation
                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.05)

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 1.0; duration: 1000 }
                        NumberAnimation { to: 0.3; duration: 1000 }
                    }
                }

                Core.MaterialIcon {
                    anchors.centerIn: parent
                    name: "image"
                    size: 32
                    iconColor: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.2)
                }
            }
        }

        // Syncing state
        Item {
            anchors.fill: parent
            visible: tile.status === "syncing"

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.2)
                border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.1)
                border.width: 1

                // Pulse background
                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.05)

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 1.0; duration: 1000 }
                        NumberAnimation { to: 0.3; duration: 1000 }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 8

                    // Spinner
                    Item {
                        width: 32
                        height: 32
                        anchors.horizontalCenter: parent.horizontalCenter

                        Rectangle {
                            anchors.fill: parent
                            radius: 16
                            color: "transparent"
                            border.width: 2
                            border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
                        }

                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: "transparent"
                            border.width: 2
                            border.color: Core.Theme.warning

                            // Arc effect using clip
                            Rectangle {
                                anchors.right: parent.right
                                anchors.top: parent.top
                                width: parent.width / 2
                                height: parent.height
                                color: Core.Theme.surface
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
                        text: "SYNCING"
                        color: Core.Theme.textSecondary
                        font.pixelSize: 9
                        font.family: Core.Theme.fontFamilyMono
                        font.letterSpacing: 2
                        opacity: 0.7
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }

        // Failed state
        Item {
            anchors.fill: parent
            visible: tile.status === "failed" || thumbnail.status === Image.Error

            Rectangle {
                anchors.fill: parent
                color: "#1a0f0f"
                border.color: Qt.rgba(Core.Theme.error.r, Core.Theme.error.g, Core.Theme.error.b, 0.3)
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Core.MaterialIcon {
                        name: "image-broken"
                        size: 32
                        iconColor: Qt.rgba(Core.Theme.error.r, Core.Theme.error.g, Core.Theme.error.b, 0.6)
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "FAILED"
                        color: Qt.rgba(Core.Theme.error.r, Core.Theme.error.g, Core.Theme.error.b, 0.8)
                        font.pixelSize: 9
                        font.family: Core.Theme.fontFamilyMono
                        font.letterSpacing: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                // Hover border
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.width: 2
                    border.color: mouseArea.containsMouse ? Qt.rgba(Core.Theme.error.r, Core.Theme.error.g, Core.Theme.error.b, 0.2) : "transparent"
                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }
                }
            }
        }

        // RAW badge
        Rectangle {
            visible: photo && photo.isRaw
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 4
            width: rawLabel.width + 6
            height: 14
            radius: 2
            color: Qt.rgba(0, 0, 0, 0.7)
            border.color: Qt.rgba(1, 1, 1, 0.1)
            border.width: 1

            Text {
                id: rawLabel
                anchors.centerIn: parent
                text: "RAW"
                color: Core.Theme.warning
                font.pixelSize: 8
                font.family: Core.Theme.fontFamilyMono
                font.weight: Font.Bold
            }
        }

        // Location indicator
        Core.MaterialIcon {
            visible: photo && photo.hasLocation
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: 4
            name: "map-marker"
            size: 14
            iconColor: Qt.rgba(1, 1, 1, 0.8)

            // Drop shadow effect
            Rectangle {
                anchors.centerIn: parent
                width: 20
                height: 20
                radius: 10
                color: Qt.rgba(0, 0, 0, 0.5)
                z: -1
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: tile.clicked()
        }
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
        if (typeof CameraBridge !== "undefined" && CameraBridge) {
            photos = CameraBridge.getPhotos()
        } else {
            photos = []
        }
        isLoading = false
    }

    // Connect to photo changes
    Connections {
        target: typeof CameraBridge !== "undefined" ? CameraBridge : null
        enabled: typeof CameraBridge !== "undefined" && CameraBridge !== null

        function onPhotosChanged() {
            refreshPhotos()
        }
    }

    Component.onCompleted: {
        refreshPhotos()
    }
}
