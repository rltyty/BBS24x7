#!/usr/bin/env tclsh

# ######################################################################
# Expect dialog script for [水木社区](bbs.newsmth.net)
# ######################################################################

package require Expect

debug 0
set timeout 60

set BBS_INFO "\[水木社区\](bbs.newsmth.net)"
set BBS_HOST "bbs.newsmth.net"
set DEFAULT_BOARD "hotboards"

if { $has_l } {
    set loginstr $params(l)
}  else {
    set loginstr $params(u)@$BBS_HOST
}

if { ! $has_b } {
    set board $DEFAULT_BOARD
} else {
    set board $params(b)
}

puts "\033\[1;44;33mAuto login script of $BBS_INFO\033\[m"
spawn luit -encoding GB18030 ssh "$loginstr"

# send_user $spawn_id

while 1 {
    expect {
        "Are you sure you want to continue connecting" {send "yes\r";
                                                                exp_continue}
        "password"                  {send "$params(p)\r";       exp_continue}
        "离开时留下的话"            {send "\r" ;                exp_continue}
        "你同时上线的窗口数过多"    {send "1\r" ;               exp_continue}
        "欢迎您使用ssh方式访问"     {send "\r" ;                exp_continue}
        "如何处理以上密码输入错误记录"     {send "m\r" ;        exp_continue}
        "按任何键继续"              {send "\r" ;                exp_continue}
        "按任意键继续"              {send "\r" ;                exp_continue}
        -re "这是您第.*次上站"      {send "\r" ;                exp_continue}
        "近期热点"                  {send "\r" ;                exp_continue}
        "目前选择"                  {send "F\r";                exp_continue}
        "个人定制区"                {send "s"; after 2000;  exp_continue}
        "请输入讨论区名称"          {send "$board\r"; break;}
    }
}

# send_user "Now interact mode!"

set CTRLZ \032
interact {
    timeout 120                 {send "\0"} # send '\0' when idle
    #-reset $CTRLZ               {exec kill -STOP [pid]}
    \001                        {send_user "you typed a ctrl-a\n";
                                 send "\001"
                                }
    #!                           {send_user "The date is."}
    \003                        exit
    foo                         {send_user "bar"}
    ~~
}


#    \004                       {# log off
#    send "e" ; after 1000; send "e"; after 1000;
#    send "G\r" ; after 1000; send "4\r";
#    after 1000;; send "\r" }

