#!/bin/sh

for var in "VPN_PROVIDER" "VPN_USERNAME" "VPN_PASSWORD" "SMARTDNS_SERVICES" "HOST_IP"; do 

    if [ -z "$(var $var)" ] ; then
        log -e smartdns "Environment variable '$var' is mandatory. "
        var abort true
    else
        log -d smartdns "Mandatory variable '$var' is ok."
    fi

done

for service in $(var SMARTDNS_SERVICES)
do
    entry=$(cat /app/smartdns/smartdns.country.conf | grep "$service")

    if [ -z "$entry" ] 
    then
        log -i smartdns "Service '$service' isn't supported. Valid services are: $(cat /app/smartdns/smartdns.country.conf | sed 's/\(.*\):.*/\1/g' | tr '\n' ' ')"
        exit 1;
    fi
done

if [ "$(var abort)" = "true" ] ; then
    exit 1;
fi
exit 0;
