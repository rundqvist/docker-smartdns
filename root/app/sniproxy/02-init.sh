#!/bin/sh

log -i "Creating sniproxy config"
mkdir -p /etc/sniproxy
mkdir -p /app/sniproxy/state
sed 's/smartdns-.*/\*/g' /app/sniproxy/sniproxy.conf > /etc/sniproxy/sniproxy.conf

log -i "Exporting dnsmasq config to /etc/dnsmasq.d/10-smartdns.conf"
sed "s/{IP}/$HOST_IP/g" /app/sniproxy/10-smartdns.conf > /etc/dnsmasq.d/10-smartdns.conf
