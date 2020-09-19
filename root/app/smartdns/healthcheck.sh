#!/bin/sh

log -v smartdns "[health] Check health"

var health 0

for country in $(var VPN_COUNTRY) ; do

    port=$(var -k port $country)

    VPNIP=$(wget http://api.ipify.org:80$port -T 10 -O - -q 2>/dev/null)
    
    if [ $? -eq 1 ] || [ "$VPNIP" = "$(var publicIp)" ]
    then
        var -k fail $country + 1
        count=$(var -k fail $country)

        log -d smartdns "[health] $country: VPN down ($count)."

        echo "$country: VPN down ($count). "

        if [ "$count" = "3" ]
        then
            var -d fail
            log -i smartdns "Restarting $country VPN."
            pid=$(ps -o pid,args | sed -n "/openvpn\/config-$country/p" | awk '{print $1}')

            kill -s SIGHUP $pid
        fi
 
        var health 1
    else
        log -d smartdns "[health] $country: $VPNIP."
        echo "$country: $VPNIP. "

        var -k fail -d $country
    fi
done

exit $(var health);
