allists=$(ipset list | awk ' /Name/ {print $2}')
args=$*
lists=${args:-$alllists}
for l in $lists
do
  setlist=/etc/firehol/ipsets/$l.*set
  if [ -f $setlist ]; then
    entries=$(comm -13 <(ipset list $l |egrep "^[0-9]" |sort) <(egrep "^[0-9]" $setlist |sort) |sort -u)
    ecount=$(echo -n "$entries" |wc -l)
    newdot=$(( $ecount/25 + 1 ))
    progress=0
    numdots=0
    printf "%-26s" "$l ($ecount new)"
    for e in $entries
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
