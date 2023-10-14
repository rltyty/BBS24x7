#!/bin/sh

DEBUG=0

if [ $# -ne 1 ]; then
    printf "Usage: tmux-smth.sh <user_db>\n"
    exit 1
fi
read -r user_count < $1
if [ $DEBUG -eq 1 ]; then
    printf "$user_count\n"
fi
if tmux has-session -t smth > /dev/null 2>&1 ; then
    job_count=$(tmux list-windows -t smth -F \
        "#{pane_pid}:#{pane_start_command}" | grep ".tcl" | wc -l)
    if [ $DEBUG -eq 1 ]; then
        echo "job_count:$job_count"
        echo "user_count:$user_count"
    fi
    if [ $job_count -eq $user_count ]; then
        # all smth user tmux windows are opened, all ssh connections are
        # assumed to be established.
        # TODO refine this logic, make sure all user accounts online
        if [ $DEBUG -eq 1 ]; then
            printf "Status OK. No change.\n"
        fi
        exit 1
    else
        # some user windows are missing, clean the broken 'smth' session.
        if [ $DEBUG -eq 1 ]; then
            printf "Broken 'smth' session, destroy and recreate..\n"
        fi
        tmux kill-session -t smth
    fi
fi

if [ $DEBUG -eq 1 ]; then
    printf "Create 'smth' session.\n"
fi

# new-session(alias: new)
tmux new -d -s 'smth' -n 'main' -c "~/tmp"
{
    read -r tmp;
    i=1
    while read -r login
    do
        read -r pass
        # new-window(alias:neww)
        tmux neww -d -c "~/tmp" -n "$login" -t "smth:$i" \
            "$RHUB"/web/smth/smth.tcl "$login" "$pass"
            # sleep 60
        i=$((i+1))
    done
}< $1

# To retrieve tmux server pid
# tmux_pid=$(tmux display-message -p "#{pid}")

# vim: tw=78:ts=8:sts=4:sw=4:ft=sh:norl:
