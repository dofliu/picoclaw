# Deploy PicoClaw on Raspberry Pi 4 (Pi OS 64-bit)

This guide targets **Raspberry Pi 4 (ARM64)** running Raspberry Pi OS Bookworm.

## 1) System preparation

```bash
sudo apt update
sudo apt install -y git make curl jq
```

Install Go 1.21+ if not already installed:

```bash
# quick check
go version
```

If `go` is missing or too old, install from official tarball (ARM64):

```bash
cd /tmp
curl -LO https://go.dev/dl/go1.25.1.linux-arm64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.25.1.linux-arm64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc
go version
```

## 2) Build and install PicoClaw

```bash
git clone https://github.com/sipeed/picoclaw.git
cd picoclaw
make build
make install
```

The installed binary path is `~/.local/bin/picoclaw`.

## 3) Initialize and configure

```bash
picoclaw onboard
cp config/config.example.json ~/.picoclaw/config.json
nano ~/.picoclaw/config.json
```

Set your provider API keys in `~/.picoclaw/config.json`.

Quick smoke test:

```bash
picoclaw agent -m "hello from raspberry pi"
```

## 4) Run as a systemd service (gateway mode)

Create service unit:

```bash
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/picoclaw-gateway.service <<'UNIT'
[Unit]
Description=PicoClaw Gateway
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
Environment=PATH=/usr/local/bin:/usr/bin:/bin:%h/.local/bin
ExecStart=%h/.local/bin/picoclaw gateway
Restart=always
RestartSec=3
WorkingDirectory=%h

[Install]
WantedBy=default.target
UNIT
```

Enable and start:

```bash
systemctl --user daemon-reload
systemctl --user enable --now picoclaw-gateway.service
journalctl --user -u picoclaw-gateway.service -f
```

(Optional) enable lingering so service starts without active login:

```bash
sudo loginctl enable-linger "$USER"
```

## 5) Docker deployment on Pi 4 (optional)

If you prefer Docker:

```bash
cp config/config.example.json config/config.json
nano config/config.json

docker compose --profile gateway up -d
```

For cross-building from x86 to Pi 4 image:

```bash
docker buildx build --platform linux/arm64 -t picoclaw:pi4 .
```

## 6) Performance tips for Pi 4

- Prefer lightweight models via OpenRouter/Zhipu to reduce latency.
- Put workspace on SSD/USB3 storage if you have long-term logs/memory.
- Use wired Ethernet for stable bot integrations (Discord/Telegram/Slack).
- Keep swap enabled if running multiple services on 2GB RAM models.

## 7) Troubleshooting

- `command not found: picoclaw`:
  - Add `~/.local/bin` to PATH.
- API provider errors:
  - Check key and endpoint in `~/.picoclaw/config.json`.
- systemd service restarts repeatedly:
  - Run `picoclaw gateway` directly first to verify config.

