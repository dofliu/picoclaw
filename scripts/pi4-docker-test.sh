#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERROR] docker is not installed on host." >&2
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "[ERROR] docker compose plugin is required." >&2
  exit 1
fi

if [[ ! -f docker-compose.pi4.yml ]]; then
  echo "[ERROR] run this script from repository root." >&2
  exit 1
fi

run_in_pi4() {
  docker compose -f docker-compose.pi4.yml exec -T picoclaw-pi4 bash -lc "$*"
}

echo "[INFO] Ensuring Pi4 container is running..."
docker compose -f docker-compose.pi4.yml up -d

echo "[STEP] Environment info"
run_in_pi4 'uname -a && uname -m && go version'

echo "[STEP] Build PicoClaw in arm64 container"
run_in_pi4 'make build'

echo "[STEP] Install PicoClaw"
run_in_pi4 'make install'

echo "[STEP] Basic CLI check"
run_in_pi4 'export PATH="$HOME/.local/bin:$PATH"; picoclaw --help | head -n 40'

echo "[STEP] Initialize workspace"
run_in_pi4 'export PATH="$HOME/.local/bin:$PATH"; picoclaw onboard'

echo "[STEP] Prepare runtime config"
run_in_pi4 'mkdir -p ~/.picoclaw && cp -f config/config.example.json ~/.picoclaw/config.json'

echo "[STEP] Offline smoke test (no API keys required)"
run_in_pi4 'export PATH="$HOME/.local/bin:$PATH"; picoclaw agent -m "health check" || true'

echo "[NOTE] Full agent/channel integration tests need real API keys/tokens."
echo "[DONE] Pi4 Docker test workflow completed."
