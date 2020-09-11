#!/bin/sh

if ! var -e HOST_IP; then
    log -e smartdns "HOST_IP missing or wrong format. ";
    exit 1;
fi

sysctl -w net.ipv4.conf.all.rp_filter=2 >/dev/null

var VPN_MULTIPLE true
var VPN_KILLSWITCH false
var -d VPN_COUNTRY

#
# Resolve needed countries
#
for service in $(var SMARTDNS_SERVICES) ; do
    log -d smartdns "Configuring $service"
    country=$(cat /app/smartdns/smartdns.country.conf | grep "$service" | sed 's/.*:\([A-Z]\)/\1/g')

    log -d smartdns "Service $service requires vpn $country"
    var -a VPN_COUNTRY $country
done

#
# Route all requests to 80/443
#
var port 10
for country in $(var VPN_COUNTRY) ; do
    
    log -d smartdns "Configuring vpn country $country to use ports 80$(var port) and 81$(var port)"

    dict port $country $(var port)

    log -v smartdns "Add nat ($country): iptables -A OUTPUT -t nat -o eth0 -p tcp --dport 80$(var port) -j DNAT --to-destination :80"
    iptables -A OUTPUT -t nat -o eth0 -p tcp --dport 80$(var port) -j DNAT --to-destination :80

    log -v smartdns "Add nat ($country): iptables -A OUTPUT -t nat -o eth0 -p tcp --dport 81$(var port) -j DNAT --to-destination :443"
    iptables -A OUTPUT -t nat -o eth0 -p tcp --dport 81$(var port) -j DNAT --to-destination :443

    var port $(($(var port) + 1))
done
var -d port

#
# Create sniproxy.conf
#

> /app/smartdns/10-smartdns-tmp.conf
log -i smartdns "Creating sniproxy config"
mkdir -p /etc/sniproxy
cp -f /app/smartdns/sniproxy.template.conf /app/sniproxy/sniproxy.conf

for table in "http" "https" ; do
    echo "table $table {" >> /app/sniproxy/sniproxy.conf

    range="80"
    if [ "$table" = "https" ] ; then
        range="81"
    fi

    for service in $(var SMARTDNS_SERVICES) ; do
        country=$(cat /app/smartdns/smartdns.country.conf | grep "$service" | sed 's/.*:\([A-Z]\)/\1/g');
        domains=$(cat /app/smartdns/smartdns.domain.conf | grep "$service:" | sed 's/.*:\(.*\)/\1/g');

        log -d smartdns "Configuring service $service to use vpn $country and port $range$(dict port $country) for $table";

        for domain in $domains ; do
            echo "$domain *:$range$(dict port $country)" >> /app/sniproxy/sniproxy.conf
            log -v smartdns "Adding: $domain *:$range$(dict port $country)"

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
    log -v smartdns "Removing /etc/dnsmasq.d/10-sniproxy.conf"
    rm -f /etc/dnsmasq.d/10-sniproxy.conf
fi
