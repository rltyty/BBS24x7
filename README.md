# BBS24x7
A BBS on-hook tool

# Usage

See [user guide](guide.md)

# Design

![][2]

## 1. Unattended login and user information

Use Tcl Expect script to login and rest on a specific discussion board.
An user information file needs to provide as input. The format is quadruple
strings for each line, which defines a user login:

```
<user>      <password>      <loginstr>      <default_board>

```
where each field is optional.

If <loginstr> is set, it will be used as the SSH connection(`ssh <loginstr>`).
It can be normal user@host format like

```
foo@bbs.bar.net
```

or

host alias set for the `Host` field in ~/.ssh/config like `bar.foo` in the
below example

```
Host bar.foo                 <-----
    Hostname bbs.bar.net
    User foo
```

This SSH configuration way can provide more control of login. For example,
if you want to connect behind a forwar proxy
```
Host bar.foo
    Hostname bbs.bar.net
    User foo
    ProxyCommand `which ncat` --proxy-type socks5 --proxy 127.0.0.1:1080 %h %p
```

<board_name> specifies which BBS board the cursor will rest in after login.
This field is optional and the default board set in the corresponding *.tcl
file will be used if omitted.

## 2. Keep alive when idle

The Tcl Expect script will send `\0` to BBS at regular intervals of every 2
minutes to avoid connection drop by the server.

## 3. Give control back to user

When a series of commands are done after login, the script process will be
left in the interactive mode, users can visit the BBS as usual.

## 4. Managed by Tmux

Each user session is created in a single pane window of a Tmux session for a 
BBS. So n different user logins, n Tmux windows in 1 Tmux session.
Users can freely attach or detach the Tmux session anytime, from one virtual
console or another, from local or remote, which is very flexible.

e.g. To attach to a Tmux session called `smth` on remote server `rpi-lan`

```
ssh rpi-lan -t tmux a -t smth
```

## 5. Multiple session support

![][3]
![][4]

## 6. Cron and watchdog

Put the tmux launch script in cron table, and schedule it to run periodically
like every hour. Every time when the script starts, it will examine whether
the BBS session exists and all login connections are alive. If not, it will
recover the broken Tmux session. If userinfo file is updated and newer than
the timestamp when the session was created, the session will get killed and
recreated.

# Docker support

See [docker guide](docker/README.md) and [`arg6/bbs24x7`][5] on dockerhub.

# Requirements

- SSH/Telnet client
- Tcl/Expect and Tcllib
- Luit (2.0+)
- Tmux

NOTE:
`Luit` is used to translate character set and solve the "garbled text"
problem met when visit east Asian BBS. On Debian 11, the default luit(1.1.1)
installed as a part of x11-utils is too old, may cause unexpected issues
like segmentation fault. Build and install from luit 2.0 [source][1]. On
Debian 12, the default luit installed is v2.0, so no need to build from
source.

[1]: <https://invisible-island.net/luit/> "Luit"
[2]: <Resources/screenshot.1.png> "Multiple BBS logins in a Tmux session"
[3]: <Resources/multi-session.1.png> "Multiple sessions 1"
[4]: <Resources/multi-session.2.png> "Multiple sessions 2"
[5]: <https://hub.docker.com/r/arg6/bbs24x7> "arg6/bbs24x7"


[//]: # (vim: tw=78:ts=8:sts=4:sw=4:noet:ft=markdown:norl:)
