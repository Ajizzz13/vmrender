FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    dropbear \
    curl \
    wget \
    python3 \
    git \
    tmux \
    procps \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q -O /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    && chmod +x /usr/local/bin/cloudflared

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
