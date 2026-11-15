# dotfiles

zsh + oh-my-zsh + powerlevel10k + ripgrep/fzf/zoxide, installed the same way on
Ubuntu/Debian and Rocky/RHEL/Fedora. Idempotent — re-running `install.sh` is
how you update.

## Install (new machine)

```sh
git clone git@github.com:aymanhs/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
chsh -s "$(command -v zsh)"   # if not already your shell
```

Needs `sudo` for `zsh`/`git`/`curl`/`tar` via apt/dnf. Everything else
(oh-my-zsh, p10k theme, rg/fzf/zoxide) installs into your user account —
binaries go to `~/.local/bin`, no root needed.

## Update (existing machine)

```sh
cd ~/dotfiles && git pull && ./install.sh
```

Pulls latest p10k theme, re-checks pinned rg/fzf/zoxide versions (skips if
already current), re-links config. Safe to run anytime.

## Syncing config changes

`~/.zshrc` and `~/.p10k.zsh` are symlinks into this repo
(`zsh/zshrc`, `zsh/p10k.zsh`), so editing either in place edits the repo copy
directly.

**Push a change you made locally:**

```sh
cd ~/dotfiles && git add -A && git commit -m "..." && git push
```

**Pull changes made elsewhere:**

```sh
cd ~/dotfiles && git pull
```

No re-link needed either way — the symlink always points at the current repo
content.

## Bumping tool versions

Edit `lib/versions.sh`, then run `./install.sh`. ripgrep and fzf downloads are
checksum-verified against the upstream release; zoxide is fetched straight
from GitHub over TLS (no published checksums).

## Layout

```
install.sh          entrypoint
lib/
  os.sh              apt/dnf detection via /etc/os-release
  versions.sh         pinned rg/fzf/zoxide versions
  cli-tools.sh        static-binary installers (checksum-verified)
  zsh-setup.sh        oh-my-zsh + powerlevel10k theme
  link.sh             symlink helper (backs up any pre-existing real file once)
zsh/
  zshrc               -> ~/.zshrc
  p10k.zsh            -> ~/.p10k.zsh
```

## Notes

- Supported arches: x86_64, aarch64 (Pi-friendly).
- First run on a given machine backs up any existing `~/.zshrc`/`~/.p10k.zsh`
  to `<file>.bak.<timestamp>` before symlinking.
- `~/.local.sh`, if present, is sourced at the end of `.zshrc` — use it for
  per-machine stuff that shouldn't go in the repo (local env vars, secrets,
  one-off aliases).
- p10k's prompt uses Nerd Font glyphs — make sure your terminal's font is a
  Nerd Font variant; that's a terminal-side setting, not something this
  installer can do for you.
