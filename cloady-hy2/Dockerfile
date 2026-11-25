FROM alpine:3.21
RUN apk add --no-cache ca-certificates openssl \
 && wget -q https://github.com/apernet/hysteria/releases/download/app%2Fv2.14.0/hysteria-linux-amd64 -O /usr/local/bin/hysteria \
 && chmod +x /usr/local/bin/hysteria \
 && mkdir -p /etc/hysteria \
 && openssl req -x509 -newkey rsa:2048 -nodes \
      -keyout /etc/hysteria/server.key -out /etc/hysteria/server.crt \
      -days 3650 -subj "/CN=cloady-hy2" \
      -addext "subjectAltName=DNS:*.cloady.io,DNS:cloady.io"
COPY config.yaml /etc/hysteria/config.yaml
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
EXPOSE 443/udp
CMD ["/usr/local/bin/start.sh"]
