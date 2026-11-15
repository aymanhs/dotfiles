#!/usr/bin/env bash
# Wire repo-tracked git config snippets into ~/.gitconfig via include.path.
# Idempotent: git config --get-all dedupes before adding.

link_delta_gitconfig() {
  local snippet="$SCRIPT_DIR/git/delta.gitconfig"

  if git config --global --get-all include.path | grep -qF "$snippet"; then
    echo "delta.gitconfig already included in ~/.gitconfig"
    return
  fi

  git config --global --add include.path "$snippet"
  echo "Added $snippet to ~/.gitconfig include.path"
}
