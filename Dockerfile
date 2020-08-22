FROM rundqvist/supervisor:latest

LABEL maintainer="mattias.rundqvist@icloud.com"

WORKDIR /app

COPY root /

RUN apk add --update --no-cache sniproxy

ENV SERVERIP=''

VOLUME [ "/etc/dnsmasq.d" ]

EXPOSE 80 443
