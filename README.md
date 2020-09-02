# Docker SmartDNS for unblocking geo restrictions
A smart dns container for unblocking geo restrictions.

[![Docker pulls](https://img.shields.io/docker/pulls/rundqvist/smartdns.svg)](https://hub.docker.com/r/rundqvist/smartdns)

# Appreciate my work?
Do you find this container useful? Please consider a donation.

[![Donate](https://img.shields.io/badge/Donate-Flattr-brightgreen)](https://flattr.com/@rundqvist)
[![Donate](https://img.shields.io/badge/Donate-Buy%20me%20a%20coffee-orange)](https://www.buymeacoffee.com/rundqvist)
[![Donate](https://img.shields.io/badge/Donate-PayPal-blue)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=SZ7J9JL9P5DGE&source=url)

## Features
* Unblocks geo restrictions

## Supported services
* NRK (https://tv.nrk.no)
* DR (https://www.dr.dk/drtv/)
* TVPlayer (https://tvplayer.com/, account needed)
* USTVGO, USTV247 (https://ustvgo.tv, https://ustv247.tv)

## Requirements
* A local DNS server that utilizes dnsmasq (for example Pi-hole, https://hub.docker.com/u/pihole/)
* Port 80 & 443 available
* A supported VPN account (See base image for supported vpn providers: https://hub.docker.com/r/rundqvist/openvpn)

[![Affiliate](https://img.shields.io/badge/Affiliate-IPVanish_VPN-6fbc44)](https://www.ipvanish.com/?a_bid=48f95966&a_aid=5f3eb2f0be07f)
[![Affiliate](https://img.shields.io/badge/Affiliate-WeVPN-e33866)](https://www.wevpn.com/aff/rundqvist)

## Components
* Base container: https://hub.docker.com/r/rundqvist/openvpn-sniproxy
* SNI Proxy (https://github.com/dlundquist/sniproxy)

## Setup

### Create network
```
$ docker network create --subnet=172.20.0.0/16 smartdns
```

### Setup main container
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
  -e 'SMARTDNS_SERVICES=nrk.no dr.dk tvplayer.com ustvgo.com ustv247.tv' \
  rundqvist/smartdns
```

### Configuration
| Variable | Usage |
|----------|-------|
| HOST_IP | IP of the machine where SmartDNS and DNS server is running |
| SMARTDNS_SERVICES | Services to unblock, separated with one space. Valid values are: nrk.no, dr.dk, tvplayer.com, ustvgo.com and ustv247.tv. |

**IMPORTANT!** Container will create one VPN connection for each country needed. Be careful not to violate the terms of your VPN account.

See https://hub.docker.com/r/rundqvist/openvpn for VPN configuration

### Restart DNS Server
Restart your DNS server to include the 10-smartdns.conf-file in your config.

## Use
Just surf to one of the supported sites and watch without geo restrictions.

## Issues
Please report issues at https://github.com/rundqvist/docker-smartdns/issues
