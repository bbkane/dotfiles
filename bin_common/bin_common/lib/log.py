"""Shared logging setup for bin_common scripts (stdlib only).

Scripts in bin_common can import this because Python puts the running
script's directory first on sys.path:

    from lib import log

    parser = argparse.ArgumentParser()
    log.add_log_args(parser)
    args = parser.parse_args()
    log.setup(log.to_stream(args.log_level))

Common setups:

    # terminal only
    log.setup(log.to_stream(args.log_level))

    # terminal + DEBUG file per run (add_log_args(parser, log_file=log.per_run_path()))
    log.setup(log.to_stream(args.log_level), log.to_file(args.log_file))

    # background (hooks, cron): rotating file only, UTC timestamps
    log.setup(log.to_file(path, level="INFO", rotate_bytes=256 * 1024))
"""

from __future__ import annotations

import argparse
import copy
import datetime
import logging
import logging.handlers
import os
import sys
from collections.abc import Iterable
from pathlib import Path
from typing import TextIO

LEVELS = ["NOTSET", "DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"]

# Format presets
MSG = "%(levelname)s: %(message)s"
SHORT = "%(levelname)s %(filename)s:%(lineno)s: %(message)s"
LONG = "# %(asctime)s %(levelname)s %(name)s %(filename)s:%(lineno)s %(funcName)s\n%(message)s"
LINE = "%(asctime)s %(levelname)s %(name)s %(funcName)s: %(message)s"


class _Color:
    reset = "\x1b[0m"
    grey = "\x1b[38;21m"
    blue = "\x1b[38;5;39m"
    yellow = "\x1b[38;5;226m"
    red = "\x1b[38;5;196m"
    bold_red = "\x1b[31;1m"


_COLOR_LEVELNAME = {
    "DEBUG": f"{_Color.grey}DEBUG{_Color.reset}",
    "INFO": f"{_Color.blue}INFO{_Color.reset}",
    "WARNING": f"{_Color.yellow}WARNING{_Color.reset}",
    "ERROR": f"{_Color.red}ERROR{_Color.reset}",
    "CRITICAL": f"{_Color.bold_red}CRITICAL{_Color.reset}",
}


class _Formatter(logging.Formatter):
    """Formatter with ISO 8601 timestamps and optional colored level names."""

    def __init__(self, fmt: str, *, color: bool = False, utc: bool = False):
        super().__init__(fmt)
        self._color = color
        self._utc = utc

    def formatTime(self, record, datefmt=None):
        if self._utc:
            dt = datetime.datetime.fromtimestamp(record.created, datetime.UTC)
        else:
            dt = datetime.datetime.fromtimestamp(record.created).astimezone()
        return dt.isoformat(timespec="milliseconds")

    def format(self, record):
        if self._color:
            # Handlers share the record; keep color changes local.
            record = copy.copy(record)
            record.levelname = _COLOR_LEVELNAME.get(record.levelname, record.levelname)
        return super().format(record)


def to_stream(
    level: str | int = "INFO",
    *,
    to: TextIO | None = None,
    fmt: str = SHORT,
    color: bool | None = None,
    utc: bool = False,
) -> logging.Handler:
    """Return a handler that logs to a stream.

    level: minimum level to log.
    to: stream to write to; None -> sys.stderr (looked up at call time).
    fmt: format string (see presets MSG, SHORT, LONG, LINE).
    color: color level names; None -> auto (`to` is a TTY and NO_COLOR is unset).
    utc: use UTC timestamps instead of local time.
    """
    to = to or sys.stderr
    if color is None:
        color = to.isatty() and not os.environ.get("NO_COLOR")
    handler = logging.StreamHandler(to)
    handler.setLevel(level)
    handler.setFormatter(_Formatter(fmt, color=color, utc=utc))
    return handler


def to_file(
    path: str | Path,
    *,
    level: str | int = "DEBUG",
    fmt: str | None = None,
    rotate_bytes: int | None = None,
    rotate_backups: int = 2,
    utc: bool | None = None,
) -> logging.Handler:
    """Return a handler that appends to a file, creating parent directories.

    level: minimum level to log.
    fmt: format string; None -> LINE if rotating, else LONG.
    rotate_bytes: rotate the file at this size, keeping rotate_backups old files.
    utc: use UTC timestamps; None -> True if rotating, else local time.
    """
    path = Path(path).expanduser()
    path.parent.mkdir(parents=True, exist_ok=True)
    rotating = rotate_bytes is not None
    handler: logging.Handler
    if rotating:
        handler = logging.handlers.RotatingFileHandler(
            path,
            maxBytes=rotate_bytes,
            backupCount=rotate_backups,
            encoding="utf-8",
            delay=True,
        )
    else:
        handler = logging.FileHandler(path, mode="a", encoding="utf-8")
    handler.setLevel(level)
    if fmt is None:
        fmt = LINE if rotating else LONG
    if utc is None:
        utc = rotating
    handler.setFormatter(_Formatter(fmt, utc=utc))
    return handler


def setup(*handlers: logging.Handler, quiet: Iterable[str] = ()) -> None:
    """Configure the root logger with `handlers`, replacing any existing ones.

    Accepts handlers from to_stream/to_file or any stdlib logging.Handler.
    quiet: logger names (e.g. noisy third-party libraries) to raise to WARNING.
    """
    if not handlers:
        raise ValueError("pass at least one handler, e.g. log.setup(log.to_stream())")

    root = logging.getLogger()
    for h in root.handlers[:]:
        root.removeHandler(h)
        h.close()
    root.setLevel(min(h.level for h in handlers))
    for h in handlers:
        root.addHandler(h)

    for name in quiet:
        logging.getLogger(name).setLevel(logging.WARNING)


def add_log_args(
    parser: argparse.ArgumentParser, *, log_file: str | None = None
) -> None:
    """Add --log-level, plus --log-file (defaulting to log_file) if log_file is given."""
    parser.add_argument(
        "--log-level",
        choices=LEVELS,
        default="INFO",
        help="stderr log level",
    )
    if log_file is not None:
        parser.add_argument(
            "--log-file",
            default=log_file,
            help=f"log file path (default: {log_file})",
        )


def per_run_path(name: str | None = None, dir: str = "/tmp") -> str:
    """Return <dir>/<name>-<timestamp>.log; name defaults to the script's stem."""
    name = name or Path(sys.argv[0]).stem
    now = datetime.datetime.now().isoformat(timespec="seconds")
    return str(Path(dir) / f"{name}-{now}.log")
