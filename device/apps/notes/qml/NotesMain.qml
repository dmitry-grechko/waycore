import QtQuick 2.15
import QtQuick.Controls 2.15
import Core as Core

/**
 * NotesMain - Entry point for the Notes app
 *
 * Manages navigation between NotesList and NoteEditor views.
 */
Rectangle {
    id: root
    color: Core.Theme.background

    // Standard app interface
    signal closeRequested()
    property string appId: "com.waycore.notes"
    property string appTitle: "Notes"

    StackView {
        id: notesStack
        anchors.fill: parent
        initialItem: notesListComponent
    }

    Component {
        id: notesListComponent
        NotesList {
            onBackRequested: root.closeRequested()
            onNoteSelected: function(noteId) {
                openEditor(noteId)
            }
            onNewNoteRequested: openEditor(-1)
        }
    }

    Component {
        id: noteEditorComponent
        NoteEditor {
            onBackRequested: {
                notesStack.pop()
            }
        }
    }

    function openEditor(noteId) {
        var editor = noteEditorComponent.createObject(null, { noteId: noteId })
        notesStack.push(editor)
    }
}
