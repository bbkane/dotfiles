#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import copy
import datetime
import logging
import os
import re
import shlex
import shutil
import subprocess
import sys
from pathlib import Path
from typing import NamedTuple

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = f"""
Rename an example CLI template project to a new name
Examples:
    {sys.argv[0]}
Help:
Please see Benjamin Kane for help.
Code at <repo>
"""

logger = logging.getLogger(__name__)

now = datetime.datetime.now().isoformat(timespec="seconds")
log_file = f"/tmp/{Path(__file__).stem}-{now}.log"


class Color:
    reset = "\x1b[0m"
    grey = "\x1b[38;21m"
    blue = "\x1b[38;5;39m"
    yellow = "\x1b[38;5;226m"
    red = "\x1b[38;5;196m"
    bold_red = "\x1b[31;1m"


# logic from https://stackoverflow.com/a/75339761
class ColorLevelFormatter(logging.Formatter):
    _color_levelname = {
        "DEBUG": f"{Color.grey}DEBUG{Color.reset}",
        "INFO": f"{Color.blue}INFO{Color.reset}",
        "WARNING": f"{Color.yellow}WARNING{Color.reset}",
        "ERROR": f"{Color.red}ERROR{Color.reset}",
        "CRITICAL": f"{Color.bold_red}CRITICAL{Color.reset}",
    }

    def __init__(
        self,
        fmt: str = "%(levelname)s %(filename)s:%(lineno)s: %(message)s",
        *args,
        **kwargs,
    ):
        super().__init__(fmt, *args, **kwargs)

    def format(self, record):
        record = copy.copy(record)
        record.levelname = self._color_levelname[record.levelname]
        return super().format(record)


class LangSettings(NamedTuple):
    source_name: str
    topic: str
    src_dir: Path


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "--log-level",
        choices=["NOTSET", "DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        default="INFO",
        help="terminal log level",
    )
    parser.add_argument(
        "--log-file",
        default=log_file,
        help=f"log file path (default: {log_file})",
    )

    parser.add_argument(
        "--local-only",
        action="store_true",
        help="do not create a remote repository, only initialize git locally",
    )

    parser.add_argument(
        "--name",
        help="The name to copy the example project to",
    )

    parser.add_argument(
        "--lang",
        "-l",
        choices=["go", "rust"],
        required=True,
        help="project language template to use",
    )

    parser.add_argument(
        "--go-example",
        default="~/Git-GH/example-go-cli/",
        help="path to the Go example project (default: ~/Git-GH/example-go-cli/)",
    )

    parser.add_argument(
        "--rust-example",
        default="~/Git-GH/example-rust-cli/",
        help="path to the Rust example project (default: ~/Git-GH/example-rust-cli/)",
    )

    return parser


def run_cmd(*args: str, cwd: Path | None = None):
    cwd_msg = f" (cwd={cwd})" if cwd else ""
    logger.info(f"Running command{cwd_msg}: {shlex.join(args)}")
    res = subprocess.run(
        args,
        encoding="utf-8",
        capture_output=True,
        text=True,
        cwd=str(cwd) if cwd else None,
    )
    level = logging.DEBUG
    if res.returncode != 0:
        level = logging.ERROR
        logger.error(f"Command failed with return code: {res.returncode}")
    if res.stdout:
        logger.log(level, f"stdout:\n{res.stdout}")
    else:
        logger.log(level, "no stdout")

    if res.stderr:
        logger.log(level, f"stderr:\n{res.stderr}")
    else:
        logger.log(level, "no stderr")

    if res.returncode != 0:
        sys.exit(res.returncode)

    return res


def require_synced_master(repo_dir: Path):
    if not (repo_dir / ".git").exists():
        logger.error("Example repo is not a git repository: %s", repo_dir)
        sys.exit(1)

    branch = run_cmd("git", "branch", "--show-current", cwd=repo_dir).stdout.strip()
    if branch != "master":
        logger.error(
            "Example repo must be on master. Current branch is '%s' in %s",
            branch,
            repo_dir,
        )
        sys.exit(1)

    run_cmd("git", "fetch", "origin", "master", cwd=repo_dir)
    behind = run_cmd(
        "git", "rev-list", "--count", "HEAD..origin/master", cwd=repo_dir
    ).stdout.strip()
    ahead = run_cmd(
        "git", "rev-list", "--count", "origin/master..HEAD", cwd=repo_dir
    ).stdout.strip()

    if behind != "0":
        logger.error(
            "Example repo is behind origin/master by %s commit(s). Pull first: %s",
            behind,
            repo_dir,
        )
        sys.exit(1)
    if ahead != "0":
        logger.error(
            "Example repo is ahead of origin/master by %s commit(s). Push first: %s",
            ahead,
            repo_dir,
        )
        sys.exit(1)


def main():
    parser = build_parser()
    args = parser.parse_args()
    name = args.name or input("Enter the new name for the project: ").strip()

    root_logger = logging.getLogger()
    root_logger.setLevel(logging.DEBUG)

    file_handler = logging.FileHandler(args.log_file, mode="w", encoding="utf-8")
    file_handler.setFormatter(
        logging.Formatter(
            "# %(asctime)s %(levelname)s %(name)s %(filename)s:%(lineno)s\n%(message)s"
        )
    )  # noqa: E501
    root_logger.addHandler(file_handler)

    stdout_handler = logging.StreamHandler(sys.stdout)
    stdout_handler.setLevel(logging.getLevelNamesMapping()[args.log_level])
    stdout_handler.setFormatter(ColorLevelFormatter())
    root_logger.addHandler(stdout_handler)

    logger.info("log file: %s", args.log_file)

    lang_settings = {
        "go": LangSettings(
            source_name="example-go-cli",
            topic="go",
            src_dir=Path(args.go_example).expanduser().resolve(),
        ),
        "rust": LangSettings(
            source_name="example-rust-cli",
            topic="rust",
            src_dir=Path(args.rust_example).expanduser().resolve(),
        ),
    }
    settings = lang_settings[args.lang]

    # copy the selected example project directory to the new name
    src_dir = settings.src_dir
    require_synced_master(src_dir)
    dest_dir = src_dir.parent / name
    logger.info("Copying: %s to %s", src_dir, dest_dir)
    shutil.copytree(src_dir, dest_dir)

    logger.info("Changing working directory to: %s", dest_dir)
    os.chdir(dest_dir)

    # git clean
    run_cmd("git", "clean", "-fdx")

    # remove the .git directory
    git_dir = dest_dir / ".git"
    logger.info("Removing .git directory: %s", git_dir)
    shutil.rmtree(git_dir, ignore_errors=True)

    source_name = settings.source_name

    # replace template name with the new name in all files
    logger.info("Replacing '%s' with '%s' in all files", source_name, name)
    for root, dirs, files in dest_dir.walk():
        for file in files:
            file_path: Path = Path(root) / file
            logger.debug("Checking: %s", file_path)
            if file_path.suffix in (".gif",):
                logger.debug("Skipping binary file: %s", file_path)
                continue
            text = file_path.read_text(encoding="utf-8")
            new_text = text.replace(source_name, name)
            if new_text != text:
                logger.debug(
                    "Replacing '%s' with '%s' in: %s",
                    source_name,
                    name,
                    file_path,
                )
                file_path.write_text(new_text, encoding="utf-8")

    if args.lang == "rust":
        cargo_toml = dest_dir / "Cargo.toml"
        logger.info("Setting Cargo.toml package version to 0.0.1: %s", cargo_toml)
        cargo_toml_text = cargo_toml.read_text(encoding="utf-8")
        cargo_toml_text, replacements = re.subn(
            r'(?m)^version\s*=\s*"[^"]+"\s*$',
            'version = "0.0.1"',
            cargo_toml_text,
            count=1,
        )
        if replacements != 1:
            logger.error("Could not find a version line in %s", cargo_toml)
            sys.exit(1)

        cargo_toml.write_text(cargo_toml_text, encoding="utf-8")
        run_cmd("cargo", "update", "-p", name)

    # create a new git repository and commit
    run_cmd("git", "init")
    run_cmd("git", "add", ".")
    run_cmd("git", "commit", "-m", f"Initial commit for {name}")

    if args.local_only:
        logger.info("Local-only mode enabled, skipping remote repository creation.")
        return

    # create upstream repo, add language topic, and push
    run_cmd(
        "gh", "repo", "create", name, "--private", "--source", ".", "--remote", "origin"
    )  # noqa: E501
    run_cmd("gh", "repo", "edit", "--add-topic", settings.topic)
    run_cmd("git", "push")

    logger.info("Script complete!")
    logger.warning(
        "Take next steps at: https://www.bbkane.com/blog/go-project-notes/#steps"
    )  # noqa: E501


if __name__ == "__main__":
    main()
