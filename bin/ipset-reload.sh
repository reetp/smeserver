#!/bin/bash
alllists=$(ipset list | awk ' /Name/ {print $2}')
args=$*
lists=${args:-$alllists}
for l in $lists
do
  setlist=/etc/firehol/ipsets/$l.*set
  if [ -f $setlist ]; then
    entries=$(egrep -c "^[0-9]" $setlist)
    newdot=$(( $entries/25 + 1 ))
    progress=0
    numdots=0
    printf "%-26s" "$l ($entries)"
    for e in $(egrep "^[0-9]" $setlist)
      do
       ipset add $l $e -exist
       (( progress=progress+1 ))
       if [ $progress -ge $newdot ]; then
         echo -en "."
         (( numdots=numdots+1 ))
         progress=0
       fi
    done
    while [ $numdots -lt 25 ]
    do
      echo -en "."
      (( numdots=numdots+1 )) 
    done
    echo done
  else
    printf "%-26s" "$l"
    echo "No ipset or netset file"
  fi
done
