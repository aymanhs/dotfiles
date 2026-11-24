#!/usr/bin/env bash
# Checks GitHub releases for every tool pinned in lib/versions.sh.
# Usage:
#   ./check-updates.sh            # just show what's outdated
#   ./check-updates.sh --apply    # bump lib/versions.sh pins to latest
#   ./check-updates.sh --install  # bump pins AND run install.sh to download

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/versions.sh
source "$SCRIPT_DIR/lib/versions.sh"

APPLY=0
INSTALL=0
case "${1:-}" in
  --apply)   APPLY=1 ;;
  --install) APPLY=1; INSTALL=1 ;;
  "") ;;
  *) echo "Usage: $0 [--apply|--install]" >&2; exit 1 ;;
esac

declare -A REPOS=(
  [RIPGREP]="BurntSushi/ripgrep"
  [FZF]="junegunn/fzf"
  [ZOXIDE]="ajeetdsouza/zoxide"
  [EZA]="eza-community/eza"
  [BAT]="sharkdp/bat"
  [FD]="sharkdp/fd"
  [DUST]="bootandy/dust"
  [BOTTOM]="ClementTsang/bottom"
  [DELTA]="dandavison/delta"
  [DUF]="muesli/duf"
  [TEALDEER]="tealdeer-rs/tealdeer"
  [DIRENV]="direnv/direnv"
  [ATUIN]="atuinsh/atuin"
  [JQ]="jqlang/jq"
  [YQ]="mikefarah/yq"
  [SD]="chmln/sd"
  [PROCS]="dalance/procs"
)

latest_tag() {
  local repo="$1" tag
  if command -v gh >/dev/null 2>&1; then
    tag="$(gh api "repos/$repo/releases/latest" --jq .tag_name 2>/dev/null)" || tag=""
  fi
  if [[ -z "${tag:-}" ]]; then
    tag="$(curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
      "https://api.github.com/repos/$repo/releases/latest" \
      | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')" || tag=""
  fi
  # strip common tag prefixes (v1.2.3, jq-1.8.2)
  tag="${tag#v}"
  tag="${tag#jq-}"
  printf '%s' "$tag"
}

declare -A LATEST
outdated=()

printf '%-10s %-12s %-12s %s\n' "TOOL" "CURRENT" "LATEST" "STATUS"
for name in "${!REPOS[@]}"; do :; done
for name in $(printf '%s\n' "${!REPOS[@]}" | sort); do
  repo="${REPOS[$name]}"
  var="${name}_VERSION"
  current="${!var}"
  latest="$(latest_tag "$repo")"
  LATEST[$name]="$latest"

  if [[ -z "$latest" ]]; then
    status="? (lookup failed)"
  elif [[ "$latest" == "$current" ]]; then
    status="up to date"
  else
    status="UPDATE AVAILABLE"
    outdated+=("$name")
  fi
  printf '%-10s %-12s %-12s %s\n' "${name,,}" "$current" "${latest:--}" "$status"
done

if [[ ${#outdated[@]} -eq 0 ]]; then
  echo
  echo "Everything up to date."
  exit 0
fi

if [[ $APPLY -eq 0 ]]; then
  echo
  echo "${#outdated[@]} tool(s) outdated. Re-run with --apply to bump lib/versions.sh, or --install to also download."
  exit 0
fi

echo
for name in "${outdated[@]}"; do
  var="${name}_VERSION"
  old="${!var}"
  new="${LATEST[$name]}"
  sed -i "s/^${var}=\"${old}\"/${var}=\"${new}\"/" "$SCRIPT_DIR/lib/versions.sh"
  echo "Bumped ${var}: ${old} -> ${new}"
done

if [[ $INSTALL -eq 1 ]]; then
  echo
  echo "Running install.sh to download updated tools..."
  "$SCRIPT_DIR/install.sh"
fi
