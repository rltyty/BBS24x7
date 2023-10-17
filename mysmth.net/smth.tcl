#!/usr/bin/tclsh

package require Expect 

debug 0
set timeout 60

set default_board "hotboards"
set login ""
set pass ""
set board ""
puts "\033\[1;44;33mAuto login script of MYSMTH.net\033\[m"

if {$argc < 2} {
    puts "Usage: smth.tcl <login> <pass> [<board>], where <login> is usually\
the value of Host field in a ssh_config file"
    exit 1
}

set login [lindex $argv 0]
set pass [lindex $argv 1]
if {$argc >= 3} {
    set board [lindex $argv 3]
} else {
    set board $default_board
}
spawn luit -encoding GB18030 ssh "$login"

# send_user $spawn_id

while 1 {
    expect {
        "password"                  {send "$pass\r";            exp_continue}
        "离开时留下的话"            {send "\r" ;                exp_continue}
        "你同时上线的窗口数过多"    {send "1\r" ;               exp_continue}
        "欢迎您使用ssh方式访问"     {send "\r" ;                exp_continue}
        "如何处理以上密码输入错误记录"     {send "m\r" ;        exp_continue}
        "按任何键继续"              {send "\r" ;                exp_continue}
        "按任意键继续"              {send "\r" ;                exp_continue}
        -re "这是您第.*次上站"      {send "\r" ;                exp_continue}
        "近期热点"                  {send "\r" ;                exp_continue}
        "目前选择"                  {send "F\r";                exp_continue}
        "个人定制区"                {send "s"; after 1000;  exp_continue}
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
