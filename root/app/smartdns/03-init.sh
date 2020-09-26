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
