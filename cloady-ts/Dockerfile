FROM alpine:3.21
RUN apk add --no-cache ca-certificates \
 && wget -q https://pkgs.tailscale.com/stable/tailscale_1.102.3_amd64.tgz -O /tmp/ts.tgz \
 && tar -xzf /tmp/ts.tgz -C /tmp \
 && cp /tmp/tailscale_1.102.3_amd64/tailscale /tmp/tailscale_1.102.3_amd64/tailscaled /usr/local/bin/ \
 && rm -rf /tmp/ts.tgz /tmp/tailscale_1.102.3_amd64 \
 && mkdir -p /var/lib/tailscale /var/run/tailscale /etc/tailscale /var/www
RUN --mount=type=secret,id=ts_authkey if [ -s /run/secrets/ts_authkey ]; then cp /run/secrets/ts_authkey /etc/tailscale/authkey && chmod 600 /etc/tailscale/authkey; fi
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
EXPOSE 8080
CMD ["/usr/local/bin/start.sh"]
