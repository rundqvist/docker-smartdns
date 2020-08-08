#!/bin/sh

PREFIX="smartdns"
EXIT=0
COUNTRIES="no dk uk"

cp -f /etc/sniproxy/sniproxy.template.conf /etc/sniproxy/sniproxy.partial.conf

echo "${COUNTRIES}" | fold -w 4 -s | while IFS= read -r i; do
    CURRENT_COUNTRY=$(echo $i | sed 's/ *$//g')
    CONTAINER_NAME=$PREFIX"-"$CURRENT_COUNTRY


PREVIP=$(cat /app/state/$CONTAINER_NAME)
RC=$?
if [ $RC -eq 1 ]; then
    echo "No PREVIP" >> /proc/1/fd/1
    PREVIP=""
fi

PING=$(ping -c 1 $CONTAINER_NAME)
RC=$?

if [ $RC -eq 1 ]; then
    echo "No CURRIP" >> /proc/1/fd/1
    CURRIP=""
    EXIT=1
else
    CURRIP=$(echo $PING | sed -ne '/.*(/{;s///;s/).*//;p;}')
fi

if [ "$PREVIP" != "$CURRIP" ]; then
    echo "IP changed: "$CURRIP >> /proc/1/fd/1
    echo $CURRIP >> /app/state/$CONTAINER_NAME
    echo "1" > /app/state/restart
fi

if [ "$CURRIP" = "" ]; then
    CURRIP="*"
    echo "IP: "$CURRIP >> /proc/1/fd/1
fi

sed -i 's/smartdns-'$CURRENT_COUNTRY'/'$CURRIP'/g' /etc/sniproxy/sniproxy.partial.conf


done

RESTART=$(cat /app/state/restart)

mv -f /etc/sniproxy/sniproxy.partial.conf /etc/sniproxy/sniproxy.conf

if [ $RESTART -eq 1 ]; then
    echo "RESTART" >> /proc/1/fd/1
    echo "0" > /app/state/restart
    killall -s SIGHUP sniproxy
fi

exit $EXIT