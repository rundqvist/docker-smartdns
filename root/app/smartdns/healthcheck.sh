#!/bin/sh

# Reset health
var smartdns.health 0

# Perform health check for each country
for country in $(var VPN_COUNTRY)
do
    port=$(var -k port $country)    
    previousIp="$(var -k vpn.$country ip)"

    # Delete stored ip
    var -k vpn.$country -d ip

    for protocol in "http" "https"
    do
        # Sleep to not spam ipify.org
        sleep 1

        range=$(var -k vpn.range $protocol)

        log -v smartdns "Checking ip for $country $protocol $range$port (previousIp: $previousIp)."

        ip=$(wget $protocol://api.ipify.org:$range$port -T 10 -O - -q 2>/dev/null)

        if [ $? -eq 1 ] || [ "$ip" = "$(var publicIp)" ] || [ -z "$ip" ]
        then
            log -d smartdns "$country ip check failed on port $range$port ($protocol). Breaking."
            var -k vpn.$country -d ip
            break
        else
            log -v smartdns "$country ip is: $ip on port $range$port ($protocol)."
            var -k vpn.$country -a ip -v "$ip"
        fi
    done
    
    log -v smartdns "$country ip count: $(var -k vpn.$country -c ip)"

    if [ $(var -k vpn.$country -c ip) -eq 1 ]
    then
        #success
        var -k vpn.$country -d fail
        currentIp="$(var -k vpn.$country ip)"
        if [ "$currentIp" != "$previousIp" ]
        then
            log -i smartdns "Vpn ($country) healthy. Ip is: $currentIp."
        else
            log -v smartdns "Vpn ($country) healthy. Ip is: $currentIp."
        fi
        echo "$country: $currentIp. "
    else
        #fail
        var -k vpn.$country fail + 1
        var smartdns.health 1

        count="$(var -k vpn.$country fail)"
        if [ "$count" = "3" ]
        then
            var -k vpn.$country -d fail
            log -e smartdns "Vpn ($country) unhealthy ($count). Restarting vpn."
            pid=$(ps -o pid,args | sed -n "/openvpn\/config-$country/p" | awk '{print $1}')

            kill -s SIGHUP $pid
            echo "$country: Restarted. "
        else
            log -w smartdns "Vpn ($country) unhealthy ($count)."
            echo "$country: Unhealthy. "
        fi
    fi
done

exit $(var smartdns.health);
