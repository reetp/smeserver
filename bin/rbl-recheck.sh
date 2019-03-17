#!/bin/bash
VERBOSE=NO
MOVEM=NO
MOVETO=".RBL-Recheck"
USER=
DEBUG=FALSE
SUMMARY=FALSE
: ${RBLList:=$(config getprop qpsmtpd RBLList | tr ":" "\n")" "$(config getprop qpsmtpd A_Record_RBL | cut -d: -f1)}
: ${DAYS:=2}

while [[ $# > 0 ]]; do
	opt="$1" 
	case $opt in
		-v|--verbose)
			VERBOSE=YES
			;;
		-m|--movem)
			MOVEM=YES
			;;
		--dry-run)
			MOVEM=NO
			;;
		-t|--moveto)
			MOVETO="$2"
			shift
			;;
		-u|--user)	
			USER="$2"
			shift
			;;
		-d|--debug)
			DEBUG=TRUE
			SUMMARY=TRUE
			;;
		-s|--summary)
			SUMMARY=TRUE
			;;
		--days)
			DAYS="$2"
			shift
			;;
		-r|--rbllist)
			RBLList="$2"
			shift
			;;
		-h|-\?|--help|*)
			echo "$0 [-v|--verbose] [-s|--summary] [-m|--movem] [-t|--moveto FolderName]" 
			echo "          [-u|--user username] [-d|--debug] [-h|-?|--help] [--dry-run]"
			echo "          [--days DAYS] [-r|-rbllist \"list of rbl services\"]"
			echo ""
			echo "	-v, --verbose          Verbose output - display all rbl-recheck results (default=NO)"
			echo "	-s, --summary          Display a summary of the active arguments (defaults to off)"
			echo "	-m, --movem            Move Messages - move messages into $MOVETO (default is to NOT move messages)"
			echo "	-t, --moveto FOLDER    to FOLDER. Do not include slashes.  FOLDER will be created if it does not exist (default is .RBL-Recheck)"
			echo "	-u, --user USERNAME    Process only the user specified. (default is to process all users)"
			echo "	-d, --debug            Debug - display arguments & exit"
                        echo "	--days N               Scan messages with create dates in the last N days (default=2)"
			echo "	-r, --rbllist \"LIST\"  List of RBL services to use separated by spaces.  (defaults to qpsmtpd RBLList plus qpsmtpd A_Record_RBL)"
			echo ""
                        echo "	--dry-run              Show what would be done (sets \$MOVEM to NO) "
			echo "	          IMPORTANT:   --dry-run should be the last argument on the command line."
			echo ""
                        echo "	-h or -?               display this help"
			exit 1
			;;
	esac
	shift
done

if [[ $SUMMARY == TRUE ]]; then
	echo "RBLList:        $RBLList"
	echo "DAYS:           $DAYS"
	echo "FOLDER TO SCAN: /home/e-smith/files/users/$USER"
	echo "SUMMARY:        $SUMMARY"
	echo "VERBOSE:        $VERBOSE"
	echo "MOVEM:          $MOVEM"
	echo "MOVETO:         $MOVETO"
	echo "USER:           $USER"
	echo "DEBUG:          $DEBUG"
	echo ""
fi
if [[ $DEBUG == TRUE ]]; then
	exit 1
fi

: ${RBLList:=$(config getprop qpsmtpd RBLList | tr ":" " ")" "$(config getprop qpsmtpd A_Record_RBL | cut -d: -f1)}
: ${DAYS:=2}

find /home/e-smith/files/users/$USER -not -path */$MOVETO/* -daystart -name *$(config get SystemName):* -ctime -$DAYS -print0 | \
while read -d $'\0' MAILFILE; do 
        RECEIVED=$(pcregrep -M "^Received: .*(\n.*){1,2}by $(config get DomainName).*" "$MAILFILE" |tr "\n" " ")
        IP=$(echo $RECEIVED |perl -lne 'print $& if /(\d+\.){3}\d+/')
                
        if [[ ! "$IP" =~ "(^127\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)" ]] && [ ! -z "$IP" ]; then 
               if [[ $RECEIVED == *"smtp-auth"* ]]; then
                        ARESULT=AUTH
                        AMSG=$(echo $RECEIVED |perl -pe 's|.*smtp-auth\ username\ (\w*),.*|\1|')
                        AINFO="Authenticated user"
               else
                        IFS=.  read IP1 IP2 IP3 IP4 <<< "$IP"
                        AINFO=""
                        for DNSBL in $RBLList; do
                                ARESULT=$(dig +short +time=1 "$IP4.$IP3.$IP2.$IP1.$DNSBL" |head -1)
                                if [[ $ARESULT == 127* ]]; then
                                        if [ -z "$AINFO" ]; then
                                                AINFO="$DNSBL,"
                                                AMSG="$DNSBL"
                                        else
                                                AMSG="$DNSBL"
                                        fi
                                        break
                                else 
                                        if [ -z "$ARESULT" ]; then
                                                AINFO="$AINFO$DNSBL,"
                                        else
                                                AINFO="$AINFO,$DNSBL*,"
                                        fi
                                        AMSG="DECLINED"
                                        ARESULT="OK"
                                fi 
                        done
                fi
     else
    		if [ -z "$IP" ]; then
    			ARESULT="SENT"
    			AMSG="BLANK"
    			AINFO="No Received Header; this is a 'Sent Item'"
    			IP="??.??.??.??"
    		else
    			ARESULT="LOCAL"
    			AMSG="$IP"
    			AINFO="Message Received from Local IP"
    		fi
     fi
     if [[ $VERBOSE == YES ]]; then
	echo -e "$IP\t$ARESULT\t$AMSG\t$AINFO\t$MAILFILE"
     fi
     if [[ $ARESULT == 127* ]]; then
	if [[ $MOVEM == YES ]]; then
		CMD="mv"
	else
		CMD="echo mv"
	fi
	if [[ $MAILFILE == *$USER/Maildir/cur/* ]]; then
		if [ ! -d "${MAILFILE/Maildir?cur*/Maildir/$MOVETO/cur}" ]; then
			mkdir -p "${MAILFILE/Maildir?cur*/Maildir/$MOVETO/cur}"
                        mkdir -p "${MAILFILE/Maildir?cur*/Maildir/$MOVETO/new}"
                        mkdir -p "${MAILFILE/Maildir?cur*/Maildir/$MOVETO/tmp}"
			chown -R $(stat -c "%U:%G" "$MAILFILE") "${MAILFILE/Maildir?cur*/Maildir/$MOVETO}"
		fi
     		$CMD "$MAILFILE" "${MAILFILE/Maildir?cur/Maildir/$MOVETO/cur}"
     	fi
     fi
done


