#!/bin/bash
mkdir -p /var/lib/tailscale /var/run/tailscale /var/lib/vnstat /run/nginx

IFACE=$(ip route show default 2>/dev/null | awk '{print $5; exit}')
[ -z "$IFACE" ] && IFACE=eth0
vnstat -i "$IFACE" --add 2>/dev/null || true
(
  while true; do
    vnstatd -n
    sleep 2
  done
) &
(
  while true; do
    nginx -g 'daemon off;'
    sleep 2
  done
) &
(
  while true; do
    ssserver -c /etc/cloady-ubuntu/config.json
    sleep 2
  done
) &
(
  while true; do
    tailscaled --tun=userspace-networking \
      --state=/var/lib/tailscale/tailscaled.state \
      --socket=/var/run/tailscale/tailscaled.sock \
      --socks5-server=localhost:1055 \
      --outbound-http-proxy-listen=localhost:1055
    sleep 2
  done
) &
for i in $(seq 1 30); do
  [ -S /var/run/tailscale/tailscaled.sock ] && break
  sleep 1
done
if [ -s /etc/tailscale/authkey ]; then
  tailscale --socket=/var/run/tailscale/tailscaled.sock up \
    --auth-key="$(cat /etc/tailscale/authkey)" \
    --hostname=cloady-de \
    --advertise-exit-node --accept-dns=false || true
fi
while true; do sleep 3600; done
