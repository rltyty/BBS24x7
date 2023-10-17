# Usage for mysmth.net(水木社区)

## A quick run

```
./tmux-smth.sh ./userdb
```

## Watch dog mode with Cron

```
5  0-23/2  * * *   BBS24x7/mysmth.net/tmux-smth.sh BBS24x7/mysmth.net/userdb > /dev/null 2>>${HOME}/tmp/smth-err.log
```

## Debugging

```
export DEBUG=1
./tmux-smth.sh ./userdb
```
