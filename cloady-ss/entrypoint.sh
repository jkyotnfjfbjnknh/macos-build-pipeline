#!/bin/sh
set -e
CFG=/etc/shadowsocks-rust/config.json
mkdir -p /etc/shadowsocks-rust
if [ -z "$SS_PASSWORD" ]; then
  SS_PASSWORD=$(head -c 16 /dev/urandom | base64)
  echo "WARNING: SS_PASSWORD env not set; using a random ephemeral password for this run" >&2
fi
cat > "$CFG" <<EOF
{
    "server": "0.0.0.0",
    "server_port": 8080,
    "password": "$SS_PASSWORD",
    "method": "2022-blake3-aes-128-gcm",
    "mode": "tcp_only",
    "plugin": "/usr/local/bin/v2ray-plugin",
    "plugin_opts": "server;path=/ws"
}
EOF
exec /usr/local/bin/ssserver -c "$CFG"
