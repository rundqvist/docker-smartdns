FROM alpine:3.12

LABEL maintainer="mattias.rundqvist@icloud.com"

WORKDIR /app

COPY root /

RUN apk add --update --no-cache supervisor sniproxy \
	&& mkdir /app/state \
	&& chmod 755 /app/healthcheck.sh \
	&& chmod 755 /app/entrypoint.sh

ENV SERVERIP=''

VOLUME [ "/etc/dnsmasq.d" ]

EXPOSE 80 443

HEALTHCHECK --interval=5s --timeout=5s --start-period=5s \  
 CMD /bin/sh /app/healthcheck.sh

ENTRYPOINT [ "/app/entrypoint.sh" ]
