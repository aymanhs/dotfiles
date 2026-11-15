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
# GitHub on first use. On boxes without outbound internet access this hangs
# the shell on login. Warn up front and point at the escape hatch.
check_gitstatus_connectivity() {
  if curl -fsSL -m 5 -o /dev/null https://github.com 2>/dev/null; then
    echo "GitHub reachable - powerlevel10k git status (gitstatusd) will work normally."
    return
  fi

  cat >&2 <<'EOF'

WARNING: cannot reach github.com - powerlevel10k's gitstatusd download will
hang on first login (git status segment in the prompt).

To disable it on this machine, add to ~/.local.sh:

  export POWERLEVEL9K_DISABLE_GITSTATUS=true

(~/.local.sh is sourced from .zshrc and is machine-local, not in this repo.)
EOF
}
