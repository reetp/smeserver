#!/bin/bash
echo -e \
"IP             \t"\
"BanTime             \t"\
"UnbanTime           \t"\
"Jail"

for ban in $(db fail2ban show |awk -F\= ' $2=="ban" {print $1}'); 
  do
    IP=$(db fail2ban getprop $ban Host)
    Bantime=$(date +"%F %T" -d @$(db fail2ban getprop $ban BanTimestamp))
    UnBanTime=$(date +"%F %T" -d @$(db fail2ban getprop $ban UnbanTimestamp))
    LastJail=$(zgrep -H "Ban $IP" $(find /var/log/fail2ban -type f -ctime -7) |tail -1 |awk '{print $6}') 

    printf "%-15s" "$IP"
    echo -e "\t$Bantime\t$UnBanTime\t$LastJail"
  done

