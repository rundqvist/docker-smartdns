#!/bin/sh

for var in "SMARTDNS_SERVICES" "HOST_IP"
do 
    if [ -z "$(var $var)" ]
    then
        log -e "Environment variable '$var' is mandatory. "
        var abort true
    else
        log -d "Mandatory variable '$var' is ok."
    fi
done

if [ "$(var abort)" = "true" ]
then
    exit 1;
fi

exit 0;
