#!/usr/bin/env bash
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/scripts" && pwd)"

echo "==> macOS setup starting"

run() {
  echo ""
  echo "--> $1"
  bash "$SCRIPTS_DIR/$2"
}

run "Homebrew & packages" homebrew.sh
run "macOS preferences"   macos.sh
run "Dev environment"     dev.sh
run "Dotfiles"            dotfiles.sh

echo ""
echo "==> Done. Restart your Mac for all settings to take effect."
