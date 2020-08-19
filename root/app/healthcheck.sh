#!/bin/sh

PREFIX="smartdns"
COUNTRIES="no dk uk"

echo "0" > /app/state/exit

cp -f /etc/sniproxy/sniproxy.template.conf /etc/sniproxy/sniproxy.partial.conf

echo "${COUNTRIES}" | fold -w 4 -s | while IFS= read -r i; do
    CURRENT_COUNTRY=$(echo $i | sed 's/ *$//g')
    CONTAINER_NAME=$PREFIX"-"$CURRENT_COUNTRY

    PREVIP=$(cat /app/state/$CONTAINER_NAME)
    RC=$?
    if [ $RC -eq 1 ]; then
        echo "[INF] Container "$CONTAINER_NAME" has no known IP. Try to resolve." >> /proc/1/fd/1
        PREVIP=""
    fi

    PING=$(ping -c 1 $CONTAINER_NAME)
    RC=$?

    if [ $RC -eq 1 ]; then
        CURRIP=""
        echo "1" > /app/state/exit
        echo "[ERR] IP for container "$CONTAINER_NAME" could not be resolved. Channels will not work."
    else
        CURRIP=$(echo $PING | sed -ne '/.*(/{;s///;s/).*//;p;}')
    fi

    if [ "$PREVIP" != "$CURRIP" ]; then

        if [ "$CURRIP" = "" ]; then
            echo "[ERR] IP for container "$CONTAINER_NAME" could not be resolved. Channels will not work." >> /proc/1/fd/1
        else
            echo "[INF] IP for container "$CONTAINER_NAME" has changed. New IP: "$CURRIP"." >> /proc/1/fd/1
        fi

        echo $CURRIP > /app/state/$CONTAINER_NAME
        echo "1" > /app/state/restart      
        
    fi

    if [ "$CURRIP" = "" ]; then
        CURRIP="*"
    fi

    sed -i 's/smartdns-'$CURRENT_COUNTRY'/'$CURRIP'/g' /etc/sniproxy/sniproxy.partial.conf

done

RESTART=$(cat /app/state/restart)

mv -f /etc/sniproxy/sniproxy.partial.conf /etc/sniproxy/sniproxy.conf

if [ $RESTART -eq 1 ]; then
    echo "[INF] Sniproxy restarting to apply changes..." >> /proc/1/fd/1
    echo "0" > /app/state/restart
    killall -s SIGHUP sniproxy
fi

EXIT=$(cat /app/state/exit)
exit $EXIT