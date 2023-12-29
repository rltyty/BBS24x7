#!/bin/sh
# Copyright 2022, 2023 RLT
# Author: RLT (except10n.rlt@gmail.com)
# Revision: 0.1
# Created:     2022-02-01
# Last udpate: 2023-12-04

set -e                                      # Exit when there is an error

# ---------------------------- HELP MESSAGE ----------------------------

HELP="Usage: ${0##*/}: [-h] [-s sname] -e dialog -u userinfo
       ${0##*/}: [-h] \e[4msession\e[m \e[4m...\e[m
where
    -s sname        tmux session name
    -e dialog       an Expect script for interaction automation
    -u userinfo     a file contains login secrets and other profile stuff
    -h              show this help

Multiple Tmux session creation is supported with the second synopsis form.
Each \e[4msession\e[m is a directory contains a dialog.tcl and \
a userinfo file.
The last component of \e[4msession\e[m will be used as the sname in \
the first form.

When a session named <sname> already exists, the command will give up
session creation and 1) quit right away if the number of user login window
(window count) equals to the user count in the userinfo file, or 2) create
login windows for those missing when window count is less than user count
due to login disconnected. However, if the last modified time of userinfo
file is newer than the time at which the session was created, the session
is deemed to be outdated and should be killed and recreate.
"

# ---------------------- CONSTANTS AND VARIABLES -----------------------

DEBUG=${DEBUG:-0}

# userinfo file parser:
# a. ignore empty lines
# b. ingore comment lines or inline comments at the end of lines
# c. split the space separated fields into user login arguments
AWK_USERINFO_PARSER='BEGIN {FSCPY=FS; FS="#"}
NF && !($1 ~ /^[[:space:]]*$/) {
    n=split($1, a, FSCPY);
    for (i=1; i<=n; i++) printf("%s ", a[i]);
    printf("\n");
}
END {FS=FSCPY;}'
# number of user entries in userinfo file
AWK_USER_NUM='BEGIN {FSCPY=FS; FS="#"}
NF && !($1 ~ /^[[:space:]]*$/) {
    count++
}
END {FS=FSCPY; printf("%d", count);}'
sname=${TMUX_SESS_NAME:-bbs}
dialog=
userinfo=
mypath=$(realpath $0)
mydir=${mypath%/*}

# -------------------- OPTIONS & ARGUMENTS PARSERS ---------------------

while getopts :s:e:u:h name
do
    case $name in
        s)
            sname="$OPTARG"
            ;;
        e)
            dialog="$OPTARG"
            ;;
        u)
            userinfo="$OPTARG"
            ;;
        h)
            printf "$HELP"
            exit 0
            ;;
        :)
            printf "Missing argument for option [%s].\n" "$OPTARG"
            printf "$HELP"
            exit 2
            ;;
        ?)
            printf "Unknown option [%s].\n" "$OPTARG"
            printf "$HELP"
            exit 1
            ;;
    esac
done

# Move to positional parameters
shift $(($OPTIND-1))

# ---------------------------- MAIN PROGRAM ----------------------------
file_exists_or_exit() # $1: file path, $2: msg
{
    [ -n "$1" ] && [ -f $1 ] || {
        printf "$2:[$1] does not exist.\n"
        exit 127
    }
}

log_msg()
{
    if [ $DEBUG -eq 1 ]; then
        printf "$1\n"
    fi
}


is_userinfo_updated() # $1: sname $2: userinfo; return: lmt > sess_t
{
    lmt=$(date -r "$2" +%s)
    sess_t=$(tmux showenv -t "$1" SESS_CRE_TIME | awk -F'=' '{print $2}')
    if [ $DEBUG -eq 1 ]; then
        log_msg "userinfo last modified time: $lmt, SESS_CRE_TIME: $sess_t"
    fi
    [ $lmt -gt $sess_t ]
}

check_win_count() # $1: sname $2: userinfo; return: wincount == usercount
{
    u_count=$(awk "${AWK_USER_NUM}" "$2")
    log_msg "${u_count}"
    w_count=$(tmux list-windows -t "$1" -F \
        "#{pane_pid}:#{pane_start_command}" | grep ".tcl" | wc -l)
    w_count=$(printf $w_count | sed -e 's/^ *//' -e 's/ *$//')
    log_msg "w_count:${w_count}, u_count:${u_count}"
    [ $w_count -eq ${u_count} ]
}

create_session() # $1: sname, $2: dialog, $3: userinfo
{
    if [ $# -lt 3 ]; then
        printf "create_session: too few arguments.\n"
        exit 127
    fi
    sname="$1"
    dialog="$2"
    userinfo="$3"
    file_exists_or_exit "${dialog}" "dialog script"
    file_exists_or_exit "${userinfo}" "userinfo"

    refresh=true
    # when the $sname session already exists
    if tmux has-session -t "${sname}" > /dev/null 2>&1; then
        if ! is_userinfo_updated "${sname}" "${userinfo}"; then
            # retrun without action if wincount == usercount
            if check_win_count "${sname}" "${userinfo}"; then
                log_msg "Status OK. No change."
                return 0;
            # don't refresh the session if part of user windows get closed
            else
                refresh=false
            fi
        # kill the session if userinfo is newer than its creation time
        else
            tmux kill-session -t "${sname}"
            log_msg "Kill session:[$sname] for userinfo has been updated."

            # if the last modified time of userinfo is accidently ahead of
            # the current time, align it to the current time.
            lmt=$(date -r "${userinfo}" "+%s")
            if [ $lmt -gt $(date "+%s") ]; then
                touch "${userinfo}"
            fi
        fi
    fi

    # new-session(alias: new)
    if $refresh; then
        tmux new -d -s "${sname}" -n 'main' -c "~/tmp" -y 30 -x 100
        tmux setenv -t "${sname}" SESS_CRE_TIME $(date +%s)
        log_msg "Session [${sname}] created."
    fi

    awk "${AWK_USERINFO_PARSER}" "${userinfo}" | {
        i=1
        while read -r user pass loginstr board
        do
            opts=""
            if [ "x*" != "x$user" ]; then opts="$opts -u $user"; \
                else unset user; fi # unset user to use loginstr as win_name
            if [ "x*" != "x$pass" ]; then opts="$opts -p $pass"; fi
            if [ "x*" != "x$loginstr" ]; then opts="$opts -l $loginstr"; fi
            if [ "x*" != "x$board" ]; then opts="$opts -b $board"; fi

            log_msg "opts: [$opts]."
            log_msg "${user:=$loginstr} $mydir $dialog"
            # new-window(alias:neww)
            ## no action will be done if a same window already exists
            tmux neww -dS -n "${user:=$loginstr}" -t "${sname}" \
                "$mydir"/expscripts/main.tcl -e "$dialog" $opts \
                > /dev/null 2>&1
        done
    }
}

# create a session
[ -z $sname ] || [ -z $dialog ] || [ -z $userinfo ] \
    || create_session "$sname" "$dialog" "$userinfo"

for session
do
    [ -d "$session" ] || continue
    # a. strip the last slash; b. use the last component as session name
    session=${session%/}
    create_session "${session##*/}" "$session/dialog.tcl" "$session/userinfo"
done

# To retrieve tmux server pid
# tmux_pid=$(tmux display-message -p "#{pid}")

# vim: tw=78:ts=8:sts=4:sw=4:ft=sh:norl:
