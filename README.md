# Docker SmartDNS
A smart dns container based on Alpine Linux.  
https://hub.docker.com/repository/docker/rundqvist/smartdns

## Features
* Unblocks georestrictions
* Compact
* Docker health check

## Components
* OpenVPN
* Sniproxy

## Supported channels
* NRK (https://tv.nrk.no)
* DR (https://www.dr.dk/drtv/)
* TVPlayer (https://tvplayer.com/uk/)
* USTVGO, USTV247 (https://ustvgo.tv, https://ustv247.tv)

## Requirements
* An IPVanish VPN account (https://www.ipvanish.com)
* A local DNS server that utilizes dnsmasq (for example Pi-hole, https://hub.docker.com/u/pihole/)
* Port 80 & 443 available

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