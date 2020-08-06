#!/bin/sh

cp /etc/no-smart.conf /etc/dnsmasq.d/

sed -i "s/{IP}/$SERVERIP/g" /etc/dnsmasq.d/no-smart.conf

exec supervisord -c /etc/supervisord.conf
