# User Guide

## A quick run

    # Method 1:
    tmux.sh -s sess1 -e dialog.tcl -u userinfo

    # Method 2:
    tmux.sh sess1 sess2 sess3

    # show help
    tmux.sh -h

## User information file format

    # user      password            Host_in_ssh_conf    default_board

    user1       password1           *                   *
    user2       password2           *                   Gossiping
    *           password3           bbs.ex.3            Hotboards
    *           *                   bbs.ex.thru_proxy   Music
    *           *                   bbs5                *   # inline comment

Note:
'*' means an option field is empty and default behaviour of that option
should be used.
The cursor will rest in the default board after login if the 4th field is
not empty.
A Comment starts from '#' to the end of the line.

## SSH Client Configuration

    Host bbs.3
        Hostname bbs.example.net
        User     user3

    Host bbs.4.thru_proxy
        Hostname bbs.example.net
        User     user4
        ProxyCommand `which ncat` --proxy-type socks5 --proxy 127.0.0.1:1080 %h %p

    Host bbs.5
        Hostname bbs.example.net
        User     user5
        IdentityFile ~/.ssh/id_rsa


## Watch dog mode with Cron

    5  0-23/2  * * *   <fullpath>/tmux.sh <fullpath>/sess1 > /dev/null 2>>${HOME}/tmp/example.err.log

## Debugging

    DEBUG=1 tmux.sh ...
