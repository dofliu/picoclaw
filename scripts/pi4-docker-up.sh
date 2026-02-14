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

echo "[INFO] Building Pi4 (linux/arm64) development container..."
docker compose -f docker-compose.pi4.yml build --no-cache

echo "[INFO] Starting Pi4 development container..."
docker compose -f docker-compose.pi4.yml up -d

echo "[DONE] Container is ready: picoclaw-pi4"
echo "Attach shell with: docker compose -f docker-compose.pi4.yml exec picoclaw-pi4 bash"
