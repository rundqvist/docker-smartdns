#!/bin/sh

sysctl -w net.ipv4.conf.all.rp_filter=2 >/dev/null

var VPN_MULTIPLE true
var -d VPN_COUNTRY

#
# Resolve needed countries
#
for service in $(var SMARTDNS_SERVICES) ; do
    log -d "Configuring $service"

    country=$(cat /app/smartdns/smartdns.country.conf | grep "$service" | sed 's/.*:\([A-Z]\)/\1/g')

    log -d "Service $service requires vpn $country"

    var -a VPN_COUNTRY $country
done

for country in $(var VPN_COUNTRY) ; do

    line=$(cat /app/smartdns/smartdns.port.conf | grep "$country")
    port=$range${line:3:2}

    iptables -A OUTPUT -t nat -o eth0 -p tcp --dport 80$port -j DNAT --to-destination :80
    iptables -A OUTPUT -t nat -o eth0 -p tcp --dport 81$port -j DNAT --to-destination :443
done

log -i "Creating sniproxy config"
mkdir -p /etc/sniproxy
cp -f /app/smartdns/sniproxy.template.conf /app/sniproxy/sniproxy.conf

for table in "http" "https" ; do
    echo "table $table {" >> /app/sniproxy/sniproxy.conf

    range="80"
    if [ "$table" = "https" ] ; then
        range="81"
    fi

    for service in $(var SMARTDNS_SERVICES) ; do
        country=$(cat /app/smartdns/smartdns.country.conf | grep "$service" | sed 's/.*:\([A-Z]\)/\1/g')
        line=$(cat /app/smartdns/smartdns.port.conf | grep "$country")
        port=$range${line:3:2}

        domains=$(cat /app/smartdns/smartdns.domain.conf | grep "$service:" | sed 's/.*:\(.*\)/\1/g')

        for domain in $domains ; do
            echo "$domain *:$port" >> /app/sniproxy/sniproxy.conf
        done
    done
    echo ".* *"  >> /app/sniproxy/sniproxy.conf
    echo "}" >> /app/sniproxy/sniproxy.conf
done

#setv VPN_COUNTRY "NO GB"

#sed 's/smartdns-.*/\*/g' /app/smartdns/sniproxy.conf > /etc/sniproxy/sniproxy.conf

#log -i "Exporting dnsmasq config to /etc/dnsmasq.d/10-smartdns.conf"
#sed "s/{IP}/$HOST_IP/g" /app/smartdns/10-smartdns.conf > /etc/dnsmasq.d/10-smartdns.conf
