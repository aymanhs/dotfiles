#!/usr/bin/env bash
# Install ripgrep, fzf and zoxide as static binaries into BIN_DIR.
# Idempotent: skips download if the pinned version is already installed.

BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

_already_installed() {
  local bin="$1" version="$2"
  command -v "$bin" >/dev/null 2>&1 && "$BIN_DIR/$bin" --version 2>/dev/null | grep -qF "$version"
}

install_ripgrep() {
  _already_installed rg "$RIPGREP_VERSION" && { echo "ripgrep $RIPGREP_VERSION already installed"; return; }

  local arch target tmp
  arch="$(arch_name)"
  case "$arch" in
    x86_64)  target="x86_64-unknown-linux-musl" ;;
    aarch64) target="aarch64-unknown-linux-musl" ;;
    *) echo "Unsupported arch for ripgrep: $arch" >&2; return 1 ;;
  esac

  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  local base="ripgrep-${RIPGREP_VERSION}-${target}"
  local url="https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/${base}.tar.gz"

  curl -fsSL "$url" -o "$tmp/rg.tar.gz"
  curl -fsSL "${url}.sha256" -o "$tmp/rg.tar.gz.sha256"
  (cd "$tmp" && sed "s/${base}.tar.gz/rg.tar.gz/" "rg.tar.gz.sha256" | sha256sum -c -)

  tar -xzf "$tmp/rg.tar.gz" -C "$tmp"
  install -Dm755 "$tmp/${base}/rg" "$BIN_DIR/rg"
  echo "Installed ripgrep $RIPGREP_VERSION to $BIN_DIR/rg"
}

install_fzf() {
  _already_installed fzf "$FZF_VERSION" && { echo "fzf $FZF_VERSION already installed"; return; }

  local arch target tmp
  arch="$(arch_name)"
  case "$arch" in
    x86_64)  target="amd64" ;;
    aarch64) target="arm64" ;;
    *) echo "Unsupported arch for fzf: $arch" >&2; return 1 ;;
  esac

  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  local asset="fzf-${FZF_VERSION}-linux_${target}.tar.gz"
  local base_url="https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}"

  curl -fsSL "${base_url}/${asset}" -o "$tmp/fzf.tar.gz"
  curl -fsSL "${base_url}/fzf_${FZF_VERSION}_checksums.txt" -o "$tmp/checksums.txt"
  (cd "$tmp" && grep "$asset\$" checksums.txt | awk '{print $1"  fzf.tar.gz"}' | sha256sum -c -)

  tar -xzf "$tmp/fzf.tar.gz" -C "$tmp"
  install -Dm755 "$tmp/fzf" "$BIN_DIR/fzf"
  echo "Installed fzf $FZF_VERSION to $BIN_DIR/fzf"
}

install_zoxide() {
  _already_installed zoxide "$ZOXIDE_VERSION" && { echo "zoxide $ZOXIDE_VERSION already installed"; return; }

  local arch target tmp
  arch="$(arch_name)"
  case "$arch" in
    x86_64)  target="x86_64-unknown-linux-musl" ;;
    aarch64) target="aarch64-unknown-linux-musl" ;;
    *) echo "Unsupported arch for zoxide: $arch" >&2; return 1 ;;
  esac

  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  local base="zoxide-${ZOXIDE_VERSION}-${target}"
  local url="https://github.com/ajeetdsouza/zoxide/releases/download/v${ZOXIDE_VERSION}/${base}.tar.gz"

  curl -fsSL "$url" -o "$tmp/zoxide.tar.gz"
  tar -xzf "$tmp/zoxide.tar.gz" -C "$tmp"
  install -Dm755 "$tmp/zoxide" "$BIN_DIR/zoxide"
  echo "Installed zoxide $ZOXIDE_VERSION to $BIN_DIR/zoxide"
}
