#!/bin/bash
for SERVI in $(fail2ban-client status|grep 'Jail list'|cut -d':' -f2|sed 's/, / /g'| sed -e 's/^[ \t]*//')
do
fail2ban-client status $SERVI |grep -E 'IP list|Status for the jail'
done
