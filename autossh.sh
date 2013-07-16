#!/usr/bin/expect -f

#
##################################################################
#
# 使用expect自动登录ssh，被sshto.sh调用
#
# author: bluffstone@gmail.com 
# date: 2012-09-17
# modify: 2013-03-07
#################################################################

set user_name [lindex $argv 0]
set password  [lindex $argv 1]
set server_name  [lindex $argv 2]

send_user "username：$user_name\r"

spawn /usr/bin/ssh -o StrictHostKeyChecking=no $user_name@$server_name
expect "*password:"
send "$password\r"
interact
#expect eof
#send "exit\r"