# bin_common

I'm keeping shared scripts in `bin_common`, so I can reserve `~/bin` for machine-specific scripts (similar to why I have `~/.zshrc_common` and `~/.zshrc`).

Add `~/bin_common` to the `$PATH` manually.

Assumes `zsh` is the current shell and this package's `bin_common` directory is symlinked to `~/bin_common`:

```bash
cat >> "$HOME/.zshrc" << 'EOF'

# See https://github.com/bbkane/dotfiles
export PATH="$HOME/bin_common:$PATH"
EOF
```

# List of scripts

As of 2026-07-27. See the comments or `-h/--help` in each script for more details.

- [blog.py](./bin_common/blog.py) - Create a blog post for www.bbkane.com

- [check_sync_log.py](./bin_common/check_sync_log.py) - Check the log for rclone sync --dry-run --combined

- [color_exceptions.py](./bin_common/color_exceptions.py) - highlight exceptions in log files

- [copy_and_format_for_gdocs.py](./bin_common/copy_and_format_for_gdocs.py) - Restyle the clipboard's rich text so pasting into Google Docs keeps lists/links but matches the doc's font/style

- [copy_as_rtf.py](./bin_common/copy_as_rtf.py) - Copy CSV file as rich text

- [dashcam_audio.py](./bin_common/dashcam_audio.py) - Extract and concatenate audio from dashcam video files

- [date_range.pl](./bin_common/date_range.pl) - Print a date range

- [diff_against_example-go-cli.py](./bin_common/diff_against_example-go-cli.py) - Diff a file in example-go-cli against same-named files in other Go projects

- [diff_strings.py](./bin_common/diff_strings.py) - Diff two strings with colored output

- [docx-dir-to-md-dir.sh](./bin_common/docx-dir-to-md-dir.sh) - Recursively convert .docx files to .md using pandoc

- [easyssl.py](./bin_common/easyssl.py) - Generate and run/print the small subset of openssl commands I care about

- [envwarden.py](./bin_common/envwarden.py) - Exports environmental variables from a TOML config file and the system Key Chain

- [format_dict.py](./bin_common/format_dict.py) - Format Python dict from stdin as pretty-printed JSON

- [format_f-string.py](./bin_common/format_f-string.py) - read stdin formatted as a Python f-string and format with key-value pairs passed as args

- [format_json.py](./bin_common/format_json.py) - Format JSON files, printing to stdout or editing in place with `-i`

- [format_jsonl.py](./bin_common/format_jsonl.py) - Read stdin and pretty-print JSON lines

- [format_shell_cmd.py](./bin_common/format_shell_cmd.py) - Read a line from stdin and format as a BASH Command

- [gdoc_image_from_clipboard.sh](./bin_common/gdoc_image_from_clipboard.sh) - Extract a base64 image from a Google Docs HTML clipboard entry and save to a file

- [git-lines-changed-tsv](./bin_common/git-lines-changed-tsv) - Print lines changed over time for a git repo

- [git-merged-branches](./bin_common/git-merged-branches) - List branches that can be deleted because they've been merged via PR

- [git-tagit](./bin_common/git-tagit) - Print git status and current last 10 git tags, then prompt for a new git tag and push

- [git-url](./bin_common/git-url) - Print the GitHub URL for a tracked file, optionally as a permalink

- [imgcat](./bin_common/imgcat) - Display images inline in the iTerm2 using Inline Images Protocol

- [json_to_yaml.sh](./bin_common/json_to_yaml.sh) - Read JSON file by path and print as YAML to stdout

- [jsonl_to_csv.py](./bin_common/jsonl_to_csv.py) - Normalize JSONL records to a common key set and output JSONL or CSV

- [new_cli.py](./bin_common/new_cli.py) - Rename an example CLI template project

- [open_tmp_html.py](./bin_common/open_tmp_html.py) - Write html input to a tmpfile, then open in a browser

- [pr-watch](./bin_common/pr-watch) - List open pull requests, watch their checks, and notify when they finish

- [reply_to_recruiters.py](./bin_common/reply_to_recruiters.py) - Reply to recruiters

- [rewrite_goreleaser_cask_urls_to_file.py](./bin_common/rewrite_goreleaser_cask_urls_to_file.py) - Rewrite GoReleaser cask release URLs to local file URLs

- [scatterplot.py](./bin_common/scatterplot.py) - Create interactive HTML scatter/line plots!

- [tokei_projects.sh](./bin_common/tokei_projects.sh) - Count lines of code across personal Go projects using tokei

- [yaml_to_json.sh](./bin_common/yaml_to_json.sh)  - Read YAML file by path and print as JSON to stdout
