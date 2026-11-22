# Install

```bash
fling link --src-dir . --link-dir "$VAULT_ROOT"
```

And re-install plugins (next section)

# Plugins / Themes

NOTE: I'm ignoring code but keeping any `data.json` files as those have settings

- [bkane-msft/obsidian-git-gutter: Fork of obsidian-git with just the local gutter](https://github.com/bkane-msft/obsidian-git-gutter) - fork that just keeps the gitgutter; follow install instructions there.
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

# Sun 2026-11-22 Notes on asset migration

I made ../bin_common/bin_common/obsidian_migrate_assets.py to do this. So the steps to migrate are:

- Go to target directory (my blog for example)

Because I have multiple vaults on the samem machine and the obsidian directory is a mix of data and config, we don't want to symlink the whole folder, just the relevant files. This will let each vault own its data and share the config. It'll also make it harder for me to tell when files that I *want* to version control are added (since by default they'll be owned by the vault and I'll need to copy them into dotfiles and symlink) but oh well. I think I've gotten most of what I want in version control already; I'll just need to add plugin config files when I add plugins

- Quit Obsidian
- `git pull`
- Remove the `.obsidian` directory (should be a symlink so `rm .obsidian/` will work)
- Ensure `.obsidian/` is in `.gitignore`
- Create an empty one: `mkdir .obsidian` . 
- Symlink: `fling link -s ~/Git-GH/dotfiles/obsidian/ -l /path/to/vault`
- Run the migration script: `~/bin_common/obsidian_migrate_assets.py` (and re-run with `--apply` after inspection)
- Re-open Obsidian and uninstall the file renaming and image link plugins (and the emoji plugin too)
- check the Files and Links settings to ensure stuff goes into a subfolder of current directory and "assets"



