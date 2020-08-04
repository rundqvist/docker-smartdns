FROM alpine:3.12

LABEL maintainer="mattias.rundqvist@icloud.com"

WORKDIR /app

COPY root /

RUN apk add --update --no-cache supervisor sniproxy \
	&& chmod 755 entrypoint.sh

VOLUME [ "/etc/dnsmasq.d" ]

EXPOSE 80 443

ENTRYPOINT [ "/app/entrypoint.sh" ]
