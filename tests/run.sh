#!/bin/sh
# Copyright 2023 David Ren
# Author: rbach (except10n.rlt@gmail.com)
# Revision: 0.1
# Last udpate: 2023-12-13
set -o nounset                              # Treat unset variables as an error
set -e                                      # Exit when there is an error

# 1. Test option parser
./test_getopts.tcl -u u1\* -p p\"\*2 -l bbsu\*\*@foo.net -b Goss\"\*\"i\"ping -e dialog.tcl

# 2. Test main program
printf "Real user, password or loginstr needed to run the tests!\n" 
DEBUG=1 ../tmux.sh ./sess1 ./sess2 ./sess3

# vim: tw=78:ts=8:sts=4:sw=4:et:ft=sh:norl:

