#!/bin/sh
# cloady-ss-ts: ssserver in the foreground (the app's main process),
# tailscaled in userspace networking mode supervised in the background.
# Join behaviour:
#   - TS_AUTHKEY set  -> automatic join on every (re)start; use a reusable
#     *ephemeral* key, pod rebuilds register a fresh node and the old one
#     disappears from the tailnet on its own.
#   - TS_AUTHKEY empty -> `tailscale up` prints a login URL into the
#     container log for one-off manual approval.
mkdir -p /var/lib/tailscale /var/run/tailscale

(
  while true; do
    /usr/local/bin/tailscaled \
      --tun=userspace-networking \
      --state=/var/lib/tailscale/tailscaled.state \
      --socket=/var/run/tailscale/tailscaled.sock \
      --socks5-server=localhost:1055 \
      --outbound-http-proxy-listen=localhost:1055 &
    TS_PID=$!
    i=0
    while [ ! -S /var/run/tailscale/tailscaled.sock ] && [ $i -lt 30 ]; do
      sleep 1; i=$((i + 1))
    done
    if [ -n "${TS_AUTHKEY:-}" ]; then
      /usr/local/bin/tailscale --socket=/var/run/tailscale/tailscaled.sock up \
        --auth-key="$TS_AUTHKEY" \
        --hostname="${TS_HOSTNAME:-cloady-jp}" \
        --advertise-exit-node \
        --accept-dns=false &
    else
      /usr/local/bin/tailscale --socket=/var/run/tailscale/tailscaled.sock up \
        --hostname="${TS_HOSTNAME:-cloady-jp}" \
        --advertise-exit-node \
        --accept-dns=false &
    fi
    wait $TS_PID
    sleep 5
  done
) &

/usr/local/bin/ssserver -c /etc/shadowsocks-rust/config.json
