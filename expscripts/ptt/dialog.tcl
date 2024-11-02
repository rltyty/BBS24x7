#!/usr/bin/env tclsh

# ######################################################################
# Expect dialog script for [批踢踢實業坊](ptt.cc)
# ######################################################################

package require Expect

debug 0
set timeout 60

set BBS_INFO "\[批踢踢實業坊\](ptt.cc)"
set BBS_HOST "ptt.cc"
set DEFAULT_BOARD "Gossiping"

if { $has_l } {
    set loginstr $params(l)
}  else {
    set loginstr bbsu@$BBS_HOST
}

if { ! $has_b } {
    set board $DEFAULT_BOARD
} else {
    set board $params(b)
}

puts "\033\[1;44;33mAuto login script of $BBS_INFO\033\[m"
spawn luit ssh "$loginstr"

# send_user $spawn_id

while 1 {
    expect {
        "Are you sure you want to continue connecting" {send "yes\r";
                                                                exp_continue}
        "請輸入代號，或以 guest "   {send "$params(u)\r";       exp_continue}
        "請輸入您的密碼:"           {send "$params(p)\r";       exp_continue}
        "請按任意鍵繼續"            {send "\r";                 exp_continue}
        "您要刪除以上錯誤嘗試的記錄嗎?" {send "y\r";            exp_continue}
        "您想刪除其他重複登入的連線嗎" {send "y\r";             exp_continue}
        ")avorite     【 我 的 最愛 】" {send "s";              exp_continue}
        "請輸入看板名稱"            {send "$board\r\r\r";             break;}
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

