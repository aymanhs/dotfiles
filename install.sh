#!/usr/bin/env bash
# dotfiles installer: zsh, oh-my-zsh, powerlevel10k, ripgrep, fzf, zoxide.
# Works on Ubuntu/Debian (apt) and Rocky/RHEL/Fedora (dnf). Safe to re-run.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/os.sh
source "$SCRIPT_DIR/lib/os.sh"
# shellcheck source=lib/versions.sh
source "$SCRIPT_DIR/lib/versions.sh"
# shellcheck source=lib/cli-tools.sh
source "$SCRIPT_DIR/lib/cli-tools.sh"
# shellcheck source=lib/zsh-setup.sh
source "$SCRIPT_DIR/lib/zsh-setup.sh"
# shellcheck source=lib/link.sh
source "$SCRIPT_DIR/lib/link.sh"

mkdir -p "$HOME/.local/bin"

detect_pkg_mgr
echo "Detected package manager: $PKG_MGR"

pkg_install zsh git curl tar

install_oh_my_zsh
install_p10k_theme
check_gitstatus_connectivity

install_ripgrep
install_fzf
install_zoxide
install_eza

link_file "$SCRIPT_DIR/zsh/zshrc" "$HOME/.zshrc"
link_file "$SCRIPT_DIR/zsh/p10k.zsh" "$HOME/.p10k.zsh"
link_file "$SCRIPT_DIR/zsh/aliases.zsh" "$HOME/.aliases.zsh"

echo
echo "Done."
if [[ "$SHELL" != *zsh* ]]; then
  echo "Note: default shell is still $SHELL. Run: chsh -s \$(command -v zsh)"
fi
echo "Note: p10k config uses Nerd Font icons - make sure your terminal font is a Nerd Font."
