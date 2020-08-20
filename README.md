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
* Compact
* Docker health check

## Supported services
* NRK (https://tv.nrk.no)
* DR (https://www.dr.dk/drtv/)
* TVPlayer (https://tvplayer.com/uk/)
* USTVGO, USTV247 (https://ustvgo.tv, https://ustv247.tv)

## Requirements
* An IPVanish VPN account [![Sign up](https://img.shields.io/badge/Sign_up-IPVanish_VPN-6fbc44)](https://www.ipvanish.com/?a_bid=48f95966&a_aid=5f3eb2f0be07f)
* A local DNS server that utilizes dnsmasq (for example Pi-hole, https://hub.docker.com/u/pihole/)
* Port 80 & 443 available

## Components
* OpenVPN (https://github.com/OpenVPN/openvpn)
* Sniproxy (https://github.com/dlundquist/sniproxy)

## Configuration
| Variable | Usage |
|----------|-------|
| SERVERIP | IP of the machine where SmartDNS and DNS server is running |

## Setup

### Create network
```
$ docker network create --subnet=172.20.0.0/16 smartdns
```

### Setup main container
Make sure docker is allowed to create a file in the /path/to/etc/dnsmasq.d/ folder.
Also possible to map this directory to a temp-folder and copy the 10-smartdns.conf-file to your /etc/dnsmasq.d/-folder.
```
$ sudo docker run \
  -d \
  --name=smartdns \
  -p 80:80 \
  -p 443:443 \
  -v /path/to/etc/dnsmasq.d:/etc/dnsmasq.d/ \
  --net smartdns \
  -e 'SERVERIP=[your server ip]' \
  rundqvist/smartdns
```

### Restart DNS Server
Restart your DNS server to include the 10-smartdns.conf-file in your config.

### Setup VPN's
Do not change the --name.

```
$ docker run \
  -d \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  --name=smartdns-no \
  --dns 84.200.69.80 \
  --dns 84.200.70.40 \
  -e 'USERNAME=[ipvanish username]' \
  -e 'PASSWORD=[ipvanish password]' \
  -e 'COUNTRY=NO' \
  --net smartdns \
  rundqvist/smartdns-vpn

$ docker run \
  -d \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  --name=smartdns-dk \
  --dns 84.200.69.80 \
  --dns 84.200.70.40 \
  -e 'USERNAME=[ipvanish username]' \
  -e 'PASSWORD=[ipvanish password]' \
  -e 'COUNTRY=DK' \
  --net smartdns \
  rundqvist/smartdns-vpn

$ docker run \
  -d \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  --name=smartdns-uk \
  --dns 84.200.69.80 \
  --dns 84.200.70.40 \
  -e 'USERNAME=[ipvanish username]' \
  -e 'PASSWORD=[ipvanish password]' \
  -e 'COUNTRY=UK' \
  --net smartdns \
  rundqvist/smartdns-vpn
```
### Set DNS ip in your router
Update the DNS ip in your router to your server ip.

## Use
Just surf to one of the supported sites and watch without geo restrictions.

## Issues
Please report issues at https://github.com/rundqvist/smartdns/issues