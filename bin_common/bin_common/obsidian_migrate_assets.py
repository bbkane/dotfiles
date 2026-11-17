#!/usr/bin/env python3
"""Migrate per-note `<note>.assets/` attachment folders into a shared `assets/`
folder next to the note, and rewrite links in markdown notes.

  ddos/ddos.assets/foo.png  ->  ddos/assets/foo.png
  ![](ddos.assets/foo.png)  ->  ![](assets/foo.png)

Dry run by default; pass --apply to make changes. Run from the vault root
(or pass --vault):

  obsidian_migrate_assets.py           # preview
  obsidian_migrate_assets.py --apply   # do it

If two notes in the same folder have attachments with the same name but
different content, the second one is renamed to `<note>-<name>` and links to it
are updated. Identical duplicates are merged into a single file.

Skips .git, hidden dirs, node_modules, and nested git repos (e.g. core/,
edge-iac/). After running, any remaining `.assets/` references are listed so
they can be checked manually.
"""

import argparse
import filecmp
import os
import re
import sys
from pathlib import Path
from urllib.parse import quote

SUFFIX = ".assets"
TARGET = "assets"
SKIP_DIRS = {"node_modules"}


def walk_vault(vault: Path):
    for root, dirs, files in os.walk(vault):
        root_p = Path(root)
        dirs[:] = sorted(
            d
            for d in dirs
            if not d.startswith(".")
            and d not in SKIP_DIRS
            and not (root_p / d / ".git").exists()
        )
        yield root_p, dirs, files


def plan_moves(vault: Path):
    """Return (asset_dirs, moves, dupes).

    moves: old path -> new path to rename to.
    dupes: old path -> existing identical file in the target (old is deleted).
    """
    asset_dirs = []
    for root, dirs, _ in walk_vault(vault):
        for d in list(dirs):
            if d.endswith(SUFFIX) and d != SUFFIX:
                asset_dirs.append(root / d)
                dirs.remove(d)  # don't descend; contents move as a unit

    moves, dupes, claimed = {}, {}, {}  # claimed: new path -> source path
    for adir in asset_dirs:
        note_stem = adir.name[: -len(SUFFIX)]
        target_dir = adir.parent / TARGET
        for entry in sorted(adir.iterdir()):
            dest = target_dir / entry.name
            existing = claimed.get(dest) or (dest if dest.exists() else None)
            if existing is not None:
                if entry.is_file() and existing.is_file() and filecmp.cmp(entry, existing, shallow=False):
                    dupes[entry] = dest
                    continue
                dest = target_dir / f"{note_stem}-{entry.name}"
                n = 2
                while dest in claimed or dest.exists():
                    dest = target_dir / f"{note_stem}-{n}-{entry.name}"
                    n += 1
            claimed[dest] = entry
            moves[entry] = dest
    return asset_dirs, moves, dupes


# A path must start at a link boundary (not mid-name), optionally after "./".
BOUNDARY = r"(?<![\w.\-/%~])((?:\./)?)"
# A per-file path must also end at a link boundary.
FILE_END = r"(?=[)\]|\"'>#?\s]|$)"


# Forms a relative path may take in a link: raw, %20 spaces, fully URL-encoded.
ENCODINGS = [lambda s: s, lambda s: s.replace(" ", "%20"), quote]


def rewrite_note(note: Path, asset_dirs, mapping):
    text = note.read_text(encoding="utf-8")
    note_dir = note.parent
    pairs = []
    for adir in asset_dirs:
        old_dir = os.path.relpath(adir, note_dir)
        new_dir = os.path.relpath(adir.parent / TARGET, note_dir)
        for old, new in mapping.items():
            if old.parent == adir and new.name != old.name:
                pairs.append((f"{old_dir}/{old.name}", f"{new_dir}/{new.name}"))
        pairs.append((old_dir + "/", new_dir + "/"))

    expanded = {}
    for old, new in pairs:
        for enc in ENCODINGS:
            expanded.setdefault(enc(old), enc(new))
    # Longest first so per-file renames win over the folder-level rewrite.
    for old, new in sorted(expanded.items(), key=lambda p: len(p[0]), reverse=True):
        tail = "" if old.endswith("/") else FILE_END
        text = re.sub(BOUNDARY + re.escape(old) + tail, lambda m: m.group(1) + new, text)
    return text


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--apply", action="store_true", help="perform the migration (default: dry run)")
    ap.add_argument("--vault", type=Path, default=Path.cwd(), help="vault root (default: cwd)")
    args = ap.parse_args()
    vault = args.vault.resolve()
    if not (vault / ".obsidian").is_dir():
        ap.error(f"{vault} is not an Obsidian vault (no .obsidian/ folder)")
    print(f"[{'APPLY' if args.apply else 'DRY RUN'}] vault: {vault}\n")

    asset_dirs, moves, dupes = plan_moves(vault)
    if not asset_dirs:
        print("No *.assets folders found.")
        return 0

    rel = lambda p: p.relative_to(vault)
    print(f"Asset folders: {len(asset_dirs)}, entries to move: {len(moves)}, duplicates: {len(dupes)}")
    for old, new in moves.items():
        if new.name != old.name:
            print(f"  RENAME  {rel(old)} -> {rel(new)}")
    for old, new in dupes.items():
        print(f"  DEDUPE  {rel(old)} (identical to {rel(new)})")

    mapping = {**moves, **dupes}
    notes = [r / f for r, _, files in walk_vault(vault) for f in files if f.endswith(".md")]
    contents = {}
    changed = []
    for note in notes:
        original = note.read_text(encoding="utf-8")
        updated = rewrite_note(note, asset_dirs, mapping)
        contents[note] = updated
        if original != updated:
            n = sum(a != b for a, b in zip(original.splitlines(), updated.splitlines()))
            changed.append(note)
            print(f"  LINKS   {rel(note)}: {n} line(s)")
    print(f"\nNotes with link updates: {len(changed)}")

    if args.apply:
        for old, new in moves.items():
            new.parent.mkdir(exist_ok=True)
            old.rename(new)
        for old in dupes:
            old.unlink()
        for adir in asset_dirs:
            adir.rmdir()  # fails loudly if anything was left behind
        for note in changed:
            note.write_text(contents[note], encoding="utf-8")
        print("Applied.")

    # Leftovers are prose mentions, already-broken links, or unhandled link forms.
    leftover = re.compile(r"[^\s(\[\"'<>`]*\.assets/[^\s)\]\"'>`]*")
    hits = [
        f"  {rel(note)}:{i}: {m.group(0)}"
        for note, text in contents.items()
        for i, line in enumerate(text.splitlines(), 1)
        for m in leftover.finditer(line)
    ]
    if hits:
        print(f"\nRemaining '.assets/' references to review ({len(hits)}):")
        print("\n".join(hits))
    if not args.apply:
        print("\nDry run only. Re-run with --apply to migrate.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
