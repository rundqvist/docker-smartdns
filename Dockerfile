FROM rundqvist/openvpn:multiple

LABEL maintainer="mattias.rundqvist@icloud.com"

WORKDIR /app

COPY root /

#RUN apk add --update --no-cache sniproxy curl iptraf-ng
RUN apk update; apk add sniproxy curl iptraf-ng

ENV HOST_IP=''

VOLUME [ "/etc/dnsmasq.d" ]

EXPOSE 80 443
