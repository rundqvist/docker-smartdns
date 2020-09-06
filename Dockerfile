FROM rundqvist/openvpn-sniproxy:latest

LABEL maintainer="mattias.rundqvist@icloud.com"

WORKDIR /app

COPY root /

RUN apk add --update --no-cache dnsmasq

ENV HOST_IP='' \
    SMARTDNS_SERVICES=''

VOLUME [ "/etc/dnsmasq.d" ]

EXPOSE 53 80 443
