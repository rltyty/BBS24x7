#!/bin/sh

DEBUG=${DEBUG:-0}
MY_PATH=$(realpath $0)
MY_DIR=${MY_PATH%/*}

log_msg()
{
    if [ $DEBUG -eq 1 ]; then
	printf "$1\n"
    fi
}

if [ $# -ne 1 ]; then
    printf "Usage: tmux-smth.sh <user_db>\n"
    exit 1
fi
read -r user_count < $1
log_msg "$user_count"
if tmux has-session -t smth > /dev/null 2>&1 ; then
    job_count=$(tmux list-windows -t smth -F \
        "#{pane_pid}:#{pane_start_command}" | grep ".tcl" | wc -l)
        log_msg "job_count:$job_count"
        log_msg "user_count:$user_count"
    if [ $job_count -eq $user_count ]; then
        # all smth user tmux windows are opened, all ssh connections are
        # assumed to be established.
        # TODO refine this logic, make sure all user accounts online
        log_msg "Status OK. No change."
        exit 1
    else
        # some user windows are missing, clean the broken 'smth' session.
        log_msg "Broken 'smth' session, destroy and recreate.."
        tmux kill-session -t smth
    fi
fi

    log_msg "Create 'smth' session."

# new-session(alias: new)
tmux new -d -s 'smth' -n 'main' -c "~/tmp" -y 40 -x 100
{
    read -r tmp;
    i=1
    while read -r login
    do
        read -r pass
        log_msg "login:$login"
        # new-window(alias:neww)
        tmux neww -d -c "~/tmp" -n "$login" -t "smth:$i" \
            ${MY_DIR}/smth.tcl "$login" "$pass"
            # sleep 60
        i=$((i+1))
    done
}< $1

# To retrieve tmux server pid
# tmux_pid=$(tmux display-message -p "#{pid}")

# vim: tw=78:ts=8:sts=4:sw=4:ft=sh:norl:
