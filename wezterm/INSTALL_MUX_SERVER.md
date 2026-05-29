# Installing the WezTerm mux server on a remote VM

This sets up persistent, tmux-style attach/detach sessions on a remote VM using
WezTerm's built-in multiplexer. You run `wezterm-mux-server` on the VM (it owns
the shells/panes and survives disconnects), and attach from your Mac with
`wezterm connect <domain>`.

You only need two binaries on the VM — `wezterm` and `wezterm-mux-server` — and
**no root**. We extract them from a prebuilt release into `~/.local/bin`.

## Step 0: Match the version

The mux protocol differs between releases, so the VM's WezTerm **must match the
version on your Mac**. Check locally:

```bash
wezterm --version
# e.g. wezterm 20240203-110809-5046fc22
```

Use that exact version tag everywhere below (shown here as `20240203-110809-5046fc22`).

## Step 1: Identify the VM's libc, arch, and OS

The right build is the one whose **glibc requirement is ≤ the VM's glibc**
(glibc is backward-compatible: a binary built against an older glibc runs on a
newer one, but not vice-versa). The OS *name* barely matters since we extract
binaries by hand — glibc and CPU arch are what count.

```bash
ldd --version | head -1     # glibc version, e.g. "ldd (GNU libc) 2.35"
uname -m                    # x86_64 or aarch64
cat /etc/os-release         # distro name/version, for context
```

### Picking a build from the glibc version

| VM glibc | Recommended release asset | Notes |
|----------|---------------------------|-------|
| ≥ 2.35   | **Ubuntu 22.04** build    | exact match for glibc 2.35 |
| 2.31–2.34| **Ubuntu 20.04** build    | glibc 2.31; runs on anything newer |
| < 2.31   | Ubuntu 20.04, else build from source | very old; AppImage may not run |
| Fedora ≥2.36 only available | Fedora rpm | only if VM glibc ≥ the rpm's (Fedora ships newer glibc) |

Rule of thumb: **prefer the Ubuntu build with the highest version number whose
glibc is still ≤ the VM's glibc.** When unsure, the Ubuntu 20.04 build (glibc
2.31) is the safest because almost every current VM has glibc ≥ 2.31.

> Worked example — a VM reports glibc 2.35 / x86_64. Despite
> being an RPM-based distro, the Fedora rpms (glibc 2.36/2.37) are *too new* and
> would fail with `GLIBC_2.3x not found`. The Ubuntu 22.04 build (glibc 2.35) is
> the match; the Ubuntu 20.04 build also works.

## Step 2: List the actual release assets

Asset filenames change slightly between releases, so list them rather than
guessing (substitute your version tag):

```bash
curl -s https://api.github.com/repos/wez/wezterm/releases/tags/20240203-110809-5046fc22 \
  | grep browser_download_url | grep -Ei 'appimage|ubuntu|fedora|rpm|deb'
```

## Step 3: Download and extract (no root)

The **AppImage is the easiest** no-root option — extraction needs neither root
nor FUSE. Pick the AppImage matching the build chosen in Step 1.

```bash
mkdir -p ~/.local/bin ~/tmp/wez && cd ~/tmp/wez

# Substitute the exact asset URL from Step 2:
curl -L -o wez.AppImage \
  'https://github.com/wez/wezterm/releases/download/20240203-110809-5046fc22/WezTerm-20240203-110809-5046fc22-Ubuntu20.04.AppImage'

chmod +x wez.AppImage
./wez.AppImage --appimage-extract        # creates ./squashfs-root/

cp squashfs-root/usr/bin/wezterm squashfs-root/usr/bin/wezterm-mux-server ~/.local/bin/
```

### Alternatives if no suitable AppImage exists

Extract the binaries straight out of a `.deb` or `.rpm` (still no root):

```bash
# .deb (Ubuntu/Debian builds)
ar x wezterm.deb && tar xf data.tar.* \
  && cp ./usr/bin/wezterm ./usr/bin/wezterm-mux-server ~/.local/bin/

# .rpm (Fedora builds — only if VM glibc is new enough)
rpm2cpio wezterm.rpm | cpio -idmv \
  && cp ./usr/bin/wezterm ./usr/bin/wezterm-mux-server ~/.local/bin/
```

## Step 4: Put it on PATH and verify

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc   # or ~/.zshrc
export PATH="$HOME/.local/bin:$PATH"

wezterm --version        # MUST print the same version as your Mac
```

If this fails with `GLIBC_2.xx not found`, the build is too new for the VM —
go back to Step 1 and pick an older Ubuntu build (lower glibc requirement).

## Step 5: Point your Mac's WezTerm config at it

Add an SSH multiplexing domain on the **Mac** side. Because the binary lives in
`~/.local/bin` (not on the non-interactive SSH PATH), set `remote_wezterm_path`
explicitly:

```lua
config.ssh_domains = {
  {
    name = "myvm",
    remote_address = "myvm",   -- the ssh alias/host that connects from your Mac
    username = "myuser",
    multiplexing = "WezTerm",        -- bootstraps wezterm-mux-server on the remote
    remote_wezterm_path = "/home/myuser/.local/bin/wezterm",
  },
}
```

Validate the config loads cleanly:

```bash
wezterm show-keys >/dev/null && echo "config OK"
```

## Usage

| Action | Command |
|--------|---------|
| Attach | `wezterm connect myvm` |
| Detach | close the window (`Cmd+W`) or quit WezTerm — the workspace keeps running on the VM |
| Reattach | `wezterm connect myvm` |
| List panes/workspaces | `wezterm cli list` (run in a VM pane) |
| List connected clients | `wezterm cli list-clients` |

The session only ends if `wezterm-mux-server` is killed on the VM or the VM
reboots. Verify the server persists across disconnects:

```bash
ssh myvm 'pgrep -fa wezterm-mux-server'
```

## Troubleshooting / when the environment changes

- **You upgraded WezTerm on the Mac** → connecting fails with a protocol/version
  mismatch. Re-run Steps 0–4 on the VM to install the new matching version.
- **The VM was rebuilt / migrated to a new OS or image** → re-check glibc with
  Step 1 and re-pick the build. If glibc went *down*, your current binary may now
  be too new; install an older Ubuntu build.
- **`GLIBC_2.xx not found`** → the build's glibc requirement exceeds the VM's.
  Choose the Ubuntu build with the next-lower version number.
- **AppImage won't extract / run** → use the `.deb`/`.rpm` extraction in Step 3
  instead (no FUSE involved at all).
- **Different CPU arch (aarch64/ARM VM)** → grab the `aarch64`/`arm64` asset in
  Step 2 instead of `x86_64`.
- **No matching prebuilt build at all** (exotic/old libc) → build from source on
  the VM (`cargo build --release -p wezterm-mux-server`) or run the mux server
  inside a container that bundles a compatible libc.
