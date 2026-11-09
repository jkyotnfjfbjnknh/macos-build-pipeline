FROM ubuntu:24.04
ENV TZ=Asia/Shanghai DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      nginx vnstat curl jq dnsutils iputils-ping iproute2 procps vim-tiny \
      ca-certificates tzdata wget xz-utils \
 && rm -rf /var/lib/apt/lists/* \
 && ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN mkdir -p /tmp/tsx /tmp/ssx /tmp/vpx \
 && wget -q https://pkgs.tailscale.com/stable/tailscale_1.102.3_amd64.tgz -O /tmp/ts.tgz \
 && tar -xzf /tmp/ts.tgz -C /tmp/tsx --strip-components=1 \
 && cp /tmp/tsx/tailscale /tmp/tsx/tailscaled /usr/local/bin/ \
 && wget -q https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.25.0/shadowsocks-v1.25.0.x86_64-unknown-linux-musl.tar.xz -O /tmp/ss.tar.xz \
 && unxz -ck /tmp/ss.tar.xz | tar -xf - -C /tmp/ssx \
 && cp /tmp/ssx/ssserver /usr/local/bin/ssserver \
 && wget -q https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.3.2/v2ray-plugin-linux-amd64-v1.3.2.tar.gz -O /tmp/vp.tar.gz \
 && tar -xzf /tmp/vp.tar.gz -C /tmp/vpx \
 && cp /tmp/vpx/v2ray-plugin_linux_amd64 /usr/local/bin/v2ray-plugin \
 && chmod 755 /usr/local/bin/ssserver /usr/local/bin/v2ray-plugin /usr/local/bin/tailscale /usr/local/bin/tailscaled \
 && rm -rf /tmp/tsx /tmp/ssx /tmp/vpx /tmp/ts.tgz /tmp/ss.tar.xz /tmp/vp.tar.gz \
 && mkdir -p /var/lib/tailscale /var/run/tailscale /etc/tailscale /var/lib/vnstat
RUN --mount=type=secret,id=ts_authkey if [ -s /run/secrets/ts_authkey ]; then cp /run/secrets/ts_authkey /etc/tailscale/authkey && chmod 600 /etc/tailscale/authkey; fi
COPY config.json /etc/cloady-ubuntu/config.json
COPY nginx.conf /etc/nginx/sites-available/default
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
EXPOSE 8080
CMD ["/usr/local/bin/start.sh"]
