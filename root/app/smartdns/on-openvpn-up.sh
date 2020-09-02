#!/bin/sh

COUNTRY=$1
TUN=$2 # tun
IP=$3 # default gw of tun
GW=$(echo $IP | sed 's/\([0-9\.]*\)\.[0-9][0-9]*$/\1\.1/g') # gateway
DPORT=$(dict port $COUNTRY)

# -- Clean up old config
ip route del default via $GW dev $TUN table $TUN
ip rule del fwmark 0x$DPORT table $TUN
iptables -D OUTPUT -t mangle -o eth0 -p tcp --dport 80$DPORT -j MARK --set-mark 0x$DPORT
iptables -D OUTPUT -t mangle -o eth0 -p tcp --dport 81$DPORT -j MARK --set-mark 0x$DPORT
iptables -D POSTROUTING -t nat -o $TUN -j MASQUERADE
sed -i "/20$DPORT $TUN/d" /etc/iproute2/rt_tables
# --

# -- Create new config --
echo "20$DPORT $TUN" >> /etc/iproute2/rt_tables
ip route add default via $GW dev $TUN table $TUN
ip rule add fwmark 0x$DPORT table $TUN
iptables -A OUTPUT -t mangle -o eth0 -p tcp --dport 80$DPORT -j MARK --set-mark 0x$DPORT
iptables -A OUTPUT -t mangle -o eth0 -p tcp --dport 81$DPORT -j MARK --set-mark 0x$DPORT
iptables -A POSTROUTING -t nat -o $TUN -j MASQUERADE
# --
