#!/bin/sh

COUNTRY=$1
TUN=$2 # tun
IP=$3 # default gw of tun
MARK=$(expr ${TUN:3:4} + 1)
GW=$(echo $IP | sed 's/\([0-9\.]*\)\.[0-9][0-9]*$/\1\.1/g')
CP=$(cat /app/smartdns/smartdns.port.conf | grep "$COUNTRY")
DPORT=${CP:3:2}

sed -i "/20$MARK $TUN/d" /etc/iproute2/rt_tables

ip route del default via $GW dev $TUN table $TUN
ip rule del fwmark 0x$MARK table $TUN
iptables -D OUTPUT -t mangle -o eth0 -p tcp --dport 80$DPORT -j MARK --set-mark 0x$MARK
iptables -D OUTPUT -t mangle -o eth0 -p tcp --dport 81$DPORT -j MARK --set-mark 0x$MARK
iptables -D POSTROUTING -t nat -o $TUN -j MASQUERADE
