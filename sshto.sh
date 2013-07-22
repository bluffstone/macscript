#!/bin/sh
#
##################################################################
#
# 使用ssh链接各开发环境应用服务的简单工具。
#
# author: bluffstone@gmail.com 
# date: 2012-09-17
# modify: 2013-03-07
#
#
# 命令形式：
#		sshto [username@]url  [password]
# 支持自动补全一级、二级域名, 自动用户和密码记录和补全。
# 
# 最佳实践：
#	1. 先配置默认的一级、二级域名、完整域名，默认密码、默认用户名；
# 	2. 对于经常登录的一个系统，假设域名为 appA.stable.company.com，配置完第一步后，可以直接使用以下命令：
#		./sshto
#	3. 对于其它系统，使用命令：
#		./sshto appB
#		./sshto appC.sit
#		./sshto admin@appD.sit.company.com password
#
#################################################################

# ===============================================================
#  常量定义
# ===============================================================
DEFAULT_LEVEL_1_DOMAIN_URL=domain.net
DEFAULT_LEVEL_2_DOMAIN_URL=stable.$DEFAULT_LEVEL_1_DOMAIN_URL
SEP=@
DEFAULT_LOGINE_NAME=log
DEFAULT_SSH_URL=appname.$DEFAULT_LEVEL_2_DOMAIN_URL
DEFAULT_PASSWD=123456
SSH_LOG_HIS=sshlog.his

# ===============================================================
#  变量定义
# ===============================================================
user_name=$DEFAULT_LOGINE_NAME
ssh_url=$DEFAULT_SSH_URL
password=$DEFAULT_PASSWD

# ===============================================================
#  主流程
# ===============================================================

# 参数处理
if [ $# -eq 0 ]; then
 	echo "ERROR: no param. " 1>&2
 	echo "Usage: "
 	echo "       sshto [username@]url  [password]" 
    exit 1
fi

# 读取参数1
cmd_line=$1


#读取参数2
has_set_passwd=n
if [ $# -eq 2 ]; then
	has_set_passwd=y
	password=$2
fi


# 根据是否含有@切割字符串
has_sep=`echo $cmd_line | grep $SEP | wc -l`
if [ $has_sep -gt 0 ] ; then

	# 有@，形如username@ssh_url
	user_name=${cmd_line%@*}
	ssh_url=${cmd_line#*@}
else
	# 无@，默认参数是url
	ssh_url=$cmd_line
fi


# 自动补充二级域名
if [ `echo $ssh_url | grep "\." | wc -l` -eq 0 ] ; then
	ssh_url=$ssh_url.$DEFAULT_LEVEL_2_DOMAIN_URL 
fi


# 自动补充一级域名
if [ `echo $ssh_url | grep $DEFAULT_LEVEL_1_DOMAIN_URL | wc -l` -eq 0 ] ; then
	ssh_url=$ssh_url.$DEFAULT_LEVEL_1_DOMAIN_URL 
fi

# 处理用户登录密码
if [ $has_set_passwd = "y" ] ; then
	
	# 如果手工设置了密码，则自动记忆设置的密码
	if [ -e $SSH_LOG_HIS ] ; then
		# 历史登录文件存在，则判断密码是否存在
		if [ `grep "$user_name@$ssh_url" $SSH_LOG_HIS | wc -l` -gt 0 ] ; then
			# 同样的服务器和用户名所对应的密码存在，则覆盖
			grep -v "$user_name@$ssh_url" $SSH_LOG_HIS > $SSH_LOG_HIS.bak
			mv $SSH_LOG_HIS.bak $SSH_LOG_HIS
			echo $user_name@$ssh_url@$password >> $SSH_LOG_HIS
		else
			# 不存在同样的服务器和用户名所对应的密码，则添加
			echo $user_name@$ssh_url@$password >> $SSH_LOG_HIS
		fi
	else
		# 历史登录文件不存在，创建一个新的
		echo $user_name@$ssh_url@$password > $SSH_LOG_HIS
	fi
else
	# 判断自动记忆文件是否存在
	if [ -e $SSH_LOG_HIS ] ; then
		# 历史登录文件存在，则判断密码是否存在
		if [ `grep "$user_name@$ssh_url" $SSH_LOG_HIS | wc -l` -gt 0 ] ; then
			# 读取自动记忆的密码
			tmp_record=`grep "$user_name@$ssh_url" $SSH_LOG_HIS `
			password=${tmp_record##*@}
		fi
	fi
fi

echo "[DEBUG INFO] user: $user_name password:$password  server:$ssh_url set_paswd:$has_set_passwd"

#调用自动登录ssh脚本登录
autossh.sh $user_name $password $ssh_url

