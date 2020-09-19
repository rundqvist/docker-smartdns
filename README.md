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
* Self healing (restarts vpn if no connection)
* Healthcheck

## Supported services
* DR - [dr.dk](https://www.dr.dk/drtv/)
* ITV - [itv.com](https://www.itv.com) (account needed, live tv only)
* NRK - [nrk.no](https://tv.nrk.no)
* SVT Play - [svtplay.se](https://svtplay.se)
* TV Player - [tvplayer.com](https://tvplayer.com/) (account needed)
* USTVGO - [ustvgo.tv](https://ustvgo.tv)
* USTV247 - [ustv247.tv](https://ustv247.tv)
* YLE - [yle.fi](https://areena.yle.fi/tv) (live tv only)

## Requirements
* Port 80 & 443 available on host
* A supported VPN account (currently [ipvanish](https://www.ipvanish.com/?a_bid=48f95966&a_aid=5f3eb2f0be07f) or [wevpn](https://www.wevpn.com/aff/rundqvist))

[![Sign up](https://img.shields.io/badge/sign_up-IPVanish_VPN-6fbc44)](https://www.ipvanish.com/?a_bid=48f95966&a_aid=5f3eb2f0be07f)
[![Sign up](https://img.shields.io/badge/sign_up-WeVPN-e33866)](https://www.wevpn.com/aff/rundqvist)

## Components
Built on [rundqvist/openvpn-sniproxy](https://hub.docker.com/r/rundqvist/openvpn-sniproxy) container.
* [Alpine Linux](https://www.alpinelinux.org)
* [Supervisor](https://github.com/Supervisor/supervisor)
* [OpenVPN](https://github.com/OpenVPN/openvpn)
* [SNI Proxy](https://github.com/dlundquist/sniproxy)
* [Dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html)

## Run

### Example with internal DNS

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
  -e 'HOST_IP=[your server ip]' \
  -e 'VPN_PROVIDER=[your vpn provider]' \
  -e 'VPN_USERNAME=[your vpn username]' \
  -e 'VPN_PASSWORD=[your vpn password]' \
  -e 'SMARTDNS_SERVICES=nrk.no dr.dk tvplayer.com' \
  -e 'DNS_ENABLED=true' \
  -v /path/to/cache/folder:/cache/ \
  rundqvist/smartdns
```

### Example with external DNS

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
  -e 'HOST_IP=[your server ip]' \
  -e 'VPN_PROVIDER=[your vpn provider]' \
  -e 'VPN_USERNAME=[your vpn username]' \
  -e 'VPN_PASSWORD=[your vpn password]' \
  -e 'SMARTDNS_SERVICES=nrk.no dr.dk tvplayer.com' \
  -e 'DNS_ENABLED=false' \
  -v /path/to/etc/dnsmasq.d:/etc/dnsmasq.d/ \
  -v /path/to/cache/folder:/cache/ \
  rundqvist/smartdns
```

Then restart your DNS server to include the 10-smartdns.conf-file in your config.

### Configuration
See image ([rundqvist/openvpn](https://hub.docker.com/r/rundqvist/openvpn)) for detailed vpn configuration.

#### Variables
| Variable | Usage |
|----------|-------|
| _HOST_IP_ | IP of the machine where container is running. |
| _SMARTDNS_SERVICES_ | Services to unblock, separated with one space (see list of supported services above). |
| DNS_ENABLED | Enables DNS server in container. <br />`true` or `false` (default). |
| _VPN_PROVIDER_ | Your VPN provider ("[ipvanish](https://www.ipvanish.com/?a_bid=48f95966&a_aid=5f3eb2f0be07f)" or "[wevpn](https://www.wevpn.com/aff/rundqvist)"). |
| _VPN_USERNAME_ | Your VPN username. |
| _VPN_PASSWORD_ | Your VPN password. |
| VPN_INCLUDED_REMOTES | Host names separated by one space. VPN will _only_ connect to entered remotes. |
| VPN_EXCLUDED_REMOTES | Host names separated by one space. VPN will _not_ connect to entered remotes. |
| VPN_RANDOM_REMOTE | Connects to random remote. <br />`true` or `false` (default). |

Variables in _cursive_ is mandatory.

**IMPORTANT!** Container will create one VPN connection for each country needed. Be careful not to violate the terms of your VPN account.

#### Volumes

| Folder | Usage |
|--------|-------|
| /cache/ | Used for caching original configuration files from vpn provider. |
| /etc/dnsmasq.d/ | Output of dnsmasq configuration file (usually `/etc/dnsmasq.d/`). |

## Setup

### Internal DNS
Set `DNS_ENABLED=true` and configure your client (or router) to use `HOST_IP` as DNS.

### External DNS

If you are using an external DNS server that utilizes dnsmasq (for example Pi-hole, https://hub.docker.com/u/pihole/), you can let the container copy needed settings to the /etc/dnsmasq.d/-folder.

* Make sure docker is allowed to create a file in the `/path/to/etc/dnsmasq.d/` folder (if not, map this directory to a temp-folder).
* Run `docker run`command to start container.
* If `/etc/dnsmasq.d/` is mapped to a temp-folder, now copy the autogenerated `10-smartdns.conf`-file to your dnsmasq.d-folder manually.
* Restart DNS

## Use
Just surf to one of the supported sites and watch without geo restrictions.

## Issues
Please report issues at https://github.com/rundqvist/docker-smartdns/issues
