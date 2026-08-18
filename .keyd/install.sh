#!/usr/bin/env bash
#
# Install keyd and link this repo's config as the single source of truth.
# Idempotent and safe to re-run. Works on Arch (pacman) and Mint/Debian (apt,
# falling back to a source build since keyd isn't always packaged).
#
# Usage:  ./install.sh
# After a config change on any box:  git pull && sudo keyd reload
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$HERE/etc/keyd/default.conf"
TARGET="/etc/keyd/default.conf"

log() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }

# 1. Ensure keyd is installed.
if ! command -v keyd >/dev/null 2>&1; then
  if command -v pacman >/dev/null 2>&1; then
    log "Installing keyd via pacman"
    sudo pacman -S --needed --noconfirm keyd
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -qq
    if sudo apt-get install -y keyd 2>/dev/null; then
      log "Installed keyd from apt"
    else
      log "keyd not in apt; building from source"
      sudo apt-get install -y git build-essential
      tmp="$(mktemp -d)"
      git clone --depth 1 https://github.com/rvaiya/keyd "$tmp/keyd"
      make -C "$tmp/keyd"
      sudo make -C "$tmp/keyd" install
      sudo systemctl daemon-reload 2>/dev/null || true
      rm -rf "$tmp"
    fi
  else
    echo "Unsupported distro: install keyd manually (https://github.com/rvaiya/keyd)" >&2
    exit 1
  fi
else
  log "keyd already installed ($(keyd --version 2>/dev/null | head -1))"
fi

# 2. Link the config. Back up any pre-existing real file first.
sudo mkdir -p /etc/keyd
if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
  backup="$TARGET.bak.$(date +%s)"
  log "Backing up existing $TARGET -> $backup"
  sudo mv "$TARGET" "$backup"
fi
sudo ln -sfn "$SRC" "$TARGET"
log "Linked $TARGET -> $SRC"

# 3. Enable, start, and load the config.
sudo systemctl enable --now keyd
sudo keyd reload
log "keyd is active. Hold Alt + i/j/k/l for arrows."

# 4. Allow passwordless `keyd reload` for this user, so config changes pulled on
#    any box apply unattended (used by the omarchy post-update hook).
#    Skip with:  NO_SUDOERS=1 ./install.sh
if [ "${NO_SUDOERS:-0}" != "1" ]; then
  keyd_bin="$(command -v keyd)"
  sudoers="/etc/sudoers.d/keyd-reload"
  tmp_sudoers="$(mktemp)"
  chmod 0440 "$tmp_sudoers"
  printf '%s ALL=(root) NOPASSWD: %s reload\n' "$(id -un)" "$keyd_bin" >"$tmp_sudoers"
  if sudo visudo -cqf "$tmp_sudoers"; then
    sudo install -m 0440 -o root -g root "$tmp_sudoers" "$sudoers"
    log "Installed $sudoers (passwordless '$keyd_bin reload')"
  else
    echo "Generated sudoers file failed validation; not installing it." >&2
  fi
  rm -f "$tmp_sudoers"
fi
