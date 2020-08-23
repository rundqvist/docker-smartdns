# Docker SmartDNS for unblocking geo restrictions
A smart dns container for unblocking geo restrictions.  
https://hub.docker.com/repository/docker/rundqvist/smartdns

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
* TVPlayer (https://tvplayer.com/uk/, account needed)
* USTVGO, USTV247 (https://ustvgo.tv, https://ustv247.tv)

## Requirements
* A supported VPN account [![Sign up](https://img.shields.io/badge/Affiliate-IPVanish_VPN-6fbc44)](https://www.ipvanish.com/?a_bid=48f95966&a_aid=5f3eb2f0be07f)
* A local DNS server that utilizes dnsmasq (for example Pi-hole, https://hub.docker.com/u/pihole/)
* Port 80 & 443 available

## Components
* OpenVPN container as base (https://hub.docker.com/r/rundqvist/openvpn)
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
  --name=smartdns \
  -p 80:80 \
  -p 443:443 \
  -v /path/to/etc/dnsmasq.d:/etc/dnsmasq.d/ \
  --net smartdns \
  -e 'HOST_IP=[your server ip]' \
  rundqvist/smartdns
```

### Configuration
| Variable | Usage |
|----------|-------|
| HOST_IP | IP of the machine where SmartDNS and DNS server is running |


### Restart DNS Server
Restart your DNS server to include the 10-smartdns.conf-file in your config.

## Setup SmartDNS VPN's
IMPORTANT! Do not change the --name of the containers.

```
$ docker run \
  -d \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  --name=smartdns-no \
  --dns 1.1.1.1 \
  -e 'VPN_PROVIDER=[vpn provider]' \
  -e 'VPN_USERNAME=[vpn username]' \
  -e 'VPN_PASSWORD=[vpn password]' \
  -e 'VPN_COUNTRY=NO' \
  --net smartdns \
  rundqvist/openvpn-sniproxy

$ docker run \
  -d \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  --name=smartdns-dk \
  --dns 1.1.1.1 \
  -e 'VPN_PROVIDER=[vpn provider]' \
  -e 'VPN_USERNAME=[vpn username]' \
  -e 'VPN_PASSWORD=[vpn password]' \
  -e 'VPN_COUNTRY=DK' \
  --net smartdns \
  rundqvist/openvpn-sniproxy

$ docker run \
  -d \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  --name=smartdns-uk \
  --dns 1.1.1.1 \
  -e 'VPN_PROVIDER=[vpn provider]' \
  -e 'VPN_USERNAME=[vpn username]' \
  -e 'VPN_PASSWORD=[vpn password]' \
  -e 'VPN_COUNTRY=UK' \
  --net smartdns \
  rundqvist/openvpn-sniproxy
```

### Configuration
Please see OpenVPN container for VPN configuration.
https://hub.docker.com/r/rundqvist/openvpn

## Use
Just surf to one of the supported sites and watch without geo restrictions.

## Issues
Please report issues at https://github.com/rundqvist/docker-smartdns/issues