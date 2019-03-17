#!/bin/bash
MYSQL="/opt/rh/mysql55/root/usr/bin/mysql --socket=/var/lib/mysql/mysql55.sock"
DB=etherpad
DESTINATION=/home/e-smith/files/users/mmccarn/home/etherpad

# It's easier if you put the login details into ~/.my.cnf
# otherwise, specify USERNAME as "-u <username>" 
# and USERPASS as "-pPASSWORD" (or "-p" by itself to be prompted)
USERNAME=
USERPASS=

mkdir -p "$DESTINATION"
cd "$DESTINATION"

for pad in $($MYSQL $USERNAME $USERPASS $DB -e \
	'select distinct left(store.key,locate(":revs",store.key)) from store where store.key like "pad%"' | \
	grep -Eo '^pad:[^:]+'    | \
	sed -e 's/pad://'    | \
	sort    | uniq -c    | \
	sort -rn    | \
	awk '{if ($1!="2") {print $2 }}')
	do
		curl -s -o "$pad.html" https://etherpad.mmsionline.us/p/$pad/export/html
	done


