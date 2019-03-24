#!/bin/bash
# for host in 192.168.200.2 192.168.200.167 192.168.200.197 192.168.200.14
HOSTS=${*-office cloud docker neth mattermost}
for host in $HOSTS
do
  printf "%-20s" "$host"
  sslinfo=$(echo | \
    openssl s_client -servername $host -connect $host:443 2>/dev/null | \
    openssl x509 -noout -dates -issuer 2>/dev/null)

  issuer=$(echo $sslinfo  |\
    sed 's/.*issuer.*O=\([^\/]*\).*/\1/')
  printf "%-20s" "$issuer"

  expires=$(echo $sslinfo |\
    sed 's/.*notAfter=\(.*\) issuer.*/\1/')

  expiress=$(date -d $(date -d "${expires}" '+%Y%m%d') '+%s')
  today=$(date -d $(date '+%Y%m%d') '+%s')
  diffdays=$(( ($expiress - $today) / (60*60*24) ))
  if (( diffdays < 30 ))
  then
    renew="===RENEW NOW==="
  else
    renew=""
  fi
  printf "$(date -d "${expires}" '+%Y%m%d') ($diffdays days)\t$renew\n"

done
