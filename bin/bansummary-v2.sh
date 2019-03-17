#!/bin/bash
HEADER=FALSE
SUMMARY=FALSE
DETAIL=TRUE
FORCEDETAIL=FALSE

while [[ $# > 0 ]]; do
  opt="$1"
  case $opt in
    -d|--detail)
      FORCEDETAIL=TRUE
      ;;
    -s|--summary)
      SUMMARY=TRUE
      DETAIL=FALSE
      ;;
    -h|--header)
      HEADER=TRUE
      ;;
    -\?|--help|*)
      echo "$0 [-s|--summary] [-h|--header]"
      echo ""
      echo "  -d, --detail     Include detailed output (default=ON unless '-s' is specified)"
      echo "  -s, --summary    Output counts of IPs band by each jail"
      echo "  -h, --header     Include a header row"
      exit 1
      ;;
    esac
    shift
done
if [[ $FORCEDETAIL == TRUE ]]; then
  DETAIL=TRUE
fi

output=$(mktemp)
trap "{ rm -f $output; }" EXIT

for e in $(db fail2ban print)
  do 
    IP=$(echo $e |cut -d\| -f 5)
    Bantime=$(date +"%F %T" -d@$(echo $e |sed -e 's/^.*BanTimestamp/BanTimestamp/' |cut -d\| -f 2))
    UnBanTime=$(date +"%F %T" -d@$(echo $e |sed -e 's/^.*UnbanTimestamp/UnbanTimestamp/' |cut -d\| -f 2))
    LastJail=$(zgrep -H "Ban $IP" $(find /var/log/fail2ban -type f -ctime -7) |tail -1 |awk '{print $6}')

    printf "%-15s" "$IP" >> $output
    echo -e "\t$Bantime\t$UnBanTime\t$LastJail" >> $output
  done

if [[ $DETAIL == TRUE ]]; then
  if [[ $HEADER == TRUE ]]; then
    echo -en "IP             \t"
    echo -en "BanTime             \t"
    echo -en "UnbanTime           \t"
    echo -en "Jail\n"
  fi
  cat $output
  echo -e ""
fi

if [[ $SUMMARY == TRUE ]]; then
  if [[ $HEADER == TRUE ]]; then
    echo -en "[jail]    \t"
    echo -en "bancount\n"
  fi
  awk -F"\t" '{ a[$4]++} END { for (n in a) print n "\t" a[n] }' $output
fi

exit

