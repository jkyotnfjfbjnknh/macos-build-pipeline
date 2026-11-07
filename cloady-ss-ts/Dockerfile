FROM alpine:3.21
RUN mkdir -p /tmp/ssx /tmp/vpx /tmp/tsx /usr/local/bin \
 && wget -q https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.25.0/shadowsocks-v1.25.0.x86_64-unknown-linux-musl.tar.xz -O /tmp/ss.tar.xz \
 && unxz -ck /tmp/ss.tar.xz | tar -xf - -C /tmp/ssx \
 && cp /tmp/ssx/ssserver /usr/local/bin/ssserver \
 && wget -q https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.3.2/v2ray-plugin-linux-amd64-v1.3.2.tar.gz -O /tmp/vp.tar.gz \
 && tar -xzf /tmp/vp.tar.gz -C /tmp/vpx \
 && cp /tmp/vpx/v2ray-plugin_linux_amd64 /usr/local/bin/v2ray-plugin \
 && wget -q https://pkgs.tailscale.com/stable/tailscale_1.102.3_amd64.tgz -O /tmp/ts.tgz \
 && tar -xzf /tmp/ts.tgz -C /tmp/tsx --strip-components=1 \
 && cp /tmp/tsx/tailscale /tmp/tsx/tailscaled /usr/local/bin/ \
 && chmod 755 /usr/local/bin/ssserver /usr/local/bin/v2ray-plugin /usr/local/bin/tailscale /usr/local/bin/tailscaled \
 && rm -rf /tmp/ssx /tmp/vpx /tmp/tsx /tmp/ss.tar.xz /tmp/vp.tar.gz /tmp/ts.tgz
COPY config.json /etc/shadowsocks-rust/config.json
COPY start.sh /usr/local/bin/start.sh
RUN chmod 755 /usr/local/bin/start.sh
EXPOSE 8080
CMD ["/bin/sh", "/usr/local/bin/start.sh"]
