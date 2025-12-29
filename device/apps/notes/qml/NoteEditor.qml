import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * NoteEditor - Edit or create a note
 */
Rectangle {
    id: noteEditor
    color: Core.Theme.background

    signal backRequested()

    // Note data
    property int noteId: -1  // -1 = new note
    property string noteTitle: ""
    property string noteContent: ""
    property bool isModified: false
    property bool isSaving: false

    // Load note data when noteId changes
    Connections {
        target: NotesBridge
        function onCurrentNoteChanged() {
            if (NotesBridge.currentNote) {
                noteTitle = NotesBridge.currentNote.title || ""
                noteContent = NotesBridge.currentNote.content || ""
                isModified = false
            }
        }
        function onErrorOccurred(message) {
            toast.show("Error: " + message)
            isSaving = false
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // App bar
        Core.AppBar {
            Layout.fillWidth: true
            title: noteId < 0 ? "New Note" : "Edit Note"
            showBack: true
            onBackClicked: {
                if (isModified) {
                    saveNote()
                }
                noteEditor.backRequested()
            }

            rightContent: Core.Button {
                text: isSaving ? "Saving..." : "Save"
                size: "small"
                variant: "primary"
                enabled: isModified && !isSaving
                onClicked: saveNote()
            }
        }

        // Title input
        Core.TextField {
            Layout.fillWidth: true
            Layout.margins: Core.Theme.spacingMedium
            Layout.bottomMargin: 0
            placeholderText: "Note title..."
            text: noteTitle
            font.pixelSize: Core.Theme.h3Size
            font.weight: Core.Theme.fontWeightBold
            onTextChanged: {
                if (noteTitle !== text) {
                    noteTitle = text
                    isModified = true
                }
            }
        }

        // Formatting toolbar
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: Core.Theme.spacingMedium
            Layout.topMargin: Core.Theme.spacingSmall
            spacing: Core.Theme.spacingXS

            Core.Button {
                text: "H1"
                size: "small"
                variant: "ghost"
                onClicked: insertFormatting("# ")
            }
            Core.Button {
                text: "H2"
                size: "small"
                variant: "ghost"
                onClicked: insertFormatting("## ")
            }
            Core.Button {
                text: "•"
                size: "small"
                variant: "ghost"
                onClicked: insertFormatting("- ")
            }
            Core.Button {
                text: "B"
                size: "small"
                variant: "ghost"
                onClicked: wrapSelection("**", "**")
            }
            Core.Button {
                text: "I"
                size: "small"
                variant: "ghost"
                onClicked: wrapSelection("*", "*")
            }

            Item { Layout.fillWidth: true }

            Text {
                text: contentArea.text.length + " chars"
                color: Core.Theme.textSecondary
                font.pixelSize: Core.Theme.smallSize
            }
        }

        // Content area
        Core.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Core.Theme.spacingMedium
            Layout.topMargin: 0

            TextArea {
                id: contentArea
                text: noteContent
                placeholderText: "Start writing...\n\nTip: Use the formatting buttons above for headers and lists."
                wrapMode: TextEdit.Wrap
                font.pixelSize: Core.Theme.bodySize
                color: Core.Theme.textPrimary
                placeholderTextColor: Core.Theme.textSecondary
                background: Rectangle {
                    color: Core.Theme.surface
                    radius: Core.Theme.borderRadius
                }
                padding: Core.Theme.spacingMedium
                onTextChanged: {
                    if (noteContent !== text) {
                        noteContent = text
                        isModified = true
                    }
                }
            }
        }
    }

    // Toast for status messages
    Core.Toast {
        id: toast
        position: "bottom"
    }

    function insertFormatting(prefix) {
        var pos = contentArea.cursorPosition
        var text = contentArea.text

        var lineStart = text.lastIndexOf("\n", pos - 1) + 1

        contentArea.text = text.substring(0, lineStart) + prefix + text.substring(lineStart)
        contentArea.cursorPosition = pos + prefix.length
    }

    function wrapSelection(before, after) {
        var start = contentArea.selectionStart
        var end = contentArea.selectionEnd

        if (start === end) {
            var text = contentArea.text
            var pos = contentArea.cursorPosition
            contentArea.text = text.substring(0, pos) + before + after + text.substring(pos)
            contentArea.cursorPosition = pos + before.length
        } else {
            var text = contentArea.text
            var selected = text.substring(start, end)
            contentArea.text = text.substring(0, start) + before + selected + after + text.substring(end)
            contentArea.cursorPosition = end + before.length + after.length
        }
    }

    function saveNote() {
        if (!NotesBridge) {
            console.log("NotesBridge not available")
            return
        }

        isSaving = true
        var result = NotesBridge.saveNote(noteId, noteTitle, noteContent)

        if (result >= 0) {
            if (noteId < 0) {
                noteId = result  // Update ID for new notes
            }
            isModified = false
            toast.show("✓ Saved")
        } else {
            toast.show("Failed to save")
        }
        isSaving = false
    }

    Component.onCompleted: {
        if (NotesBridge && noteId >= 0) {
            NotesBridge.loadNote(noteId)
        }
    }
}
