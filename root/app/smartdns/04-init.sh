#!/bin/sh

#
# Resolve needed countries
#
log -i "Selected services: $(var SMARTDNS_SERVICES | tr '\n' ' ')"

for service in $(var SMARTDNS_SERVICES)
do
    country=$(var -k smartdns.country "$service")
    if [ $? -eq 1 ] 
    then
        log -e "Service '$service' isn't supported."
        log -i "Valid services are:"
        for validService in $(var -k smartdns.country)
        do
            log -i "- $validService"
        done
        exit 1;
    fi

    log -v "Service '$service' requires $country vpn."
    var -a VPN_COUNTRY -v $country
done

log -i "Selected services require $(var VPN_COUNTRY | wc -l) vpn connection(s). Countries: $(var VPN_COUNTRY | tr '\n' ' ')"

#
# Route all requests to 80/443
#
var port 10
for country in $(var VPN_COUNTRY)
do
    port=$(var port)
    http=$(var -k vpn.range http)
    https=$(var -k vpn.range https)

    log -v "Configuring vpn $country to use ports $http$port (http) and $https$port (https)"

    var -k port $country $port

    log -v "Add nat ($country): iptables -A OUTPUT -t nat -o eth0 -p tcp --dport $http$port -j DNAT --to-destination :80"
    iptables -A OUTPUT -t nat -o eth0 -p tcp --dport $http$port -j DNAT --to-destination :80

    log -v "Add nat ($country): iptables -A OUTPUT -t nat -o eth0 -p tcp --dport $https$port -j DNAT --to-destination :443"
    iptables -A OUTPUT -t nat -o eth0 -p tcp --dport $https$port -j DNAT --to-destination :443

    var port + 1
done
var -d port

#
# Create sniproxy.conf
#

> /app/smartdns/10-smartdns-tmp.conf
log -d "Creating sniproxy config."
mkdir -p /etc/sniproxy
cp -f /app/smartdns/sniproxy.template.conf /app/sniproxy/sniproxy.conf

for protocol in "http" "https"
do
    range=$(var -k vpn.range $protocol)

    echo "table $protocol {" >> /app/sniproxy/sniproxy.conf

    for service in $(var SMARTDNS_SERVICES)
    do
        country=$(var -k smartdns.country "$service");
        port=$(var -k port $country)

        log -d "Configuring service $service to use vpn $country and port $range$port for $protocol.";

        for domain in $(var -k smartdns.domain $service)
        do
            echo "$domain *:$range$port" >> /app/sniproxy/sniproxy.conf
            log -v "Adding: $domain *:$range$port."

            d=$(echo "$domain" | sed -e "s/[\\]//g" -e "s/^\([^*]*\*\)\.//g")
            echo "address=/$d/$(var HOST_IP)" >> /app/smartdns/10-smartdns-tmp.conf
        done
    done
    echo ".* *" >> /app/sniproxy/sniproxy.conf
    echo "}" >> /app/sniproxy/sniproxy.conf
done

cat /app/smartdns/10-smartdns-tmp.conf | sort -u > /app/smartdns/10-smartdns.conf
rm -f /app/smartdns/10-smartdns-tmp.conf
cp -f /app/smartdns/10-smartdns.conf /etc/dnsmasq.d/10-smartdns.conf

if [ -f /etc/dnsmasq.d/10-sniproxy.conf ] ; then
    log -v "Removing /etc/dnsmasq.d/10-sniproxy.conf."
    rm -f /etc/dnsmasq.d/10-sniproxy.conf
fi
