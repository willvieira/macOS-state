#!/usr/bin/env bash

CONFIG_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_REPO_ROOT="$(cd "$CONFIG_LIB_DIR/../.." && pwd)"
CONFIG_FILE="${CONFIG_FILE:-$CONFIG_REPO_ROOT/user.config.toml}"

ensure_dasel() {
  if command -v dasel &>/dev/null; then
    return 0
  fi

  echo "==> Bootstrapping dasel (TOML parser)..."
  if command -v brew &>/dev/null; then
    brew install dasel
    return 0
  fi

  local arch asset url install_dir
  arch=$(uname -m)
  if [[ "$arch" == "arm64" ]]; then
    asset="darwin_arm64"
  else
    asset="darwin_amd64"
  fi

  url=$(curl -sSLf https://api.github.com/repos/tomwright/dasel/releases/latest \
    | grep browser_download_url \
    | grep -v ".gz" \
    | grep "$asset" \
    | cut -d'"' -f4)
  if [[ -z "$url" ]]; then
    echo "ERROR: could not determine dasel download URL" >&2
    exit 1
  fi

  install_dir="$HOME/.local/bin"
  mkdir -p "$install_dir"
  curl -sSLf "$url" -o "$install_dir/dasel"
  chmod +x "$install_dir/dasel"
  export PATH="$install_dir:$PATH"
}

cfg() {
  local key="$1" default="${2:-}" value
  if ! command -v dasel &>/dev/null; then
    echo "ERROR: dasel is required before reading config" >&2
    exit 1
  fi
  value=$(dasel_read "$CONFIG_FILE" "$key" || true)
  value=$(normalize_config_value "$value")
  if [[ -z "$value" ]]; then
    echo "$default"
  else
    echo "$value"
  fi
}

dasel_read() {
  local file="$1" key="$2"
  dasel -i toml "$key" < "$file" 2>/dev/null \
    || dasel -f "$file" --plain "$key" 2>/dev/null
}

normalize_config_value() {
  local value="$1"
  if [[ "$value" == "''" ]]; then
    echo ""
  elif [[ "$value" == \'*\' ]]; then
    value="${value#\'}"
    value="${value%\'}"
    echo "$value"
  else
    echo "$value"
  fi
}
