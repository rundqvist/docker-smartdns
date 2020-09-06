#!/bin/sh

if [ "$(var SMARTDNS_STANDALONE)" = "true" ] ; then
    log -i dnsmasq "Configured as stand alone. DNS server enabled.";
    cp -f /app/dnsmasq/supervisord.template.conf /app/dnsmasq/supervisord.conf
else
    log -w dnsmasq "DNS server disabled. File 10-smartdns.conf must be provided to external DNS manually."
    rm -f /app/dnsmasq/supervisord.conf
fi