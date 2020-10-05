#!/bin/sh

country=$1
tun=$2 # tun
ip=$3 # default gw of tun
gateway=$(echo $ip | sed 's/\([0-9\.]*\)\.[0-9][0-9]*$/\1\.1/g')
port=$(var -k port $country)
http=$(var -k vpn.range http)
https=$(var -k vpn.range https)

log -d "Remove routing for $country vpn: tun: $tun, ip: $ip, gateway: $gateway, port: $port."

# -- Clean up old config
log -v "Delete nat ($country): iptables -D POSTROUTING -t nat -o $tun -j MASQUERADE"
iptables -D POSTROUTING -t nat -o $tun -j MASQUERADE

log -v "Delete mangle ($country): iptables -D OUTPUT -t mangle -o eth0 -p tcp --dport $https$port -j MARK --set-mark 0x$port"
iptables -D OUTPUT -t mangle -o eth0 -p tcp --dport $https$port -j MARK --set-mark 0x$port

log -v "Delete mangle ($country): iptables -D OUTPUT -t mangle -o eth0 -p tcp --dport $http$port -j MARK --set-mark 0x$port"
iptables -D OUTPUT -t mangle -o eth0 -p tcp --dport $http$port -j MARK --set-mark 0x$port

log -v "Delete rule ($country): fwmark 0x$port table $tun"
ip rule del fwmark 0x$port table $tun

log -v "Delete route ($country): default via $gateway dev $tun table $tun"
ip route del default via $gateway dev $tun table $tun

log -v "Delete routing table ($country): 20$port $tun"
sed -i "/20$port $tun/d" /etc/iproute2/rt_tables
# --
