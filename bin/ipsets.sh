#!/bin/bash
DAYS=${DAYS:-1}
lists=$*
if [ -z "$lists" ]
  then
    lists=$(ipset list | awk ' /Name/ {print $2}')
fi
#echo lists: \"$lists\"
for l in $lists; 
  do 
    listcount=$(ipset list $l |egrep -c "^[0-9]")
    blockcount=$(cat $(find /var/log/iptables/ -type f -ctime -$DAYS) | grep -ch "\-$l" )
    uniquips=$(cat $(find /var/log/iptables/ -type f -ctime -$DAYS) | grep -h  "\-$l" |sed s/^.*SRC\=// |sed s/\ .*$// |sort -u |wc -l)
    echo -e "$listcount\t$blockcount\t$uniquips\t$l"
  done
