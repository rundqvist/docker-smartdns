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

    # Check ip
    for protocol in "http" "https"
    do
        range=$(var -k vpn.range $protocol)

        log -v "Checking ip for $country $protocol $range$port (previousIp: $previousIp)."

        ip=$(echoip -m $protocol -p $range$port)

        if [ $? -eq 1 ] || [ "$ip" = "$(var publicIp)" ] || [ -z "$ip" ]
        then
            # Check failed. Delete ip and break out of loop (no need to check next port if we already have failed)
            log -d "$country ip check failed on port $range$port ($protocol). Breaking."
            var -k vpn.$country -d ip
            break
        else
            # Check success. Append (unique) ip and continue.
            log -v "$country ip is: $ip on port $range$port ($protocol)."
            var -k vpn.$country -a ip -v "$ip"
        fi
    done
    
    log -v "$country ip count: $(var -k vpn.$country -c ip)"

    # Check if country vpn is healthy.
    if [ $(var -k vpn.$country -c ip) -eq 1 ]
    then
        # One (and only one) ip stored. Vpn is healthy.
        var -k vpn.$country -d fail

        # Log ip only if differs from last check (and since we delete on fail, if vpn just recovered).
        currentIp="$(var -k vpn.$country ip)"
        if [ "$currentIp" != "$previousIp" ]
        then
            log -i "Vpn ($country) healthy. Ip is: $currentIp."
        else
            log -v "Vpn ($country) healthy. Ip is: $currentIp."
        fi
        echo "$country: $currentIp. "
    else
        # Zero or multiple ip stored. Something is wrong. Increase fail count and set this health check run to unhealthy.
        var -k vpn.$country fail + 1
        var smartdns.health 1

        # Check if we need to restart.
        count="$(var -k vpn.$country fail)"
        if [ "$count" = "3" ]
        then
            # Restart vpn if failed 3 times...
            var -k vpn.$country -d fail
            log -e "Vpn ($country) unhealthy ($count). Restarting vpn."
            pid=$(ps -o pid,args | sed -n "/openvpn\/config-$country/p" | awk '{print $1}')

            kill -s SIGHUP $pid
            echo "$country: Restarted. "
        else
            # ...otherwise just warn.
            log -w "Vpn ($country) unhealthy ($count)."
            echo "$country: Unhealthy. "
        fi
    fi
done

exit $(var smartdns.health);
