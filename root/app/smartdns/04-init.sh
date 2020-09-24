#!/bin/sh

sysctl -w net.ipv4.conf.all.rp_filter=2 >/dev/null

var VPN_MULTIPLE true
var VPN_KILLSWITCH false
var -d VPN_COUNTRY

var -k vpn.range http 80
var -k vpn.range https 81

var -k smartdns.domain -a dr.dk -v 'dr\.dk'
var -k smartdns.domain -a dr.dk -v 'dr.*\.akamaized\.net'
var -k smartdns.domain -a dr.dk -v 'dr.*\.akamaihd\.net'
var -k smartdns.domain -a dr.dk -v 'dr-massive\.com'

var -k smartdns.domain -a itv.com -v 'itv\.com'
var -k smartdns.domain -a itv.com -v 'itvstatic\.com'
var -k smartdns.domain -a itv.com -v 'ssl-itv.*\.2cnt\.net'
var -k smartdns.domain -a itv.com -v 'itv.*\.conductrics\.com'
var -k smartdns.domain -a itv.com -v 'itv.*\.irdeto\.com'
var -k smartdns.domain -a itv.com -v 'http-inputs-itv\.splunkcloud\.com'
var -k smartdns.domain -a itv.com -v 'europe-west1-itv-ds-prd\.cloudfunctions\.net'
# var -k smartdns.domain -a itv.com -v 'toots-a\.akamaihd\.net'
# var -k smartdns.domain -a itv.com -v 'serverby\.flashtalking\.com'
# var -k smartdns.domain -a itv.com -v 'd9\.flashtalking\.com'

var -k smartdns.domain -a nrk.no -v 'nrk\.no'
var -k smartdns.domain -a nrk.no -v 'nrk.*\.akamaihd\.net'
var -k smartdns.domain -a nrk.no -v 'nrk.*\.akamaized\.net'
var -k smartdns.domain -a nrk.no -v 'nrk.*\.ip-only\.net'

var -k smartdns.domain -a svtplay.se -v 'svtplay\.se'
var -k smartdns.domain -a svtplay.se -v 'svt\.se'
var -k smartdns.domain -a svtplay.se -v 'svtstatic\.se'
var -k smartdns.domain -a svtplay.se -v 'svt.*\.akamaized\.net'
var -k smartdns.domain -a svtplay.se -v 'svt.*\.akamaihd\.net'
var -k smartdns.domain -a svtplay.se -v 'svt.*\.footprint\.net'

var -k smartdns.domain -a tvplayer.com -v 'tvplayer\.com'
var -k smartdns.domain -a tvplayer.com -v 'tvplayer-cdn\.com'

var -k smartdns.domain -a ustvgo.tv -v 'ustvgo\.tv'
var -k smartdns.domain -a ustvgo.tv -v 'ustv24h\.live'
var -k smartdns.domain -a ustvgo.tv -v 'stackpathcdn\.com'

var -k smartdns.domain -a ustv247.tv -v 'ustv247\.tv'
var -k smartdns.domain -a ustv247.tv -v 'ustv24h\.live'
var -k smartdns.domain -a ustv247.tv -v 'stackpathcdn\.com'

var -k smartdns.domain -a yle.fi -v 'yle\.fi'
var -k smartdns.domain -a yle.fi -v 'yle.*\.omtrdc\.net'
var -k smartdns.domain -a yle.fi -v 'yle.*\.akamaihd\.net'
var -k smartdns.domain -a yle.fi -v 'yle.*\.akamaized\.net'
var -k smartdns.domain -a yle.fi -v 'ylestatic\.fi'
var -k smartdns.domain -a yle.fi -v 'yle\.demdex\.net'
# var -k smartdns.domain -a yle.fi -v 'e4669\.dscd\.akamaiedge\.net'
# var -k smartdns.domain -a yle.fi -v 'e1315\.dsca\.akamaiedge\.net'
# var -k smartdns.domain -a yle.fi -v 'finnpanel\.fi'
# var -k smartdns.domain -a yle.fi -v 'front-proxy\.nvp1\.ovp\.kaltura\.com'
# var -k smartdns.domain -a yle.fi -v 'cdnapisec\.kaltura\.com'

var -k smartdns.country dr.dk DK
var -k smartdns.country itv.com GB
var -k smartdns.country nrk.no NO
var -k smartdns.country svtplay.se SE
var -k smartdns.country tvplayer.com GB
var -k smartdns.country ustvgo.tv GB
var -k smartdns.country ustv247.tv GB
var -k smartdns.country yle.fi FI

#
# Resolve needed countries
#
for service in $(var SMARTDNS_SERVICES)
do
    country=$(var -k smartdns.country "$service")
    if [ $? -eq 1 ] 
    then
        log -i smartdns "Service '$service' isn't supported. Valid services are: $(var -k smartdns.country | tr '\n' ' ')."
        exit 1;
    fi

    log -v smartdns "Service '$service' requires $country vpn."
    var -a VPN_COUNTRY -v $country
done

log -i smartdns "Selected services require $(var VPN_COUNTRY | wc -l) vpn connection(s)."

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
        country=$(var -k smartdns.country "$service");
        port=$(var -k port $country)

        log -d smartdns "Configuring service $service to use vpn $country and port $range$port for $protocol.";

        for domain in $(var -k smartdns.domain $service)
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
