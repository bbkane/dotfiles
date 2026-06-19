#!/usr/bin/env python3
"""Rewrite GoReleaser-generated Homebrew cask GitHub URLs to local file URLs.

This allows full local install testing before publishing a GitHub release.
"""

from __future__ import annotations

import argparse
import re
import shutil
import sys
from pathlib import Path
from urllib.parse import quote, unquote, urlparse

URL_PATTERN = re.compile(
    r'url\s+"https://github\.com/[^"]+/releases/download/[^/]+/([^"]+)"'
)
FILE_URL_PATTERN = re.compile(r'url\s+"(file://[^"]+)"')
VERSION_PATTERN = re.compile(r'^\s*version\s+"([^"]+)"', re.MULTILINE)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Rewrite cask URL lines from GitHub releases to local file:// URLs "
            "pointing at a GoReleaser dist directory."
        )
    )
    parser.add_argument("cask_file", type=Path, help="Path to Homebrew cask .rb file")
    parser.add_argument(
        "dist_dir",
        type=Path,
        nargs="?",
        default=Path("./dist"),
        help="Path to goreleaser dist directory (default: ./dist)",
    )
    parser.add_argument(
        "--no-backup",
        action="store_true",
        help="Do not create a .bak backup before writing",
    )
    return parser.parse_args()


def to_file_url(dist_dir: Path, filename: str) -> str:
    # Keep interpolation markers like #{version} untouched while escaping spaces.
    escaped_name = quote(filename, safe="/#{}:@-._~!$&'()*+,;=")
    return f'{dist_dir.as_uri()}/{escaped_name}'


def rewrite_urls(content: str, dist_dir: Path) -> tuple[str, int]:
    def repl(match: re.Match[str]) -> str:
        filename = match.group(1)
        return f'url "{to_file_url(dist_dir, filename)}"'

    return URL_PATTERN.subn(repl, content)


def file_url_exists(file_url: str) -> bool:
    parsed = urlparse(file_url)
    if parsed.scheme != "file":
        return False
    return Path(unquote(parsed.path)).exists()


def resolve_ruby_placeholders(text: str, version_value: str | None) -> str:
    if version_value:
        text = text.replace("#{version}", version_value)
    return text


def main() -> int:
    args = parse_args()

    cask_file = args.cask_file.expanduser().resolve()
    dist_dir = args.dist_dir.expanduser().resolve()

    if not cask_file.is_file():
        print(f"Error: cask file not found: {cask_file}", file=sys.stderr)
        return 1
    if not dist_dir.is_dir():
        print(f"Error: dist dir not found: {dist_dir}", file=sys.stderr)
        return 1

    original = cask_file.read_text(encoding="utf-8")
    updated, replacements = rewrite_urls(original, dist_dir)

    if replacements == 0:
        print("No GitHub release URL lines found to rewrite.", file=sys.stderr)
        return 1

    if not args.no_backup:
        backup_path = cask_file.with_suffix(cask_file.suffix + ".bak")
        shutil.copy2(cask_file, backup_path)
        print(f"Backup written: {backup_path}")

    cask_file.write_text(updated, encoding="utf-8")
    print(f"Rewrote {replacements} URL line(s) in: {cask_file}")

    version_match = VERSION_PATTERN.search(updated)
    version_value = version_match.group(1) if version_match else None

    file_urls = FILE_URL_PATTERN.findall(updated)
    missing = [
        url
        for url in file_urls
        if not file_url_exists(resolve_ruby_placeholders(url, version_value))
    ]

    if missing:
        print("Warning: some file URLs do not exist locally:")
        for url in missing:
            print(f"  {url}")
        return 2

    print("All rewritten file URLs resolve to existing local files.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
