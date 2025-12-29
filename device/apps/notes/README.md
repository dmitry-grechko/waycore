# Notes App

Create and manage text notes with markdown formatting support.

## Features

- **Note List**: View all notes sorted by last modified
- **Create Notes**: Quick new note creation
- **Edit Notes**: Full-featured editor with markdown toolbar
- **Markdown Formatting**: Headers, bold, italic, bullet points
- **Auto-save**: Notes are saved when navigating away
- **Delete Notes**: Swipe or tap to delete with confirmation

## Screens

### Notes List (`NotesList.qml`)
- Displays all notes in a scrollable list
- Shows title, content preview, and last modified date
- Delete button per note with confirmation dialog
- Empty state with create action

### Note Editor (`NoteEditor.qml`)
- Title input field
- Formatting toolbar (H1, H2, bullet, bold, italic)
- Large text area for content
- Character count display
- Save button and auto-save on back

## Usage

### Creating a Note
1. Tap "+ New" on the notes list
2. Enter a title
3. Write your content
4. Tap "Save" or navigate back (auto-saves)

### Markdown Formatting
- **H1**: Start line with `# `
- **H2**: Start line with `## `
- **Bullet**: Start line with `- `
- **Bold**: Wrap text with `**text**`
- **Italic**: Wrap text with `*text*`

## Technical Details

- **App ID**: `com.waycore.notes`
- **Category**: Utilities
- **Tier**: 2 (main apps grid)
- **Backend**: NotesBridge (shared with UI)

## Files

```
device/apps/notes/
├── manifest.json      # App manifest
├── qml/
│   ├── NotesMain.qml  # Entry point with navigation
│   ├── NotesList.qml  # List view
│   └── NoteEditor.qml # Editor view
└── README.md          # This file
```

## Dependencies

- NotesBridge context property for data access
- Core UI components (AppBar, Card, Button, etc.)
