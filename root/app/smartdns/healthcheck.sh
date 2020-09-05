#!/bin/sh

log -v smartdns "[health] Check health"

IP=$(cat /app/openvpn/ip)

var health 0

for country in $(var VPN_COUNTRY) ; do

    port=$(dict port $country)

    VPNIP=$(wget http://api.ipify.org:80$port -O - -q 2>/dev/null)
    RC=$?

    if [ $RC -eq 1 ] || [ $RC":"$VPNIP = $IP ]; then
        log -d smartdns "[health] $country: VPN down."
        echo "$country: VPN down. "
        var health 1
    else
        log -d smartdns "[health] $country: $VPNIP."
        echo "$country: $VPNIP. "
    fi
done

exit $(var health);
