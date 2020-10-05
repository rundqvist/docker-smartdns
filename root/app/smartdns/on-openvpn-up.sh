#!/bin/sh

country=$1
tun=$2 # tun
ip=$3 # default gw of tun
gateway=$(echo $ip | sed 's/\([0-9\.]*\)\.[0-9][0-9]*$/\1\.1/g') # gateway
port=$(var -k port $country)
http=$(var -k vpn.range http)
https=$(var -k vpn.range https)

log -d "Setup routing for $country vpn: tun: $tun, ip: $ip, gateway: $gateway, port: $port."

# -- Create new config --
log -v "Add routing table ($country): 20$port $tun"
echo "20$port $tun" >> /etc/iproute2/rt_tables

log -v "Add route ($country): default via $gateway dev $tun table $tun"
ip route add default via $gateway dev $tun table $tun

log -v "Add rule ($country): fwmark 0x$port table $tun"
ip rule add fwmark 0x$port table $tun

log -v "Add mangle ($country): iptables -A OUTPUT -t mangle -o eth0 -p tcp --dport $http$port -j MARK --set-mark 0x$port"
iptables -A OUTPUT -t mangle -o eth0 -p tcp --dport $http$port -j MARK --set-mark 0x$port

log -v "Add mangle ($country): iptables -A OUTPUT -t mangle -o eth0 -p tcp --dport $https$port -j MARK --set-mark 0x$port"
iptables -A OUTPUT -t mangle -o eth0 -p tcp --dport $https$port -j MARK --set-mark 0x$port

log -v "Add nat ($country): iptables -A POSTROUTING -t nat -o $tun -j MASQUERADE"
iptables -A POSTROUTING -t nat -o $tun -j MASQUERADE
# --
