#!/bin/sh

for var in "VPN_PROVIDER" "VPN_USERNAME" "VPN_PASSWORD" "SMARTDNS_SERVICES" "HOST_IP"; do 

    if [ -z "$(var $var)" ] ; then
        log -e smartdns "Environment variable '$var' is mandatory. "
        var abort true
    else
        log -d smartdns "Mandatory variable '$var' is ok."
    fi

done

if [ "$(var abort)" = "true" ] ; then
    exit 1;
fi
exit 0;
