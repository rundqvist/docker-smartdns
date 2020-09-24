FROM rundqvist/openvpn-sniproxy:latest

LABEL maintainer="mattias.rundqvist@icloud.com"

WORKDIR /app

COPY root /

ENV HOST_IP='' \
    SMARTDNS_SERVICES=''

VOLUME [ "/etc/dnsmasq.d" ]

EXPOSE 53 80 443

HEALTHCHECK --interval=180s --timeout=120s --start-period=30s \  
 CMD /bin/sh /app/healthcheck.sh
