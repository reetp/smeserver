#!/bin/bash
MATCHDIR='/home/e-smith/Maildir/{new,cur}'
AGE="-mmin +60"
MATCH='^Subject.*ALRT.*temp2'

# find and delete all files
#  in $MATCHDIR (wildcards and brace expansion OK)
#  matching regex ${MATCH} 
#  matching age expression ${AGE}

# cd "${MAILDIR}"
# find new cur -mmin +$MMIN -type f -exec grep -l "${MATCH}" "{}" \; -delete
find $(eval echo $MATCHDIR) ${AGE} -type f -exec grep -l "${MATCH}" "{}" \; -delete
