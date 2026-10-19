#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import logging
import os
import platform
import re
import subprocess
import sys
from pathlib import Path

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = f"""
Manage VS Code settings and extensions stored in dotfiles

Examples:
    {sys.argv[0]} settings symlink
    {sys.argv[0]} extensions save
    {sys.argv[0]} extensions install
    {sys.argv[0]} extensions purge --no-ask
    VSCODECTL_ROOT=/tmp/vscode {sys.argv[0]} extensions save

Help:
Please see Benjamin Kane for help.
Code at https://github.com/bbkane/dotfiles
"""

logger = logging.getLogger(__name__)

EXTENSIONS_FILE_NAME = "installed_extensions.txt"
DEFAULT_EXCLUDE_REGEXES = [
    r"^linkedin\.",
    r"^suchitadoshi1987\.vscode-ember-experimental$",
]


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "--log-level",
        choices=["NOTSET", "DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        default="INFO",
        help="log level",
    )

    parser.add_argument(
        "--root",
        type=Path,
        default=Path(
            os.environ.get("VSCODECTL_ROOT", "~/Git-LI-GH/dotfiles/vscode")
        ).expanduser(),
        help="Dir containing settings.json and installed_extensions.txt. Env: VSCODECTL_ROOT. Default: %(default)s",
    )

    subcommands = parser.add_subparsers(dest="subcommand_name", required=True)

    # settings
    settings_cmd = subcommands.add_parser("settings", help="settings subcommands")
    settings_subcommands = settings_cmd.add_subparsers(
        dest="settings_subcommand_name",
        required=True,
        help="subcommand name",
    )

    # settings symlink
    symlink_cmd = settings_subcommands.add_parser(
        "symlink",
        help="Symlink settings.json (and mcp.json, snippets/, keybindings_linux.json if present) from --root into VS Code's User dir",
    )
    symlink_cmd.add_argument(
        "--ask",
        action=argparse.BooleanOptionalAction,
        default=True,
        help="Ask for confirmation",
    )
    symlink_cmd.add_argument(
        "--platform",
        choices=("Windows", "Darwin", "Linux"),
        default=platform.system(),
        help="Platform. Default: %(default)s",
    )

    # extensions
    extensions_cmd = subcommands.add_parser(
        "extensions", help="extensions subcommands"
    )
    extensions_subcommands = extensions_cmd.add_subparsers(
        dest="extensions_subcommand_name",
        required=True,
        help="subcommand name",
    )

    # extensions install
    _ = extensions_subcommands.add_parser(
        "install", help=f"Install extensions listed in {EXTENSIONS_FILE_NAME}"
    )

    # extensions save
    save_cmd = extensions_subcommands.add_parser(
        "save", help=f"Save installed extensions to {EXTENSIONS_FILE_NAME}"
    )
    save_cmd.add_argument(
        "--exclude-regex",
        action="append",
        default=None,
        help=f"Regex of extension IDs to not save. Repeatable. Overrides defaults: {DEFAULT_EXCLUDE_REGEXES}",
    )

    # extensions purge
    purge_cmd = extensions_subcommands.add_parser(
        "purge", help="Uninstall all installed extensions"
    )
    purge_cmd.add_argument(
        "--ask",
        action=argparse.BooleanOptionalAction,
        default=True,
        help="Ask for confirmation",
    )

    return parser


def confirm(prompt: str) -> bool:
    return input(f"{prompt} Type 'yes' to continue: ") in ("yes", "'yes'", "y")


def run_code(*args: str, check: bool = True) -> subprocess.CompletedProcess[str]:
    cmd = ["code", *args]
    logger.debug(f"Running: {cmd}")
    try:
        return subprocess.run(cmd, check=check, text=True, capture_output=True)
    except FileNotFoundError:
        raise SystemExit(
            "`code` not found on PATH. In VS Code run: '> Shell Command: Install code command in PATH'"
        )


def list_installed_extensions() -> list[str]:
    return run_code("--list-extensions").stdout.split()


def symlink_paths(links: list[tuple[Path, Path]], ask: bool):
    """Validate all (src, dst) links first so a conflict doesn't leave a partial install"""
    for src, dst in links:
        if not src.exists():
            raise SystemExit(f"Source does not exist: {src}")
        if dst.exists() and not dst.is_symlink():
            raise SystemExit(f"Non-symlink already exists: {dst}")

    logger.info(
        "About to symlink:\n" + "\n".join(f"  {src} -> {dst}" for src, dst in links)
    )
    if ask and not confirm("Create dirs and symlinks?"):
        logger.info("Skipping")
        return

    for src, dst in links:
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.unlink(missing_ok=True)
        dst.symlink_to(src)


def settings_symlink(root: Path, plat: str, ask: bool):
    match plat:
        case "Windows":
            settings_dst_dir = Path(os.path.expandvars(r"%APPDATA%\Code\User"))
        case "Darwin":
            settings_dst_dir = Path(
                "~/Library/Application Support/Code/User"
            ).expanduser()
        case "Linux":
            settings_dst_dir = Path("~/.config/Code/User").expanduser()
        case _:
            raise SystemExit(f"No platform support for {plat!r}")

    links = [(root / "settings.json", settings_dst_dir / "settings.json")]

    # (src name in root, dst name in VS Code User dir), linked only if src exists
    optional = [("mcp.json", "mcp.json"), ("snippets", "snippets")]
    if plat == "Linux":
        optional.append(("keybindings_linux.json", "keybindings.json"))

    for src_name, dst_name in optional:
        src = root / src_name
        if src.exists():
            links.append((src, settings_dst_dir / dst_name))
        else:
            logger.info(f"Skipping, not found: {src}")

    symlink_paths(links, ask)


def extensions_install(root: Path):
    extensions_file = root / EXTENSIONS_FILE_NAME
    extensions = [
        line.strip()
        for line in extensions_file.read_text().splitlines()
        if line.strip()
    ]
    for ext in extensions:
        logger.info(f"Installing: {ext}")
        res = run_code("--install-extension", ext, check=False)
        if res.returncode != 0:
            raise SystemExit(f"Failed to install {ext!r}:\n{res.stdout}{res.stderr}")


def extensions_save(root: Path, exclude_regexes: list[str]):
    patterns = [re.compile(r) for r in exclude_regexes]
    extensions = sorted(
        ext
        for ext in list_installed_extensions()
        if not any(p.search(ext) for p in patterns)
    )
    extensions_file = root / EXTENSIONS_FILE_NAME
    extensions_file.write_text("".join(f"{ext}\n" for ext in extensions))
    logger.info(f"Saved {len(extensions)} extensions to {extensions_file}")


def extensions_purge(ask: bool):
    extensions = list_installed_extensions()
    if not extensions:
        logger.info("No extensions installed")
        return
    logger.info(f"About to uninstall {len(extensions)} extensions")
    if ask and not confirm("Uninstall all extensions?"):
        logger.info("Skipping")
        return
    for ext in extensions:
        logger.info(f"Uninstalling: {ext}")
        # Non-zero exit if another extension depends on this one. Ignore those
        res = run_code("--uninstall-extension", ext, check=False)
        if res.returncode != 0:
            logger.warning(f"Failed to uninstall {ext!r}:\n{res.stdout}{res.stderr}")


def main():
    parser = build_parser()
    args = parser.parse_args()

    logging.basicConfig(
        format="# %(asctime)s %(levelname)s %(name)s %(filename)s:%(lineno)s\n%(message)s\n",
        level=logging.getLevelName(args.log_level),
    )

    root: Path = args.root.expanduser().resolve()
    if not root.is_dir():
        raise SystemExit(f"--root is not a directory: {root}")

    match args.subcommand_name:
        case "settings":
            match args.settings_subcommand_name:
                case "symlink":
                    settings_symlink(root, args.platform, args.ask)
                case _:
                    raise SystemExit(
                        f"Unknown subcommand: {args.settings_subcommand_name!r}"
                    )
        case "extensions":
            match args.extensions_subcommand_name:
                case "install":
                    extensions_install(root)
                case "save":
                    extensions_save(
                        root,
                        (
                            args.exclude_regex
                            if args.exclude_regex is not None
                            else DEFAULT_EXCLUDE_REGEXES
                        ),
                    )
                case "purge":
                    extensions_purge(args.ask)
                case _:
                    raise SystemExit(
                        f"Unknown subcommand: {args.extensions_subcommand_name!r}"
                    )
        case _:
            raise SystemExit(f"Unknown command: {args.subcommand_name!r}")


if __name__ == "__main__":
    main()
