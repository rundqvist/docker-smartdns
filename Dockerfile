FROM rundqvist/openvpn-sniproxy:multiple

LABEL maintainer="mattias.rundqvist@icloud.com"

WORKDIR /app

COPY root /

ENV HOST_IP='' \
    SMARTDNS_SERVICES=''

VOLUME [ "/etc/dnsmasq.d" ]

EXPOSE 80 443
