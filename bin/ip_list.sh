#!/bin/sh
# Set CLI vars to something we can read
TYPE=$1
RESULT=${2:-Ban}
LOG=$(find /var/log/fail2ban/ -name "daemon*" -ctime -7)

# Set main grep string
SEARCH="Ban ((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])"

# Add the search term
SEARCH="\[$TYPE]\ $SEARCH"

# Now search the log
zgrep -oE "\[$TYPE\] $RESULT ((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])" $LOG
