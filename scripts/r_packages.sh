#!/usr/bin/env bash
set -euo pipefail

# Install arf
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/eitsupi/arf/releases/latest/download/arf-console-installer.sh | sh
source $HOME/.cargo/env 

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing R packages..."
Rscript "$SCRIPT_DIR/r_packages.R"
