#!/bin/sh
mkdir -p /var/lib/tailscale /var/run/tailscale /var/www
printf 'ok\n' > /var/www/index.html
httpd -p 8080 -h /var/www &
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
    --hostname="${TS_HOSTNAME:-cloady-jp}" \
    --advertise-exit-node --accept-dns=false
else
  tailscale --socket=/var/run/tailscale/tailscaled.sock up \
    --hostname="${TS_HOSTNAME:-cloady-jp}" \
    --advertise-exit-node --accept-dns=false
fi
while true; do sleep 3600; done
