#!/bin/bash

SSH_PASS=${SSH_PASSWORD:-colab123}
echo "root:${SSH_PASS}" | chpasswd

# Jalankan Dropbear di semua interface (0.0.0.0) port 22
exec dropbear -R -B -p 0.0.0.0:22 -F
