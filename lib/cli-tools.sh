#!/usr/bin/env bash
# Install ripgrep, fzf, zoxide, eza, bat, fd, dust, bottom, delta, duf,
# tealdeer (tldr) and direnv as static binaries into BIN_DIR.
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

install_eza() {
  _already_installed eza "$EZA_VERSION" && { echo "eza $EZA_VERSION already installed"; return; }

  local arch target tmp
  arch="$(arch_name)"
  case "$arch" in
    x86_64)  target="x86_64-unknown-linux-gnu" ;;
    aarch64) target="aarch64-unknown-linux-gnu" ;;
    *) echo "Unsupported arch for eza: $arch" >&2; return 1 ;;
  esac

  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  local url="https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_${target}.tar.gz"

  curl -fsSL "$url" -o "$tmp/eza.tar.gz"
  tar -xzf "$tmp/eza.tar.gz" -C "$tmp"
  install -Dm755 "$tmp/eza" "$BIN_DIR/eza"
  echo "Installed eza $EZA_VERSION to $BIN_DIR/eza"
}

install_bat() {
  _already_installed bat "$BAT_VERSION" && { echo "bat $BAT_VERSION already installed"; return; }

  local arch target tmp
  arch="$(arch_name)"
  case "$arch" in
    x86_64)  target="x86_64-unknown-linux-musl" ;;
    aarch64) target="aarch64-unknown-linux-musl" ;;
    *) echo "Unsupported arch for bat: $arch" >&2; return 1 ;;
  esac

  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  local base="bat-v${BAT_VERSION}-${target}"
  local url="https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/${base}.tar.gz"

  curl -fsSL "$url" -o "$tmp/bat.tar.gz"
  tar -xzf "$tmp/bat.tar.gz" -C "$tmp"
  install -Dm755 "$tmp/${base}/bat" "$BIN_DIR/bat"
  echo "Installed bat $BAT_VERSION to $BIN_DIR/bat"
}

install_fd() {
  _already_installed fd "$FD_VERSION" && { echo "fd $FD_VERSION already installed"; return; }

  local arch target tmp
  arch="$(arch_name)"
  case "$arch" in
    x86_64)  target="x86_64-unknown-linux-musl" ;;
    aarch64) target="aarch64-unknown-linux-musl" ;;
    *) echo "Unsupported arch for fd: $arch" >&2; return 1 ;;
  esac

  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  local base="fd-v${FD_VERSION}-${target}"
  local url="https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/${base}.tar.gz"

  curl -fsSL "$url" -o "$tmp/fd.tar.gz"
  tar -xzf "$tmp/fd.tar.gz" -C "$tmp"
  install -Dm755 "$tmp/${base}/fd" "$BIN_DIR/fd"
  echo "Installed fd $FD_VERSION to $BIN_DIR/fd"
}

install_dust() {
  _already_installed dust "$DUST_VERSION" && { echo "dust $DUST_VERSION already installed"; return; }

  local arch target tmp
  arch="$(arch_name)"
  case "$arch" in
    x86_64)  target="x86_64-unknown-linux-musl" ;;
    aarch64) target="aarch64-unknown-linux-musl" ;;
    *) echo "Unsupported arch for dust: $arch" >&2; return 1 ;;
  esac

  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  local base="dust-v${DUST_VERSION}-${target}"
  local url="https://github.com/bootandy/dust/releases/download/v${DUST_VERSION}/${base}.tar.gz"

  curl -fsSL "$url" -o "$tmp/dust.tar.gz"
  tar -xzf "$tmp/dust.tar.gz" -C "$tmp"
  install -Dm755 "$tmp/${base}/dust" "$BIN_DIR/dust"
  echo "Installed dust $DUST_VERSION to $BIN_DIR/dust"
}

install_bottom() {
  _already_installed btm "$BOTTOM_VERSION" && { echo "bottom $BOTTOM_VERSION already installed"; return; }

  local arch target tmp
  arch="$(arch_name)"
  case "$arch" in
    x86_64)  target="x86_64-unknown-linux-musl" ;;
    aarch64) target="aarch64-unknown-linux-musl" ;;
    *) echo "Unsupported arch for bottom: $arch" >&2; return 1 ;;
  esac

  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  local url="https://github.com/ClementTsang/bottom/releases/download/${BOTTOM_VERSION}/bottom_${target}.tar.gz"

  curl -fsSL "$url" -o "$tmp/bottom.tar.gz"
  tar -xzf "$tmp/bottom.tar.gz" -C "$tmp"
  install -Dm755 "$tmp/btm" "$BIN_DIR/btm"
  echo "Installed bottom $BOTTOM_VERSION to $BIN_DIR/btm"
}

install_delta() {
  _already_installed delta "$DELTA_VERSION" && { echo "delta $DELTA_VERSION already installed"; return; }

  local arch target tmp
  arch="$(arch_name)"
  case "$arch" in
    x86_64)  target="x86_64-unknown-linux-gnu" ;;
    aarch64) target="aarch64-unknown-linux-gnu" ;;
    *) echo "Unsupported arch for delta: $arch" >&2; return 1 ;;
  esac

  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  local base="delta-${DELTA_VERSION}-${target}"
  local url="https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/${base}.tar.gz"

  curl -fsSL "$url" -o "$tmp/delta.tar.gz"
  tar -xzf "$tmp/delta.tar.gz" -C "$tmp"
  install -Dm755 "$tmp/${base}/delta" "$BIN_DIR/delta"
  echo "Installed delta $DELTA_VERSION to $BIN_DIR/delta"
}

install_duf() {
  _already_installed duf "$DUF_VERSION" && { echo "duf $DUF_VERSION already installed"; return; }

  local arch target tmp
  arch="$(arch_name)"
  case "$arch" in
    x86_64)  target="x86_64" ;;
    aarch64) target="arm64" ;;
    *) echo "Unsupported arch for duf: $arch" >&2; return 1 ;;
  esac

  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  local url="https://github.com/muesli/duf/releases/download/v${DUF_VERSION}/duf_${DUF_VERSION}_linux_${target}.tar.gz"

  curl -fsSL "$url" -o "$tmp/duf.tar.gz"
  tar -xzf "$tmp/duf.tar.gz" -C "$tmp"
  install -Dm755 "$tmp/duf" "$BIN_DIR/duf"
  echo "Installed duf $DUF_VERSION to $BIN_DIR/duf"
}

install_tealdeer() {
  _already_installed tldr "$TEALDEER_VERSION" && { echo "tealdeer $TEALDEER_VERSION already installed"; return; }

  local arch target tmp
  arch="$(arch_name)"
  case "$arch" in
    x86_64)  target="x86_64-musl" ;;
    aarch64) target="aarch64-musl" ;;
    *) echo "Unsupported arch for tealdeer: $arch" >&2; return 1 ;;
  esac

  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  local base="tealdeer-linux-${target}"
  local url="https://github.com/tealdeer-rs/tealdeer/releases/download/v${TEALDEER_VERSION}/${base}"

  curl -fsSL "$url" -o "$tmp/tldr"
  curl -fsSL "${url}.sha256" -o "$tmp/tldr.sha256"
  (cd "$tmp" && sed "s/${base}/tldr/" "tldr.sha256" | sha256sum -c -)

  install -Dm755 "$tmp/tldr" "$BIN_DIR/tldr"
  "$BIN_DIR/tldr" --update >/dev/null 2>&1 || true
  echo "Installed tealdeer $TEALDEER_VERSION to $BIN_DIR/tldr"
}

install_direnv() {
  _already_installed direnv "$DIRENV_VERSION" && { echo "direnv $DIRENV_VERSION already installed"; return; }

  local arch target tmp
  arch="$(arch_name)"
  case "$arch" in
    x86_64)  target="linux-amd64" ;;
    aarch64) target="linux-arm64" ;;
    *) echo "Unsupported arch for direnv: $arch" >&2; return 1 ;;
  esac

  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  # Upstream publishes no checksum file for release binaries.
  local url="https://github.com/direnv/direnv/releases/download/v${DIRENV_VERSION}/direnv.${target}"

  curl -fsSL "$url" -o "$tmp/direnv"
  install -Dm755 "$tmp/direnv" "$BIN_DIR/direnv"
  echo "Installed direnv $DIRENV_VERSION to $BIN_DIR/direnv"
}
