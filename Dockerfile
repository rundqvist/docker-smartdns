FROM rundqvist/openvpn:multiple
#FROM openvpn

LABEL maintainer="mattias.rundqvist@icloud.com"

WORKDIR /app

COPY root /

#RUN apk add --update --no-cache sniproxy curl iptraf-ng
RUN apk update; apk add sniproxy curl iptraf-ng

ENV HOST_IP='' \
    SMARTDNS_SERVICES='nrk.no dr.dk tvplayer.com ustvgo.com'

VOLUME [ "/etc/dnsmasq.d" ]

EXPOSE 80 443
