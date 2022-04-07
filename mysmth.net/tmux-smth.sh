#!/bin/sh

DEBUG=0

if tmux has-session -t smth ; then
    job_count=$(tmux list-windows -t smth -F \
	"#{pane_pid}:#{pane_start_command}" | grep ".login" | wc -l)
    user_count=$(find $RHUB/web/smth -name "*.login" | wc -l)
    if [ $DEBUG -eq 1 ]; then
	echo "job_count:$job_count"
	echo "user_count:$user_count"
    fi
    if [ $job_count -eq $user_count ]; then
	# all smth user tmux windows are opened, all ssh connections are
	# assumed to be established.
	# TODO refine this logic, make sure all user accounts online
	exit 1
    else
	# some user windows are missing, clean the broken 'smth' session.
	tmux kill-session -t smth
    fi
fi

# tmux new -d -x 100 -y 48 -s 'smth' -n 'main' -c "~/tmp" ';' \
tmux new -d -s 'smth' -n 'main' -c "~/tmp" ';' \
    neww -d -c "~/tmp"  -n 'codeprobe' \
 	"$RHUB/web/smth/smth.tcl $RHUB/web/smth/p.login" ';' \
    neww -d -c "~/tmp"  -n 'codescv' \
	"$RHUB/web/smth/smth.tcl $RHUB/web/smth/s.login" ';' \
    neww -d -c "~/tmp"  -n 'codedrone' \
	"$RHUB/web/smth/smth.tcl $RHUB/web/smth/d.login" ';' \
    neww -d -c "~/tmp"  -n 'ieee754' \
	"$RHUB/web/smth/smth.tcl $RHUB/web/smth/i.login" ';' \
    neww -d -c "~/tmp"  -n 'appleater' \
	"$RHUB/web/smth/smth.tcl $RHUB/web/smth/a.login" ';'
    neww -d -c "~/tmp"  -n 'nvim' \
	"$RHUB/web/smth/smth.tcl $RHUB/web/smth/n.login" ';'



# To retrieve tmux server pid
# tmux_pid=$(tmux display-message -p "#{pid}")

# vim: tw=78:ts=8:sts=4:sw=4:noet:ft=sh:norl:
