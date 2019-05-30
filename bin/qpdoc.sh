#!/bin/bash
# perldoc -T -ohtml helo |pandoc -f html -t mediawiki |sed '1 i\\n\n\n<!-- $0 $@ -->\n<span id="_top"></span>' |sed -e 's#</d.>##'
plugins=/usr/share/qpsmtpd/plugins

[ -f $plugins/$1 ] || die "$plugins/$1 does not exist"

# generate html from the plugin using perldoc
# pipe that to pandoc to convert it to mediawiki syntax
# add an anchor for "_top" so that the back-links work
# remove </dd> </dl> and </dt> since these appear on the page if included
# comments at the bottom showing the time and date and the command used  
perldoc -T -ohtml $plugins/$1 2>&1 |pandoc -f html -t mediawiki |sed '1 i\\n\n\n<span id="_top">[[Qpsmtpd#Plugins]]</span>' |sed -e 's#</d.>##'
echo \<\!-- Generated $(date) using
echo 'perldoc -T -ohtml $plugins/$1 \|pandoc -f html -t mediawiki \|sed '\''1 i\\n\n\n<span id="_top">[[Qpsmtpd#Plugins]]</span>'\'' \|sed -e '\''s#</d.>##'\'
echo --\>
echo -e "----\n[[Category:Qpsmtpd|$1]]"
