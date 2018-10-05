#!/usr/bin/expect
set timeout 600
spawn  ./shadowsocks-all.sh install
expect  "(Default Shadowsocks-Python):"
send "4\r"
expect "(Default password: teddysun.com):"
send  "Luo008051\r"
expect "(Default port:"
send "31523\r"
expect "Which cipher you'd select(Default: aes-256-gcm):"
send   "14\r"
expect "(default: n):"
send "n\r"
expect "Which obfs you'd select(Default: http):"
send "1\r"

expect "Press any key to start...or Press Ctrl+C to cancel"
send "\r"
expect EOF
