#!/bin/sh

var smartdns.anyup false
for country in $(var VPN_COUNTRY)
do
    if [ -f /app/openvpn/config-$country.ovpn ]
    then
        var smartdns.anyup true
    else
        log -e "No $country vpn. Services affected: $(var -k smartdns.country -w $country | tr '\n' ' ') "
    fi
done

if [ "$(var smartdns.anyup)" == "true" ]
then
    exit 0;
fi

exit 1;
