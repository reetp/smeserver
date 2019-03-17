#!/bin/bash
# for host in 192.168.200.2 192.168.200.167 192.168.200.197 192.168.200.14
for host in office cloud docker neth mattermost
do
  printf "%-12s" "$host"
  expires=$(echo | \
    openssl s_client -servername $host -connect $host:443 2>/dev/null | \
    openssl x509 -noout -dates | \
    grep notAfter |\
    sed 's/notAfter=//')
  expiress=$(date -d $(date -d "${expires}" '+%Y%m%d') '+%s')
  today=$(date -d $(date '+%Y%m%d') '+%s')
  diffdays=$(( ($expiress - $today) / (60*60*24) ))

  echo $(date -d "${expires}" '+%Y%m%d') \($diffdays days from today\)

done
