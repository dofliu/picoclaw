#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -m)" != "aarch64" ]]; then
  echo "[WARN] This script is intended for Raspberry Pi OS 64-bit (aarch64)."
fi

sudo apt update
sudo apt install -y git make curl jq

if ! command -v go >/dev/null 2>&1; then
  echo "[INFO] Go not found. Installing Go 1.25.1 (linux-arm64)..."
  cd /tmp
  curl -LO https://go.dev/dl/go1.25.1.linux-arm64.tar.gz
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf go1.25.1.linux-arm64.tar.gz
  if ! grep -q '/usr/local/go/bin' "$HOME/.bashrc"; then
    echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.bashrc"
  fi
  export PATH="$PATH:/usr/local/go/bin"
fi

echo "[INFO] Go version: $(go version)"

if [[ ! -d picoclaw ]]; then
  git clone https://github.com/sipeed/picoclaw.git
fi

cd picoclaw
make build
make install

if [[ ! -f "$HOME/.picoclaw/config.json" ]]; then
  mkdir -p "$HOME/.picoclaw"
  cp config/config.example.json "$HOME/.picoclaw/config.json"
  echo "[INFO] Created $HOME/.picoclaw/config.json (please edit API keys)."
fi

echo "[DONE] PicoClaw installed at $HOME/.local/bin/picoclaw"
echo "Run: picoclaw onboard"
