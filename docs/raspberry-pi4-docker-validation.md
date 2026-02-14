# Raspberry Pi 4 Docker Validation Guide (ARM64)

This document provides a **full, reproducible workflow** to create a Raspberry Pi 4-like Docker environment (`linux/arm64`), deploy PicoClaw, and validate runtime behavior before moving to real Pi 4 hardware.

> Scope: host machine (x86_64 or arm64) + Docker Engine + Docker Compose.

## 1. Prerequisites on host

```bash
docker --version
docker compose version
```

If your host is `x86_64`, install QEMU/binfmt for cross-architecture emulation:

```bash
docker run --privileged --rm tonistiigi/binfmt --install arm64
```

## 2. Build & start Pi4-like environment

```bash
# From repository root
bash scripts/pi4-docker-up.sh
```

Manual equivalent:

```bash
docker compose -f docker-compose.pi4.yml build --no-cache
docker compose -f docker-compose.pi4.yml up -d
```

Enter container shell:

```bash
docker compose -f docker-compose.pi4.yml exec picoclaw-pi4 bash
```

## 3. Deploy PicoClaw in container

Inside container:

```bash
make build
make install
export PATH="$HOME/.local/bin:$PATH"
picoclaw --help
picoclaw onboard
```

Prepare config:

```bash
mkdir -p ~/.picoclaw
cp config/config.example.json ~/.picoclaw/config.json
nano ~/.picoclaw/config.json
```

## 4. One-command test pipeline

```bash
bash scripts/pi4-docker-test.sh
```

This script runs:
- arm64 environment check (`uname -m`, `go version`)
- build (`make build`)
- install (`make install`)
- cli sanity (`picoclaw --help`)
- workspace init (`picoclaw onboard`)
- offline smoke (`picoclaw agent -m "health check"`)

## 5. Full feature validation checklist (all intelligent-agent functions)

To validate **all capabilities**, provide real tokens in `~/.picoclaw/config.json` (inside container) and run the following matrix.

### 5.1 Core agent abilities

```bash
picoclaw agent -m "請建立一個 TODO 清單並儲存到 workspace"
picoclaw agent -m "幫我搜尋最近一週的 AI 新聞，整理重點"
picoclaw agent -m "讀取專案 README 並摘要"
```

Expected: model response, tool usage logs, workspace file outputs.

### 5.2 Tools validation

```bash
picoclaw agent -m "請用 shell 指令顯示目前目錄檔案"
picoclaw agent -m "建立 test.txt 並寫入 hello"
picoclaw agent -m "幫我規劃每日上午九點提醒事項"
```

Expected: shell/file/cron related behavior appears in outputs and workspace.

### 5.3 Channel/bot integration (optional but recommended)

Configure one by one and launch gateway:

```bash
picoclaw gateway
```

Validate each channel by sending a real message:
- Discord
- Telegram
- Slack
- Feishu / DingTalk / WhatsApp / QQ / MaixCAM (if used)

Expected: inbound message received, agent generates reply, no crash/restart loops.

## 6. Export same setup to real Raspberry Pi 4

After Docker validation is stable, deploy on real Pi4 with the same steps:

1. Install dependencies and Go
2. `make build && make install`
3. Copy verified `~/.picoclaw/config.json`
4. Run `picoclaw gateway`
5. (Optional) enable `systemd --user` service

Reference production guide: `docs/raspberry-pi4-deployment.md`.

## 7. Limitations and parity notes

- Docker arm64 on x86 uses emulation; performance differs from real Pi4.
- Hardware-specific peripherals (camera, GPIO, audio devices) are not fully represented.
- API/network-dependent behavior still requires real credentials and outbound network.

Despite these limitations, this workflow is valid for **build correctness, runtime CLI behavior, configuration validation, and major agent feature smoke tests**.

