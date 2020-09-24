#!/bin/sh

sysctl -w net.ipv4.conf.all.rp_filter=2 >/dev/null

var VPN_MULTIPLE true
var VPN_KILLSWITCH false
var -d VPN_COUNTRY

var -k vpn.range http 80
var -k vpn.range https 81

#
# Resolve needed countries
#
for service in $(var SMARTDNS_SERVICES)
do
    country=$(cat /app/smartdns/smartdns.country.conf | grep "$service" | sed 's/.*:\([A-Z]\)/\1/g')

    log -i smartdns "Service '$service' requires $country vpn."
    var -a VPN_COUNTRY -v $country
done

#
# Route all requests to 80/443
#
var port 10
for country in $(var VPN_COUNTRY) ; do
    
    port=$(var port)
    http=$(var -k vpn.range http)
    https=$(var -k vpn.range https)

    log -v smartdns "Configuring vpn $country to use ports $http$port (http) and $https$port (https)"

    var -k port $country $port

    log -v smartdns "Add nat ($country): iptables -A OUTPUT -t nat -o eth0 -p tcp --dport $http$port -j DNAT --to-destination :80"
    iptables -A OUTPUT -t nat -o eth0 -p tcp --dport $http$port -j DNAT --to-destination :80

    log -v smartdns "Add nat ($country): iptables -A OUTPUT -t nat -o eth0 -p tcp --dport $https$port -j DNAT --to-destination :443"
    iptables -A OUTPUT -t nat -o eth0 -p tcp --dport $https$port -j DNAT --to-destination :443

    var port + 1
done
var -d port

#
# Create sniproxy.conf
#

> /app/smartdns/10-smartdns-tmp.conf
log -d smartdns "Creating sniproxy config."
mkdir -p /etc/sniproxy
cp -f /app/smartdns/sniproxy.template.conf /app/sniproxy/sniproxy.conf

for protocol in "http" "https"
do
    range=$(var -k vpn.range $protocol)

    echo "table $protocol {" >> /app/sniproxy/sniproxy.conf

    for service in $(var SMARTDNS_SERVICES)
    do
        country=$(cat /app/smartdns/smartdns.country.conf | grep "$service" | sed 's/.*:\([A-Z]\)/\1/g');
        domains=$(cat /app/smartdns/smartdns.domain.conf | grep "$service:" | sed 's/.*:\(.*\)/\1/g');
        port=$(var -k port $country)

        log -d smartdns "Configuring service $service to use vpn $country and port $range$port for $protocol.";

        for domain in $domains
        do
            echo "$domain *:$range$port" >> /app/sniproxy/sniproxy.conf
            log -v smartdns "Adding: $domain *:$range$port."

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
    log -v smartdns "Removing /etc/dnsmasq.d/10-sniproxy.conf."
    rm -f /etc/dnsmasq.d/10-sniproxy.conf
fi
