#!/bin/sh

cp -f /etc/10-smartdns.conf /etc/dnsmasq.d/
mkdir -p /app/sniproxy/state
sed -i "s/{IP}/$SERVERIP/g" /etc/dnsmasq.d/10-smartdns.conf

echo "" >> /etc/supervisord.conf
cat /app/sniproxy/supervisord.conf >> /etc/supervisord.conf
