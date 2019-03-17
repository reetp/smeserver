#!/bin/bash
#
# add only new IPs to hphosts_fsa and hphosts_wrz
#
# intermittently update sources from 
# https://github.com/firehol/blocklist-ipsets/raw/master/hphosts_fsa.ipset
# https://github.com/firehol/blocklist-ipsets/raw/master/hphosts_wrz.ipset
#
# wget -q -O /etc/firehol/ipsets/hphosts_fsa.ipset https://github.com/firehol/blocklist-ipsets/raw/master/hphosts_fsa.ipset
# wget -q -O /etc/firehol/ipsets/hphosts_wrz.ipset https://github.com/firehol/blocklist-ipsets/raw/master/hphosts_wrz.ipset
#
# ipset-reload.sh hphosts_fsa hphosts_wrz

cd /etc/firehol/ipsets
#
# FSA - latest 500 - 1000
echo -en "hphosts_fsa\t$(grep -v "^#" /etc/firehol/ipsets/hphosts_fsa.ipset |wc -l)...\t"
curl -s "https://hosts-file.net/?s=Browse&f=FSA&d=&page=[1-9]&o=DESC" |sed s/\?s\=/\\n\/g |egrep "^[0-1]" |sed s/\".*$// >> hphosts_fsa.ipset
touch -t 219912312359 hphosts_fsa.source
TMP=$(mktemp)
grep "^#" /etc/firehol/ipsets/hphosts_fsa.ipset > $TMP
egrep "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" /etc/firehol/ipsets/hphosts_fsa.ipset |sort -u >> $TMP
mv -f $TMP /etc/firehol/ipsets/hphosts_fsa.ipset
unset TMP
echo $(grep -v "^#" /etc/firehol/ipsets/hphosts_fsa.ipset |wc -l)

# WRZ - latest 500 - 1000
echo -en "hphosts_wrz\t$(grep -v "^#" /etc/firehol/ipsets/hphosts_wrz.ipset |wc -l)...\t"
curl -s "https://hosts-file.net/?s=Browse&f=WRZ&d=&page=[1-9]&o=DESC" |sed s/\?s\=/\\n\/g |egrep "^[0-1]" |sed s/\".*$// >> hphosts_wrz.ipset
touch -t 219912312359 hphosts_wrz.source
TMP=$(mktemp)
grep "^#" /etc/firehol/ipsets/hphosts_wrz.ipset > $TMP
egrep "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" /etc/firehol/ipsets/hphosts_wrz.ipset |sort -u >> $TMP
mv -f $TMP /etc/firehol/ipsets/hphosts_wrz.ipset
echo $(grep -v "^#" /etc/firehol/ipsets/hphosts_wrz.ipset |wc -l)

