#!/bin/bash
ARGS=()
REPOS=()
for var in "$@"; do
        if [[ $var != \@* ]]; then
                ARGS+=("$var")
        else
                REPOS+=("${var:1}")
        fi
done

YUMCMD=$(echo "${ARGS[@]}")

if [ -z "$YUMCMD" ]; then
        YUMCMD="check-update -q"
fi

if [ -z "$REPOS" ]; then
        REPOS=$(/sbin/e-smith/audittools/newrpms |grep \@ |awk ' {print $3}' |sort -u |sed s/@//)
else
        SEARCHREPOS=$(echo ${REPOS[@]}|sed s/^/@/ |sed s/\ /\|@/g)
        REPOS=$(/sbin/e-smith/audittools/newrpms |grep -E "$SEARCHREPOS" |awk ' {print $3}' |sort -u |sed s/@//)
fi

for repo in $REPOS; do

        # generate the list of rpms installed from the repo
        unset rpms
        for rpm in $(/sbin/e-smith/audittools/newrpms |awk -v repo_awk=@$repo 'repo_awk==$3 {print $1}'); do
                if [ ! -z "$rpms" ]; then
                        rpms="$rpms,$rpm"
                else
                        rpms="$rpm"
                fi
        done
        if [[ ${YUMCMD} != *"-q"* ]]; then
                echo -e "\n\n===";
                echo -e yum $YUMCMD --enablerepo=$repo --setopt=\"$repo.includepkgs=$rpms\"
                echo "===";
        fi
        # updating
        if [[ $repo != "/"* ]]; then
                if [ ! -z "$rpms" ]; then
                        yum $YUMCMD --enablerepo=$repo --setopt=$repo.includepkgs=$rpms
                else
                        if [[ ${YUMCMD} != *"-q"* ]]; then
                                echo -e "$repo has no installed packages"
                        fi
                fi
        else
                if [ ! -z "$localinstall" ]; then
                        localinstall="$localinstall\n\t$rpm"
                else
                        localinstall="\t$rpm"
                fi
        fi

done

if [ ! -z "$localinstall" ]; then
        echo -e "\n\n===";
        echo -e 'Locally installed package(s) exist.'
        echo -e "You need to manage updates for these packages manually:\n"
        echo -e "$localinstall"
        echo -e "\n(You would also get this message if you have created a"
        echo -e " yum repository whose name begins with a forward slash)"
        echo "===";
fi

if [[ $(/sbin/e-smith/config get UnsavedChanges) == "yes" ]]; then
        echo -e "\nA contrib has set the UnsavedChanges flag to 'yes'"
        echo -e "You should  execute the following commands to complete the update:"
        echo -e "\n signal-event post-upgrade; signal-event reboot\n\n"
fi

exit 0
