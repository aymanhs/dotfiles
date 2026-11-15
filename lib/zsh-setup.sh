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
