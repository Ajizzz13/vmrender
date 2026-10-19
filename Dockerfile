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
    cron \
    nginx \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install cloudflared
RUN wget -q -O /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    && chmod +x /usr/local/bin/cloudflared

# Install Xray-core
RUN wget -q -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/v24.9.30/Xray-linux-64.zip \
    && unzip -q /tmp/xray.zip xray -d /usr/local/bin/ \
    && chmod +x /usr/local/bin/xray \
    && rm -f /tmp/xray.zip

# Setup Nginx & Xray configs
RUN mkdir -p /etc/xray /etc/nginx/conf.d /var/www/html
COPY xray_config.json /etc/xray/config.json
COPY v2ray.conf /etc/nginx/conf.d/v2ray.conf

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
