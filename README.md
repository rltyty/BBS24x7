# BBS24x7
A BBS on-hook script.

Design
======

1. Unattended login
-------------------

Use Tcl Expect script to login and rest on a specific discussion board. An
account file needs to provide as input, which must use `.login` as file
extension. The format of the content,
E.g. user1.login:
```
<connection_string>
<password>
<target_board>
```

where <connection_string> can be:

user1@bbs.mysmth.net

or

host alias you set after `Host` in ~/.ssh/config

E.g.
Host mysmth.u1			<-----
    Hostname bbs.mysmth.net
    User user1

2. Keep alive when idle
-----------------------

The Tcl Expect script will send `\0` to BBS at regular intervals of every 2
minutes to avoid connection drop by the server.

3. Give control back to user
----------------------------

The login process will be left in interactive mode after login, user can visit
the BBS as usual.

4. Managed by Tmux
------------------

Each user login is launched in a single pane window of a Tmux session for a 
BBS. So n user login, n Tmux windows in 1 Tmux session.
Users can freely attach or detach the session anytime, and have the
session rebound from one virtual console to another, from local or remote,
which is very flexible.

5. Cron and watchdog
--------------------

Put the tmux launch script in cron table, and schedule it to run at
every 2 hours for example. Everytime when the script starts, it will examine
if the BBS session exists and all login connections are alive. If not, it will
kill the dirty session if needed and create a new one.


Requirements
============

1. SSH client
2. Tcl/Expect
3. Tmux



[//]: # (vim: tw=78:ts=8:sts=4:sw=4:noet:ft=markdown:norl:)
