FROM rundqvist/openvpn-sniproxy:1.1

LABEL maintainer="mattias.rundqvist@icloud.com"

WORKDIR /app

COPY root /

ENV SMARTDNS_SERVICES=''

VOLUME [ "/etc/dnsmasq.d" ]

EXPOSE 53 80 443

HEALTHCHECK --interval=60s --timeout=60s --start-period=30s \  
 CMD /bin/sh /app/healthcheck.sh
