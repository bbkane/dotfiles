# bin_common

I'm keeping shared scripts in `bin_common`, so I can reserve `~/bin` for machine-specific scripts (similar to why I have `~/.zshrc_common` and `~/.zshrc`).

Add `~/bin_common` to the`$PATH` manually.

Assumes `zsh` is the current shell and `/bin_common` is symlinked to `~/bin_common`:

```bash
cat >> "$HOME/.zshrc" << 'EOF'

# See https://github.com/bbkane/dotfiles
export PATH="$HOME/bin_common:$PATH"
EOF
```

# List of scripts

As of 2024-01-01. See the comments or `-h/--help` in each script for more details

- [blog.py](./bin_common/blog.py) - Create a blog post for www.bbkane.com

- [color_exceptions.py](./bin_common/color_exceptions.py) - highlight exceptions in log files

- [copy_as_rtf.py](./bin_common/copy_as_rtf.py) - Copy CSV file as rich text

- [date_range.pl](./bin_common/date_range.pl) - Print a date range

- [easyssl.py](./bin_common/easyssl.py) - Generate and run/print the small subset of openssl commands I care about

- [envwarden.py](./bin_common/envwarden.py) - Exports environmental variables from a TOML config file and the system Key Chain

- [format_jsonl.py](./bin_common/format_jsonl.py) - Read stdin and pretty-print JSON lines

- [format_shell_cmd.py](./bin_common/format_shell_cmd.py) - Read a line from stdin and format as a BASH Command

- [format_f-string.py](./bin_common/format_f-string.py) - read stdin formatted as a Python f-string and format with key-value pairs passed as args

- [git-lines-changed-tsv](./bin_common/git-lines-changed-tsv) - Print lines changed over time for a git repo

- [git-tagit](./bin_common/git-tagit) - Print git status and current last 10 git tags, then prompt for a new git tag and push

- [imgcat](./bin_common/imgcat) - Display images inline in the iTerm2 using Inline Images Protocol

- [json_to_yaml.sh](./bin_common/json_to_yaml.sh) - Read JSON file by path and print as YAML to stdout

- [jsonl_to.py](./bin_common/jsonl_to.py) - Normalize a newline delimited JSON log by adding any missing keys with null

  values TODO: rename

- [open_tmp_html.py](./bin_common/open_tmp_html.py) - Write html input to a tmpfile, then open in a browser

- [reply_to_recruiters.py](./bin_common/reply_to_recruiters.py) - Reply to recruiters

- [scatterplot.py](./bin_common/scatterplot.py) - Create interactive HTML scatter/line plots!

- [yaml_to_json.sh](./bin_common/yaml_to_json.sh)  - Read YAML file by path and print as JSON to stdout
