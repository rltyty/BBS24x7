#!/usr/bin/env tclsh

set script_path [ file dirname [ file normalize [ info script ] ] ]
source $script_path/../expscripts/getopts.tcl

if { $has_u } { puts "user=|$params(u)|" }
if { $has_p } { puts "pass=|$params(p)|" }
if { $has_l } { puts "loginstr=|$params(l)|" }
if { $has_b } { puts "board=|$params(b)|" }
if { $has_e } { puts "dialog=|$params(e)|" }


# Sample:
# ./test_getopts.tcl -u u1\* -p p\"\*2 -f bbsu\*\*@foo.net -b Goss\"\*\"i\"ping -e dialog.tcl
