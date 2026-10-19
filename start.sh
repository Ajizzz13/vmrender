#!/bin/bash

# Atur password root dari Environment Variable atau default
SSH_PASS=${SSH_PASSWORD:-colab123}
echo "root:${SSH_PASS}" | chpasswd

# Jalankan Dropbear SSH di port 22
dropbear -R -B -p 127.0.0.1:22

# Jalankan HTTP server dummy agar health check Render lolos
HTTP_PORT=${PORT:-10000}
echo "Server project aktif di port ${HTTP_PORT}" > index.html
python3 -m http.server "${HTTP_PORT}" &

# Jalankan Cloudflare Tunnel
# Jika mengisi TUNNEL_TOKEN di environment Render, gunakan named tunnel permanen
if [ -n "$TUNNEL_TOKEN" ]; then
    exec cloudflared tunnel run --token "$TUNNEL_TOKEN"
else
    exec cloudflared tunnel --url tcp://127.0.0.1:22
fi
