#!/usr/bin/env bash
# OS/package-manager detection for Ubuntu, Rocky and friends.

detect_pkg_mgr() {
  if [[ -r /etc/os-release ]]; then
    . /etc/os-release
  else
    echo "Cannot detect OS: /etc/os-release missing" >&2
    exit 1
  fi

  case "${ID}:${ID_LIKE:-}" in
    *debian*|*ubuntu*) PKG_MGR=apt ;;
    *rhel*|*fedora*|*rocky*|*centos*) PKG_MGR=dnf ;;
    *)
      echo "Unsupported distro: ${ID} (${ID_LIKE:-none})" >&2
      exit 1
      ;;
  esac
  export PKG_MGR
}

pkg_install() {
  case "$PKG_MGR" in
    apt)
      sudo apt-get update -qq || echo "Warning: apt-get update had errors (stale repo?), continuing" >&2
      sudo apt-get install -y "$@"
      ;;
    dnf)
      sudo dnf install -y "$@"
      ;;
  esac
}

arch_name() {
  uname -m
}
