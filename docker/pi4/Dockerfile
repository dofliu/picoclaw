FROM --platform=linux/arm64 arm64v8/debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    make \
    jq \
    bash \
    build-essential \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

ARG GO_VERSION=1.25.1
RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-arm64.tar.gz" -o /tmp/go.tar.gz \
    && rm -rf /usr/local/go \
    && tar -C /usr/local -xzf /tmp/go.tar.gz \
    && rm -f /tmp/go.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"
ENV PICOCLAW_HOME=/workspace/.picoclaw

WORKDIR /workspace/picoclaw

CMD ["bash"]
