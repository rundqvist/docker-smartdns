# Docker SmartDNS for unblocking geo restrictions
A smart dns container for unblocking geo restrictions.

[![docker pulls](https://img.shields.io/docker/pulls/rundqvist/smartdns.svg)](https://hub.docker.com/r/rundqvist/smartdns)
[![image size](https://img.shields.io/docker/image-size/rundqvist/smartdns.svg)](https://hub.docker.com/r/rundqvist/smartdns)
[![commit activity](https://img.shields.io/github/commit-activity/m/rundqvist/docker-smartdns)](https://github.com/rundqvist/docker-smartdns)
[![last commit](https://img.shields.io/github/last-commit/rundqvist/docker-smartdns.svg)](https://github.com/rundqvist/docker-smartdns)

## Do you find this container useful? 
Please support the development by making a small donation.

[![Support](https://img.shields.io/badge/support-Flattr-brightgreen)](https://flattr.com/@rundqvist)
[![Support](https://img.shields.io/badge/support-Buy%20me%20a%20coffee-orange)](https://www.buymeacoffee.com/rundqvist)
[![Support](https://img.shields.io/badge/support-PayPal-blue)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=SZ7J9JL9P5DGE&source=url)

## Features
* Unblocks geo restrictions

## Supported services
* DR - [dr.dk](https://www.dr.dk/drtv/)
* NRK - [nrk.no](https://tv.nrk.no)
* SVT Play - [svtplay.se](https://svtplay.se)
* TV Player - [tvplayer.com](https://tvplayer.com/) (account needed)
* USTVGO - [ustvgo.tv](https://ustvgo.tv)
* USTV247 - [ustv247.tv](https://ustv247.tv)
* YLE - [yle.fi](https://areena.yle.fi/tv) (live tv only)

## Requirements
* Port 80 & 443 available
* A supported VPN account (currently [IPVanish](https://www.ipvanish.com/?a_bid=48f95966&a_aid=5f3eb2f0be07f) or [WeVPN](https://www.wevpn.com/aff/rundqvist))

[![Sign up](https://img.shields.io/badge/sign_up-IPVanish_VPN-6fbc44)](https://www.ipvanish.com/?a_bid=48f95966&a_aid=5f3eb2f0be07f)
[![Sign up](https://img.shields.io/badge/sign_up-WeVPN-e33866)](https://www.wevpn.com/aff/rundqvist)

## Components
* Base container: https://hub.docker.com/r/rundqvist/openvpn-sniproxy
* SNI Proxy (https://github.com/dlundquist/sniproxy)
* Dnsmasq

## Setup

### Example setup with smartdns as DNS server

```
$ sudo docker run \
  -d \
  --privileged \
  --name=smartdns \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  --dns 1.1.1.1 \
  --dns 1.0.0.1 \
  -p 53:53/udp \
  -p 80:80 \
  -p 443:443 \
  -v /path/to/cache:/cache/ \
  -e 'VPN_PROVIDER=[your vpn provider]' \
  -e 'VPN_USERNAME=[your vpn username]' \
  -e 'VPN_PASSWORD=[your vpn password]' \
  -e 'HOST_IP=[your server ip]' \
  -e 'SMARTDNS_SERVICES=nrk.no dr.dk tvplayer.com' \
  -e 'SMARTDNS_STANDALONE=true' \
  rundqvist/smartdns
```

Then configure your clients to use the new DNS. For example in your router.

### Example setup with external DNS
If you are using an external DNS server that utilizes dnsmasq (for example Pi-hole, https://hub.docker.com/u/pihole/), you can let the container copy needed settings to the /etc/dnsmasq.d/-folder.

Make sure docker is allowed to create a file in the /path/to/etc/dnsmasq.d/ folder.

If not, map this directory to a temp-folder and copy the 10-smartdns.conf-file to your /etc/dnsmasq.d/-folder.

```
$ sudo docker run \
  -d \
  --privileged \
  --name=smartdns \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  --dns 1.1.1.1 \
  --dns 1.0.0.1 \
  -p 80:80 \
  -p 443:443 \
  -v /path/to/etc/dnsmasq.d:/etc/dnsmasq.d/ \
  -v /path/to/cache:/cache/ \
  -e 'VPN_PROVIDER=[your vpn provider]' \
  -e 'VPN_USERNAME=[your vpn username]' \
  -e 'VPN_PASSWORD=[your vpn password]' \
  -e 'HOST_IP=[your server ip]' \
  -e 'SMARTDNS_SERVICES=nrk.no dr.dk tvplayer.com' \
  rundqvist/smartdns
```

Then restart your DNS server to include the 10-smartdns.conf-file in your config.

### Configuration
| Variable | Usage |
|----------|-------|
| HOST_IP | IP of the machine where SmartDNS and DNS server is running. |
| SMARTDNS_SERVICES | Services to unblock, separated with one space (see list of supported services above). |
| SMARTDNS_STANDALONE | Set to true if you intend to use smartdns as DNS server.

**IMPORTANT!** Container will create one VPN connection for each country needed. Be careful not to violate the terms of your VPN account.

See https://hub.docker.com/r/rundqvist/openvpn for VPN configuration

## Use
Just surf to one of the supported sites and watch without geo restrictions.

## Issues
Please report issues at https://github.com/rundqvist/docker-smartdns/issues
