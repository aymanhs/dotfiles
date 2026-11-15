#!/usr/bin/env bash
# Symlink repo config files into $HOME, backing up any pre-existing real file once.

link_file() {
  local src="$1" dest="$2"

  if [[ -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
    echo "$dest already linked"
    return
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    local backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    echo "Backed up existing $dest to $backup"
  fi

  ln -s "$src" "$dest"
  echo "Linked $dest -> $src"
}
