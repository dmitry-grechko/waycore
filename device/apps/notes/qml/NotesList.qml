import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * NotesList - List view of all notes
 */
Rectangle {
    id: notesList
    color: Core.Theme.background

    signal backRequested()
    signal noteSelected(int noteId)
    signal newNoteRequested()

    // Notes data from bridge
    property var notes: NotesBridge ? NotesBridge.notes : []

    // Refresh when bridge data changes
    Connections {
        target: NotesBridge
        function onNotesChanged() {
            notes = NotesBridge.notes
        }
        function onErrorOccurred(message) {
            console.error("Notes error:", message)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // App bar
        Core.AppBar {
            Layout.fillWidth: true
            title: "Notes"
            showBack: true
            onBackClicked: notesList.backRequested()

            rightContent: Core.Button {
                text: "+ New"
                size: "small"
                variant: "primary"
                onClicked: notesList.newNoteRequested()
            }
        }

        // Notes list
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Core.Theme.spacingMedium
            clip: true
            spacing: Core.Theme.spacingSmall

            model: notes

            delegate: Core.Card {
                width: listView.width
                height: 80  // Explicit height for ListView delegate
                pressable: true

                RowLayout {
                    anchors.fill: parent
                    spacing: Core.Theme.spacingSmall

                    Column {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 4

                        Text {
                            text: modelData.title || "Untitled"
                            color: Core.Theme.textPrimary
                            font.pixelSize: Core.Theme.bodySize
                            font.weight: Core.Theme.fontWeightBold
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: getPreview(modelData.content)
                            color: Core.Theme.textSecondary
                            font.pixelSize: Core.Theme.captionSize
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: formatDate(modelData.updated_at)
                            color: Core.Theme.textTertiary
                            font.pixelSize: Core.Theme.smallSize
                        }
                    }

                    Core.IconButton {
                        icon: "🗑️"
                        size: "small"
                        Layout.alignment: Qt.AlignVCenter
                        onClicked: {
                            deleteConfirmDialog.noteId = modelData.id
                            deleteConfirmDialog.noteTitle = modelData.title
                            deleteConfirmDialog.open()
                        }
                    }
                }

                onClicked: notesList.noteSelected(modelData.id)
            }

            // Empty state
            Core.EmptyState {
                anchors.centerIn: parent
                visible: notes.length === 0
                icon: "📝"
                title: "No Notes Yet"
                description: "Tap '+ New' to create your first note"
                actionText: "Create Note"
                onActionClicked: notesList.newNoteRequested()
            }
        }
    }

    // Delete confirmation dialog
    Core.Dialog {
        id: deleteConfirmDialog
        title: "Delete Note?"
        message: "Delete \"" + noteTitle + "\"? This cannot be undone."
        confirmText: "Delete"
        destructive: true

        property int noteId: -1
        property string noteTitle: ""

        onConfirmed: {
            if (NotesBridge) {
                NotesBridge.deleteNote(noteId)
            }
        }
    }

    function getPreview(content) {
        if (!content) return "No content"
        var clean = content.replace(/[#*_\-\[\]]/g, "").trim()
        return clean.substring(0, 60) + (clean.length > 60 ? "..." : "")
    }

    function formatDate(isoDate) {
        if (!isoDate) return ""
        var d = new Date(isoDate)
        return d.toLocaleDateString() + " " + d.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})
    }

    function loadNotes() {
        if (NotesBridge) {
            NotesBridge.loadNotes()
        }
    }

    Component.onCompleted: {
        loadNotes()
    }
}
