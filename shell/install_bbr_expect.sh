#!/usr/bin/expect
set timeout 600
spawn  bash bbr.sh
expect "Press any key to start...or Press Ctrl+C to cancel"
send "\r"
expect EOF