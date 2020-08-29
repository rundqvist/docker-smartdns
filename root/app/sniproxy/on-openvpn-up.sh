#!/bin/sh

COUNTRY=$1
TUN=$2 # tun
IP=$3 # default gw of tun
MARK=$(expr ${TUN:3:4} + 1)
GW=$(echo $IP | sed 's/\([0-9\.]*\)\.[0-9][0-9]*$/\1\.1/g')

case $COUNTRY in
    "NO") DPORT=1;;
    "DK") DPORT=2;;
    "GB") DPORT=3;;
esac

echo "20$MARK $TUN" >> /etc/iproute2/rt_tables
sysctl -w net.ipv4.conf.all.rp_filter=2
ip route add default via $GW dev $TUN table $TUN
ip rule add fwmark 0x$MARK table $TUN
iptables -A OUTPUT -t mangle -o eth0 -p tcp --dport 800$DPORT -j MARK --set-mark 0x$MARK
iptables -A OUTPUT -t nat -o eth0 -p tcp --dport 800$DPORT -j DNAT --to-destination :80
iptables -A OUTPUT -t mangle -o eth0 -p tcp --dport 810$DPORT -j MARK --set-mark 0x$MARK
iptables -A OUTPUT -t nat -o eth0 -p tcp --dport 810$DPORT -j DNAT --to-destination :443
iptables -A POSTROUTING -t nat -o $TUN -j MASQUERADE
