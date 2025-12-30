import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * NoteEditor - Tactical-styled note editor
 *
 * Uses standardized Core components:
 * - TacticalBackground for grid + vignette
 * - PageHeader for header
 * - TacticalInput for title input
 * - TacticalTextArea for content
 * - ActionBar for save/delete actions
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

    // Tactical background (grid + vignette)
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
            title: noteId < 0 ? "New Note" : "Edit Note"
            showBack: true
            rightIcon: "edit_note"
            onBackClicked: {
                if (isModified) {
                    saveNote()
                }
                noteEditor.backRequested()
            }
        }

        // Content area
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: contentColumn.height + 120
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: contentColumn
                width: parent.width
                spacing: Core.Theme.spacingMedium

                // Spacer
                Item {
                    Layout.fillWidth: true
                    height: Core.Theme.spacingMedium
                }

                // Title input using TacticalInput
                Core.TacticalInput {
                    Layout.fillWidth: true
                    Layout.leftMargin: Core.Theme.spacingMedium
                    Layout.rightMargin: Core.Theme.spacingMedium
                    label: "Title"
                    placeholder: "Enter title..."
                    text: noteTitle

                    onTextChanged: {
                        if (noteTitle !== text) {
                            noteTitle = text
                            isModified = true
                        }
                    }
                }

                // Formatting toolbar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: Core.Theme.spacingMedium
                    Layout.rightMargin: Core.Theme.spacingMedium
                    height: 48
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        spacing: 4

                        ToolButton { iconName: "format-bold"; tooltip: "Bold" }
                        ToolButton { iconName: "format-italic"; tooltip: "Italic" }
                        ToolButton { iconName: "format-list-bulleted"; tooltip: "List" }
                        ToolButton { iconName: "check"; tooltip: "Checkbox" }

                        Rectangle {
                            width: 1
                            height: 24
                            color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
                            Layout.alignment: Qt.AlignVCenter
                        }

                        ToolButton { iconName: "microphone"; tooltip: "Voice" }
                        ToolButton { iconName: "camera"; tooltip: "Photo" }
                        ToolButton { iconName: "map-marker"; tooltip: "Location" }

                        Item { Layout.fillWidth: true }
                    }

                    // Bottom border
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.2)
                    }
                }

                // Content input using TacticalTextArea
                Core.TacticalTextArea {
                    Layout.fillWidth: true
                    Layout.leftMargin: Core.Theme.spacingMedium
                    Layout.rightMargin: Core.Theme.spacingMedium
                    label: "Content"
                    placeholder: "Start typing..."
                    text: noteContent
                    minHeight: 300

                    onTextChanged: {
                        if (noteContent !== text) {
                            noteContent = text
                            isModified = true
                        }
                    }
                }
            }
        }

        // Bottom spacer for action bar
        Item {
            Layout.fillWidth: true
            height: 100
        }
    }

    // Bottom action bar using ActionBar component
    Core.ActionBar {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        z: 50

        primaryText: isSaving ? "Saving..." : "Save Note"
        primaryIcon: "content-save"
        primaryLoading: isSaving
        primaryEnabled: !isSaving
        onPrimaryClicked: saveNote()

        secondaryIcon: noteId >= 0 ? "delete" : ""
        secondaryDestructive: true
        onSecondaryClicked: deleteConfirmDialog.open()
    }

    // Tool Button Component
    component ToolButton: Rectangle {
        property string iconName: ""
        property string tooltip: ""
        property bool active: false

        width: 40
        height: 40
        color: toolArea.containsMouse ? Core.Theme.surface : "transparent"
        radius: Core.Theme.borderRadius

        Core.MaterialIcon {
            anchors.centerIn: parent
            name: parent.iconName
            size: 20
            iconColor: parent.active ? Core.Theme.warning : (toolArea.containsMouse ? Core.Theme.textPrimary : Core.Theme.textSecondary)
        }

        MouseArea {
            id: toolArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                // TODO: Implement formatting actions
            }
        }
    }

    // Toast for status messages
    Core.Toast {
        id: toast
        position: "bottom"
    }

    // Delete confirmation dialog
    Core.Dialog {
        id: deleteConfirmDialog
        title: "Delete Note?"
        message: "This note will be permanently deleted."
        confirmText: "Delete"
        destructive: true

        onConfirmed: {
            if (NotesBridge && noteId >= 0) {
                NotesBridge.deleteNote(noteId)
                noteEditor.backRequested()
            }
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
                noteId = result
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
