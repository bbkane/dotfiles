#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import logging
import os.path
import platform
import sys
from pathlib import Path

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = f"""
Symlinks VS Code dotfiles
Examples:
    {sys.argv[0]}
Help:
Please see Benjamin Kane for help.
Code at https://github.com/bbkane/dotfiles
"""

logger = logging.getLogger(__name__)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "--ask",
        action=argparse.BooleanOptionalAction,
        default=True,
        help="Ask for confirmation",
    )

    parser.add_argument(
        "--log-level",
        choices=["NOTSET", "DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        default="INFO",
        help="Log level",
    )

    parser.add_argument(
        "--platform",
        choices=("Windows", "Darwin", "Linux"),
        default=platform.system(),
        help=f"Platform. Currently set to to {platform.system()!r}",
    )

    return parser


def symlink_file(src_file: Path, dst_file: Path, ask: bool):
    if dst_file.exists() and not dst_file.is_symlink():
        raise SystemExit(f"Non-symlink already exists: {dst_file}")

    logger.info(f"About to symlink: {src_file} -> {dst_file}")

    do_it = True
    if ask:
        do_it = input("Type 'yes' to create dirs and symlinks: ") in (
            "yes",
            "'yes'",
            "y",
        )

    if do_it:
        dst_file.unlink(missing_ok=True)

        dst_file.symlink_to(src_file)


def main():
    parser = build_parser()
    args = parser.parse_args()

    logging.basicConfig(
        format="%(levelname)s: %(message)s",
        level=logging.getLevelNamesMapping()[args.log_level],
    )

    script_dir = Path(os.path.dirname(os.path.realpath(__file__)))
    settings_src_file = script_dir / "settings.json"

    if args.platform == "Windows":
        settings_dst_dir = Path(os.path.expandvars(r"%APPDATA%\Code\User"))
        settings_dst_file = settings_dst_dir / "settings.json"
        symlink_file(settings_src_file, settings_dst_file, args.ask)

    elif args.platform == "Darwin":
        settings_dst_dir = Path("~/Library/Application Support/Code/User").expanduser()
        settings_dst_file = settings_dst_dir / "settings.json"
        symlink_file(settings_src_file, settings_dst_file, args.ask)

    elif args.platform == "Linux":
        settings_dst_dir = Path("~/.config/Code/User").expanduser()
        settings_dst_file = settings_dst_dir / "settings.json"
        symlink_file(settings_src_file, settings_dst_file, args.ask)

        # on Linux, also symlink the keybindings
        keybindings_src_file = script_dir / "keybindings_linux.json"
        keybindings_dst_file = settings_dst_dir / "keybindings.json"
        symlink_file(keybindings_src_file, keybindings_dst_file, args.ask)

    else:
        raise SystemExit(f"No platform support for {args.platform!r}")


if __name__ == "__main__":
    main()
