#!/bin/sh

if [ "$(var SMARTDNS_STANDALONE)" = "true" ] ; then
    if [ "$(ps | grep "dnsmasq" | wc -l)" -gt 1 ] ; then
        log -d dnsmasq "[health] DNSmasq is running."
    else
        log -e dnsmasq "[health] DNSmasq is not running."
        exit 1;
    fi
fi

exit 0;
