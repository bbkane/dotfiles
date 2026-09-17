# Install

```bash
fling link --src-dir . --link-dir "$VAULT_ROOT"
```

And re-install plugins (next section)

# Plugins / Themes

NOTE: I'm ignoring code but keeping any `data.json` files as those have settings

- [bkane-msft/obsidian-git-gutter: Fork of obsidian-git with just the local gutter](https://github.com/bkane-msft/obsidian-git-gutter) - fork that just keeps the gitgutter; follow install instructions there.
- [Custom Attachment Location - Obsidian Plugin](https://community.obsidian.md/plugins/obsidian-custom-attachment-location) - `./${noteFileName}.assets` as my attachment folder

- [Advanced Rename and Delete Handler - Obsidian Plugin](https://community.obsidian.md/plugins/advanced-rename-and-delete-handler) - auto installed by previous
- [Primary - Obsidian Theme](https://community.obsidian.md/themes/primary) - color theme

# Notes

Outline: `Cmd` + `P`, open outline, drag outline icon to other side.

[FIRST 3 Things You Should Do To Set Up Obsidian - YouTube](https://www.youtube.com/shorts/xHGphyA2mZw)

- I want to use markdown links so disabed "Use [[WIkilinks]]"
- "Automatically update internal links" settings
- "default folder for attachments" - I set to "subfolder under current folder" (I wish it was `${filename.assets}` like Typora but I don't want to deal with plugins right now)

initialized git repo...

Ok, I pasted an image in, and deleted it, but it stayed in the attachments - TODO: try [Clear Unused Images Plus - Obsidian Plugin](https://community.obsidian.md/plugins/clear-unused-images-plus) for this once I start using plugins

Note that mermaid diagrams make you switch between unhighligthed code and the rendered image. Ok I guess - TODO: plugin for syntax highlighting or even an LSP

To paste code blocks in, need to use Cmd+Shift+V

2026-09-13 Migration - Copy files to new repo, append a banner to the bottom of each note saying it's moved.

## Features I want

- Gdocs
  - todo-daily macro
  - Date macro
  - Checklist
  - Syncing
  - Moving tasks to next day
- NVim
  - Git gutter - added
  - Pickers / Views
    - Outline - View
    - Search - View
    - files - View / Picker
  - Embedded LSP
- CMUX
  - Workspaces - not really - it's locked to the vault so everythign has to fit into there
- Typora
  - WSIWYG - works
  - Images - works
  - Mermaid - works
  - HTML Paste -> MD
- Other
  - Excalidraw embed
  - D2 embed

## Types of organization

- **Folders:** The standard top-down file system. Best for strict, mutually exclusive boundaries where a file can only live in one place (e.g., separating `Work` vs. `Personal`, or isolating `Templates` and `Attachments`).
- **Tags (`#tag`):** Flexible, cross-cutting labels. Since a note can have multiple tags, they are ideal for statuses (`#draft`, `#to-review`), note types (`#book-summary`, `#meeting-notes`), or broad topics that span multiple folders.
- **Links (`[[note name]]`):** Direct connections between individual notes. This is the core of Obsidian, allowing you to organically connect related concepts without worrying about where the file physically lives.
- **Maps of Content (MOCs):** A structural paradigm where you create "hub" notes that act as custom tables of contents. Instead of a `Fitness` folder, you create a `[[Fitness MOC]]` note that contains categorized links to all your workout routines, diet plans, and research.
- **Properties (Frontmatter):** Structured metadata fields added to the top of a note (e.g., `author:`, `date-finished:`, `status:`). This allows you to treat your notes like a database.
- **Embedded Queries:** You can embed native search blocks (or use the popular Dataview community plugin) to dynamically generate lists or tables of notes. For example, a query can automatically display "all notes in the `Projects` folder tagged `#active`."
- **Bookmarks:** Your core quick-access menu. You can bookmark individual notes, but also folders, dynamic search queries, and specific graph view configurations to keep current priorities one click away.
- **Canvas:** Obsidian's native infinite whiteboard. Best for visually clustering notes, drawing directional arrows between concepts, creating mind maps, or laying out a timeline side-by-side.
- **Graph View:** The visual representation of your `[[links]]`. While mostly exploratory, it is an organization tool used to spot "orphan" notes (notes with no links) or heavily connected clusters that might need to be broken down into an MOC.

