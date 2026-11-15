#!/usr/bin/env bash
# oh-my-zsh and powerlevel10k theme setup. Idempotent.

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo "oh-my-zsh already installed"
    return
  fi
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_p10k_theme() {
  local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  local theme_dir="$zsh_custom/themes/powerlevel10k"

  if [[ -d "$theme_dir" ]]; then
    git -C "$theme_dir" pull --ff-only --quiet
    echo "powerlevel10k already installed, pulled latest"
  else
    git clone --depth=1 --quiet https://github.com/romkatv/powerlevel10k.git "$theme_dir"
    echo "Installed powerlevel10k theme"
  fi
}

# p10k's git status segment downloads a prebuilt `gitstatusd` binary from
# GitHub on first use. On boxes without outbound internet access - or where a
# firewall allows github.com but blocks its release-asset CDN - this hangs
# the shell on login. Warn up front and point at the escape hatch.
#
# Note: testing plain https://github.com is not enough. GitHub release
# downloads redirect to a separate host (release-assets.githubusercontent.com
# or similar), which is commonly blocked even when github.com itself is
# reachable. So we probe a real release asset, following redirects, instead.
check_gitstatus_connectivity() {
  local probe_url="https://github.com/romkatv/gitstatus/releases/download/v1.5.4/gitstatusd-linux-x86_64.tar.gz"
  if curl -fsSL -m 8 -o /dev/null -r 0-0 "$probe_url" 2>/dev/null; then
    echo "gitstatusd release CDN reachable - powerlevel10k git status will work normally."
    return
  fi

  cat >&2 <<'EOF'

WARNING: cannot reach GitHub's release-asset CDN - powerlevel10k's gitstatusd
download will hang on first login (git status segment in the prompt).

To disable it on this machine, add to ~/.local.sh:

  export POWERLEVEL9K_DISABLE_GITSTATUS=true

(~/.local.sh is sourced from .zshrc and is machine-local, not in this repo.)
EOF
}
