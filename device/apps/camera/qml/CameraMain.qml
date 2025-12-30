import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * CameraMain - Full-screen camera with tactical viewfinder overlay
 *
 * Features:
 * - Full-screen viewfinder with grid pattern
 * - Corner frame brackets
 * - Central focus crosshair
 * - Gallery thumbnail access
 * - Photo capture with flash animation
 */
Rectangle {
    id: camera
    color: "#000000"

    // Standard app interface
    property string appId: "com.waycore.camera"
    property string appTitle: "Camera"
    signal closeRequested()

    // Custom color palette (matching the design)
    QtObject {
        id: cameraColors
        readonly property color background: "#0A0F0A"
        readonly property color surface: "#1B3D2F"
        readonly property color highlight: "#2D5A3D"
        readonly property color accent: "#D4A574"
        readonly property color textSubtle: "#B0C6B0"
        readonly property color textMain: "#FFFFFF"
    }

    // Camera state from CameraBridge
    property bool isReady: CameraBridge ? CameraBridge.isReady : false
    property bool isCapturing: CameraBridge ? CameraBridge.isCapturing : false
    property bool connected: CameraBridge ? CameraBridge.connected : false
    property string lastPhotoUrl: ""

    // Viewfinder background with grid pattern
    Rectangle {
        id: viewfinder
        anchors.fill: parent
        color: "#000000"

        // Grid pattern overlay
        Canvas {
            anchors.fill: parent
            opacity: 0.5
            onPaint: {
                var ctx = getContext("2d")
                ctx.strokeStyle = Qt.rgba(0.18, 0.35, 0.24, 0.1)
                ctx.lineWidth = 1
                var gridSize = 40

                for (var x = 0; x < width; x += gridSize) {
                    ctx.beginPath()
                    ctx.moveTo(x, 0)
                    ctx.lineTo(x, height)
                    ctx.stroke()
                }
                for (var y = 0; y < height; y += gridSize) {
                    ctx.beginPath()
                    ctx.moveTo(0, y)
                    ctx.lineTo(width, y)
                    ctx.stroke()
                }
            }
        }

        // Radial vignette overlay
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: Qt.rgba(0.04, 0.06, 0.04, 0.6) }
            }
        }

        // Simulated camera feed gradient (when connected)
        Rectangle {
            anchors.fill: parent
            visible: connected
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0.1, 0.15, 0.1, 0.3) }
                GradientStop { position: 0.5; color: Qt.rgba(0.05, 0.1, 0.07, 0.2) }
                GradientStop { position: 1.0; color: Qt.rgba(0.1, 0.15, 0.1, 0.3) }
            }

            // Animated scanline effect for "live" feel
            Rectangle {
                id: scanline
                width: parent.width
                height: 2
                color: Qt.rgba(1, 1, 1, 0.05)
                y: 0

                SequentialAnimation on y {
                    running: camera.visible && connected
                    loops: Animation.Infinite
                    NumberAnimation {
                        from: 0
                        to: viewfinder.height
                        duration: 4000
                        easing.type: Easing.Linear
                    }
                }
            }
        }

        // Inner frame rectangle (subtle)
        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.8
            height: parent.height * 0.6
            color: "transparent"
            border.color: Qt.rgba(cameraColors.highlight.r, cameraColors.highlight.g, cameraColors.highlight.b, 0.2)
            border.width: 1
            radius: 4
            opacity: 0.3
        }
    }

    // Corner brackets overlay
    Item {
        anchors.fill: parent
        anchors.margins: 16

        // Top-left corner
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            width: 32
            height: 2
            color: Qt.rgba(1, 1, 1, 0.5)
        }
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            width: 2
            height: 32
            color: Qt.rgba(1, 1, 1, 0.5)
        }

        // Top-right corner
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            width: 32
            height: 2
            color: Qt.rgba(1, 1, 1, 0.5)
        }
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            width: 2
            height: 32
            color: Qt.rgba(1, 1, 1, 0.5)
        }

        // Bottom-left corner
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: 32
            height: 2
            color: Qt.rgba(1, 1, 1, 0.5)
        }
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: 2
            height: 32
            color: Qt.rgba(1, 1, 1, 0.5)
        }

        // Bottom-right corner
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: 32
            height: 2
            color: Qt.rgba(1, 1, 1, 0.5)
        }
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: 2
            height: 32
            color: Qt.rgba(1, 1, 1, 0.5)
        }
    }

    // Central focus crosshair
    Item {
        anchors.centerIn: parent
        width: 64
        height: 64

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: Qt.rgba(1, 1, 1, 0.3)
            border.width: 1
            radius: 8
        }

        // Horizontal crosshair line
        Rectangle {
            anchors.centerIn: parent
            width: 20
            height: 1
            color: Qt.rgba(1, 1, 1, 0.3)
        }

        // Vertical crosshair line
        Rectangle {
            anchors.centerIn: parent
            width: 1
            height: 20
            color: Qt.rgba(1, 1, 1, 0.3)
        }
    }

    // Exposure level indicator (right side)
    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: 4
        height: 96
        radius: 2
        color: Qt.rgba(0, 0, 0, 0.3)

        // Exposure level marker
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 2
            color: cameraColors.accent
        }
    }

    // Disconnected state overlay
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.7)
        visible: !connected

        Column {
            anchors.centerIn: parent
            spacing: 16

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "📷"
                font.pixelSize: 48
                opacity: 0.3
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Camera Unavailable"
                color: cameraColors.accent
                font.pixelSize: 18
                font.weight: Font.Bold
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Check camera service connection"
                color: cameraColors.textSubtle
                font.pixelSize: 14
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 100
                height: 44
                color: retryArea.pressed ? Qt.darker(cameraColors.surface, 1.2) : cameraColors.surface
                border.color: cameraColors.highlight
                border.width: 1
                radius: 4

                Text {
                    anchors.centerIn: parent
                    text: "RETRY"
                    color: cameraColors.textMain
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    font.letterSpacing: 1
                }

                MouseArea {
                    id: retryArea
                    anchors.fill: parent
                    onClicked: {
                        if (CameraBridge) {
                            CameraBridge.refreshStatus()
                        }
                    }
                }
            }
        }
    }

    // White flash overlay for capture effect
    Rectangle {
        id: flashOverlay
        anchors.fill: parent
        color: "white"
        opacity: 0
        z: 100

        SequentialAnimation {
            id: captureAnimation
            PropertyAnimation {
                target: flashOverlay
                property: "opacity"
                to: 0.9
                duration: 50
            }
            PropertyAnimation {
                target: flashOverlay
                property: "opacity"
                to: 0
                duration: 200
            }
        }
    }

    // Top bar with back button
    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 100
        z: 10
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.8) }
            GradientStop { position: 1.0; color: "transparent" }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            anchors.topMargin: 48

            // Back button (matching PageHeader style)
            Rectangle {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                color: "transparent"

                Core.MaterialIcon {
                    anchors.centerIn: parent
                    name: "chevron-left"
                    size: 28
                    iconColor: backArea.containsMouse ? cameraColors.accent : cameraColors.textSubtle

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

            Item { Layout.fillWidth: true }

            // Placeholder for symmetry
            Item {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
            }
        }
    }

    // Toast notification (Photo saved)
    Rectangle {
        id: toast
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 140
        height: 40
        width: toastContent.width + 32
        radius: 20
        color: Qt.rgba(cameraColors.surface.r, cameraColors.surface.g, cameraColors.surface.b, 0.9)
        border.color: cameraColors.highlight
        border.width: 1
        visible: opacity > 0
        opacity: 0
        z: 20

        Row {
            id: toastContent
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: "✓"
                color: cameraColors.accent
                font.pixelSize: 14
            }
            Text {
                text: "Photo saved"
                color: cameraColors.textMain
                font.pixelSize: 14
                font.family: "JetBrains Mono, Consolas, monospace"
                font.weight: Font.Medium
            }
        }

        SequentialAnimation {
            id: toastAnimation
            PropertyAnimation {
                target: toast
                property: "opacity"
                to: 1
                duration: 200
            }
            PauseAnimation { duration: 2000 }
            PropertyAnimation {
                target: toast
                property: "opacity"
                to: 0
                duration: 300
            }
        }
    }

    // Bottom control bar
    Rectangle {
        id: bottomBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 160
        z: 10
        color: Qt.rgba(0, 0, 0, 0.8)

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: Qt.rgba(1, 1, 1, 0.05)
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 32
            anchors.rightMargin: 32
            anchors.topMargin: 32
            anchors.bottomMargin: 48

            // Gallery thumbnail
            Rectangle {
                Layout.preferredWidth: 56
                Layout.preferredHeight: 56
                radius: 8
                color: cameraColors.surface
                border.color: cameraColors.highlight
                border.width: 2

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 2
                    radius: 6
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(cameraColors.highlight.r, cameraColors.highlight.g, cameraColors.highlight.b, 0.5) }
                        GradientStop { position: 1.0; color: "#000000" }
                    }

                    Image {
                        anchors.fill: parent
                        anchors.margins: 2
                        fillMode: Image.PreserveAspectCrop
                        source: lastPhotoUrl
                        visible: lastPhotoUrl !== ""
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "🖼"
                        font.pixelSize: 20
                        visible: lastPhotoUrl === ""
                        opacity: galleryArea.containsMouse ? 1.0 : 0.5
                    }
                }

                MouseArea {
                    id: galleryArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        var shell = camera.parent
                        while (shell && !shell.hasOwnProperty("navigateTo")) {
                            shell = shell.parent
                        }
                        if (shell && shell.navigateTo) {
                            shell.navigateTo("Gallery")
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Shutter button
            Rectangle {
                id: shutterButton
                Layout.preferredWidth: 80
                Layout.preferredHeight: 80
                radius: 40
                color: "transparent"
                border.color: Qt.rgba(1, 1, 1, 0.3)
                border.width: 3

                Rectangle {
                    anchors.centerIn: parent
                    width: 68
                    height: 68
                    radius: 34
                    color: shutterArea.pressed ? "#e0e0e0" : "#ffffff"
                    scale: shutterArea.pressed ? 0.95 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 100 }
                    }

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    // Capturing indicator
                    BusyIndicator {
                        anchors.centerIn: parent
                        running: isCapturing
                        visible: isCapturing
                        width: 32
                        height: 32
                    }
                }

                MouseArea {
                    id: shutterArea
                    anchors.fill: parent
                    enabled: isReady && !isCapturing
                    onClicked: {
                        capturePhoto()
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Placeholder for symmetry
            Item {
                Layout.preferredWidth: 56
                Layout.preferredHeight: 56
            }
        }
    }

    // Capture handlers
    function capturePhoto() {
        if (CameraBridge && isReady && !isCapturing) {
            captureAnimation.start()
            CameraBridge.capture()
        }
    }

    function showToastMessage() {
        toastAnimation.restart()
    }

    // Connect to CameraBridge signals
    Connections {
        target: CameraBridge

        function onCaptureCompleted(photoId) {
            showToastMessage()
            updateLastPhotoUrl()
        }

        function onCaptureFailed(error) {
            console.log("Capture failed:", error)
        }

        function onPhotosChanged() {
            updateLastPhotoUrl()
        }
    }

    function updateLastPhotoUrl() {
        if (CameraBridge) {
            lastPhotoUrl = CameraBridge.getLastPhotoUrl()
        }
    }

    // Refresh on visible
    Component.onCompleted: {
        if (CameraBridge) {
            CameraBridge.refreshStatus()
            CameraBridge.refreshPhotos()
            updateLastPhotoUrl()
        }
    }

    // Periodic status refresh
    Timer {
        interval: 5000
        running: camera.visible
        repeat: true
        onTriggered: {
            if (CameraBridge) {
                CameraBridge.refreshStatus()
            }
        }
    }
}
