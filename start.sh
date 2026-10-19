#!/bin/bash
set -e

# 1. Atur password root dari Environment Variable atau default
SSH_PASS=${SSH_PASSWORD:-colab123}
echo "root:${SSH_PASS}" | chpasswd

# 2. Jalankan Dropbear SSH di port 22
dropbear -R -B -p 127.0.0.1:22

# 3. Dynamic UUID untuk Xray jika diset di environment Render
if [ -n "$V2RAY_UUID" ]; then
    sed -i "s/f032e3ff-7c65-40e1-aeec-91ead52c4cae/${V2RAY_UUID}/g" /etc/xray/config.json
fi

# 4. Jalankan Xray core di background
mkdir -p /var/log/xray
/usr/local/bin/xray run -config /etc/xray/config.json &

# 5. Konfigurasi Nginx agar otomatis bind ke port Render ($PORT)
HTTP_PORT=${PORT:-10000}
mkdir -p /var/www/html
echo "Server project aktif di port ${HTTP_PORT}" > /var/www/html/index.html
sed -i "s/listen [0-9]\+/listen ${HTTP_PORT}/g" /etc/nginx/conf.d/v2ray.conf
rm -f /etc/nginx/sites-enabled/default
nginx

# 6. Jalankan cron daemon
if [ -x /usr/sbin/cron ]; then
    /usr/sbin/cron &
fi

# 7. Jalankan Cloudflare Tunnel
# Jika mengisi TUNNEL_TOKEN di environment Render, gunakan named tunnel permanen
if [ -n "$TUNNEL_TOKEN" ]; then
    exec cloudflared tunnel run --token "$TUNNEL_TOKEN"
else
    exec cloudflared tunnel --url tcp://127.0.0.1:22
fi
