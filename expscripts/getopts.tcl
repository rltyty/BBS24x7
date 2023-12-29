#!/usr/bin/env tclsh

package require cmdline;
set CMD "main.tcl"
set options {
    {u.arg  ""  "username"}
    {p.arg  ""  "password"}
    {l.arg  ""  "loginstr"}
    {b.arg  ""  "default BBS board"}
    {e.arg  ""  "dialog script"}
}

set usage \
"Usage: $CMD \[-u user\] \[-p pass\] \[-l loginstr\] \[-b board\]\
-e dialog

All the arguments are optional. loginstr could be `user1@bbs.foo.net` or
the value of Host field in `~/.ssh/config` file. If loginstr is unset,
it will be computed from the user argument and the default BBS host
set in the dialog script."

try {
    array set params [::cmdline::getoptions argv $options $usage]

    # Note: argv is modified now. The recognized options are
    # removed from it, leaving the non-option arguments behind.

    set has_u [expr {[string length $params(u)] > 0}]
    set has_p [expr {[string length $params(p)] > 0}]
    set has_l [expr {[string length $params(l)] > 0}]
    set has_b [expr {[string length $params(b)] > 0}]
    set has_e [expr {[string length $params(e)] > 0}]

} trap {CMDLINE USAGE} {msg o} {
    # Trap the usage signal, print the message, and exit the application.
    # Note: Other errors are not caught and passed through to higher levels!
    puts $msg
    exit 1
} finally {
    if { ! $has_e } {
        puts "Error: dialog script (-e dialog) required.\n"
        puts $usage
        exit 2
    }
}

if { [ info exists ::env(DEBUG) ] } {
    if { $has_u } { puts "user=|$params(u)|" }
    if { $has_p } { puts "pass=|$params(p)|" }
    if { $has_l } { puts "loginstr=|$params(l)|" }
    if { $has_b } { puts "board=|$params(b)|" }
    if { $has_e } { puts "dialog=|$params(e)|" }
}

# Sample:
# > ./getopts.tcl -u u1\* -p p\"\*2 -l bbsu\*\*@foo.net -b Goss\"\*\"i\"ping -e dialog.tcl
# user=|u1*|
# pass=|p"*2|
# loginstr=|bbsu**@foo.net|
# board=|Goss"*"i"ping
# dialog=|dialog.tcl|
