import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * NotesList - Tactical-styled list view of all notes
 *
 * Uses standardized Core components:
 * - TacticalBackground for grid + vignette
 * - PageHeader for header
 * - ActionBar for bottom actions
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
            title: "Notes"
            showBack: true
            onBackClicked: notesList.backRequested()
        }

        // Status bar
        Rectangle {
            Layout.fillWidth: true
            height: 24
            color: Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.2)

            Text {
                anchors.centerIn: parent
                text: notes.length + (notes.length === 1 ? " note" : " notes")
                color: Core.Theme.textSecondary
                font.pixelSize: 10
                font.family: Core.Theme.fontFamilyMono
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

            delegate: NoteCard {
                width: listView.width
                noteData: modelData
                onClicked: notesList.noteSelected(modelData.id)
            }

            // Empty state
            Core.EmptyState {
                anchors.centerIn: parent
                visible: notes.length === 0
                icon: "edit_note"
                title: "No Notes"
                description: "Create your first note"
                actionText: "New Note"
                onActionClicked: notesList.newNoteRequested()
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

        primaryText: "New Note"
        primaryIcon: "plus"
        onPrimaryClicked: notesList.newNoteRequested()
    }

    // Note Card Component
    component NoteCard: Rectangle {
        id: card
        height: 80
        radius: Core.Theme.borderRadius
        color: Core.Theme.background
        border.color: cardArea.containsMouse ? Core.Theme.divider : Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.4)
        border.width: 1

        property var noteData
        signal clicked()

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Core.Theme.spacingMedium
            anchors.rightMargin: Core.Theme.spacingMedium
            anchors.topMargin: Core.Theme.spacingMedium
            anchors.bottomMargin: Core.Theme.spacingMedium
            spacing: Core.Theme.spacingMedium

            Column {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 4

                // Date
                Text {
                    text: formatDate(noteData.updated_at)
                    color: Core.Theme.textSecondary
                    font.pixelSize: 10
                    font.family: Core.Theme.fontFamilyMono
                }

                // Title
                Text {
                    text: (noteData.title || "Untitled")
                    color: cardArea.containsMouse ? Core.Theme.warning : Core.Theme.textPrimary
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    font.family: Core.Theme.fontFamilyMono
                    font.letterSpacing: 0.5
                    elide: Text.ElideRight
                    width: parent.width

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }

                // Preview
                Text {
                    text: getPreview(noteData.content)
                    color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.6)
                    font.pixelSize: 14
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }

            // Chevron
            Core.MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                name: "chevron-right"
                size: 24
                iconColor: cardArea.containsMouse ? Core.Theme.warning : Core.Theme.divider

                Behavior on iconColor {
                    ColorAnimation { duration: 200 }
                }
            }
        }

        MouseArea {
            id: cardArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: card.clicked()
        }
    }

    function getPreview(content) {
        if (!content) return "No content"
        var clean = content.replace(/[#*_\-\[\]]/g, "").trim()
        return clean.substring(0, 80) + (clean.length > 80 ? "..." : "")
    }

    function formatDate(isoDate) {
        if (!isoDate) return ""
        var d = new Date(isoDate)
        var now = new Date()
        var diff = now - d
        var oneDay = 24 * 60 * 60 * 1000

        if (diff < oneDay && d.getDate() === now.getDate()) {
            return d.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}) + " TODAY"
        } else if (diff < 2 * oneDay) {
            return d.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}) + " YESTERDAY"
        } else {
            return d.toLocaleDateString(undefined, {month: 'short', day: 'numeric', year: 'numeric'}).toUpperCase()
        }
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
