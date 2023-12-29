#!/usr/bin/env tclsh

set script_path [ file dirname [ file normalize [ info script ] ] ]
source $script_path/../expscripts/getopts.tcl
source $params(e)

# Sample:
# ./main.tcl -u u1\* -p p\"\*2 -f bbsu\*\*@foo.net -b Goss\"\*\"i\"ping -e dialog.tcl
# user=|u1*|
# pass=|p"*2|
# loginstr=|bbsu**@foo.net|
# board=|Goss"*"i"ping|
# dialog=|dialog.tcl|
