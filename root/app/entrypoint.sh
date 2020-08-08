#!/bin/sh

cp /etc/10-smartdns.conf /etc/dnsmasq.d/

sed -i "s/{IP}/$SERVERIP/g" /etc/dnsmasq.d/10-smartdns.conf

exec supervisord -c /etc/supervisord.conf

