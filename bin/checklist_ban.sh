#!/bin/bash
#lancer le script en sudo 
echo -e "Jail            failed / banned" 

JAILS=$(fail2ban-client status | grep " Jail list:" | sed 's/`- Jail list://g' | sed 's/,//g')
for j in $JAILS
do
jail="$j                    "
failed=$(fail2ban-client status $j | grep " Currently failed:" | sed 's/[^0-9]*//')
banned=$(fail2ban-client status $j | grep " Currently banned:" | sed 's/[^0-9]*//')
echo -e "${jail:0:20} $failed / $banned" 
done
