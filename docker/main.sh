#!/bin/sh
# Copyright 2022, 2023 RLT
# Author: RLT (except10n.rlt@gmail.com)
# Revision: 0.1
# Created:     2022-02-01
# Last udpate: 2023-10-30

set -o nounset                              # Treat unset variables as an error
set -e                                      # Exit when there is an error

# ---------------------------- HELP MESSAGE ----------------------------

HELP="Usage: ${0##*/}: [-h] \e[4mtarget\e[m \e[4m...\e[m
where
    -h              show this help
"
# ---------------------- CONSTANTS AND VARIABLES -----------------------


# -------------------- OPTIONS & ARGUMENTS PARSERS ---------------------

while getopts :h name
do
    case $name in
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

# ---------------------------- MAIN PROGRAM ----------------------------

# The `PATH` variable in `cron` daemon is limited to `/bin:/usr/bin`, while
# those administrative commands like `service` are under `/usr/sbin`.
if ! /usr/sbin/service cron status > /dev/null ; then
    printf "cron not running, now start it.\n"
    /usr/sbin/service cron start
fi
# or just simply `cron`
# cron

# Move to positional parameters
shift $(($OPTIND-1))

for target
do
    opts=""
    cd $target
    for dir in */;
    do
        if [ -d "$dir" ]; then
            dir=${dir%/}
            opts="$opts $target/$dir"
        fi
    done
    cd - > /dev/null
    ${APP}/tmux.sh $opts
    opts=""
done

bash

# vim: tw=78:ts=8:sts=4:sw=4:et:ft=sh:norl:
