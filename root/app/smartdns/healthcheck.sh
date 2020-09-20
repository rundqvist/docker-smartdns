#!/bin/sh

log -v smartdns "[health] Check health"

var smartdns.health 0

for country in $(var VPN_COUNTRY) ; do

    port=$(var -k port $country)

    VPNIP=$(wget http://api.ipify.org:80$port -T 10 -O - -q 2>/dev/null)
    
    if [ $? -eq 1 ] || [ "$VPNIP" = "$(var publicIp)" ]
    then
        var -k smartdns.fail $country + 1
        count=$(var -k smartdns.fail $country)

        log -d smartdns "[health] $country: VPN down ($count)."

        echo "$country: VPN down ($count). "

        if [ "$count" = "3" ]
        then
            var -d smartdns.fail
            log -i smartdns "[health] Restarting $country VPN."
            pid=$(ps -o pid,args | sed -n "/openvpn\/config-$country/p" | awk '{print $1}')

            kill -s SIGHUP $pid
        fi
 
        var smartdns.health 1
    else
        log -d smartdns "[health] $country: $VPNIP."
        echo "$country: $VPNIP. "

        var -k smartdns.fail -d $country
    fi
done

exit $(var smartdns.health);
