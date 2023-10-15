# Usage for mysmth.net(水木社区)

## A one time run

```
./tmux-smth.sh ./userdb
```

## Use crontab for revisiting periodically

```
5  0-23/2  * * *   BBS24x7/mysmth.net/tmux-smth.sh BBS24x7/mysmth.net/userdb > /dev/null 2>>${HOME}/tmp/smth-err.log
```

