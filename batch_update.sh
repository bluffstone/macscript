#!/bin/sh
#
##################################################################
#
# 根据列表文件（后缀.list的文件）自动更新和编译脚本。
#
# author: bluffstone@gmail.com
# date: 2012-12-31
#
# 命令：
#	./batch_update.sh xxxx.list
#
# 说明：
#	xxxx.list  svn工程的目录列表
#
#
# 最佳实践：
#   1. 建立一个Trunk的list，命名trunk.list，列出每次需要更新的所有trunk工程列表；
#	2. 针对每个项目，建立一个projectxx.list，包括该项目内的所有系统；
#	3. 针对文档内svn工程，建立一个独立的list。
#
#################################################################

# SVN的默认用户名
DEFAULT_SVN_USER_NAME=test
DEFAULT_SYSTEMS_LIST=systems.list
SYSTEMS_LIST=$DEFAULT_SYSTEMS_LIST
POM=pom.xml
OUTPUT_LOG=update_log.log


update_and_mvn_system(){

	# 打印分区间隔
	print_segment

	echo "开始更新:`pwd`"
	# 更新代码
    svn up --username=$DEFAULT_SVN_USER_NAME >>$OUTPUT_LOG
    tail -5 $OUTPUT_LOG

	if [ -e "$POM" ];  then
		echo ""
		echo "开始编译:`pwd`"
		# 重新编译
	    mvn eclipse:eclipse  >>$OUTPUT_LOG
	    tail -7 $OUTPUT_LOG
	fi
}

print_segment(){
	echo ""
	echo "==================================================="
	echo "==================================================="
}

update_systems(){

	#备份当前目录
	original_pwd=`pwd`
	OUTPUT_LOG=$original_pwd/$OUTPUT_LOG

	echo "开始更新和编译，`date`" > $OUTPUT_LOG 
	echo "原始目录:" ,$original_pwd >> $OUTPUT_LOG

	# 依次处理每一个系统
	for var_system in  `cat $SYSTEMS_LIST | grep -v "#"`; do		

		if [ -d "$var_system" ];  then
			cd $var_system
				
			# 更新系统代码并且重新编译
			update_and_mvn_system 
		fi
	done

	# 恢复目录
	cd $original_pwd
	echo "恢复目录:" ,$original_pwd >> $OUTPUT_LOG

}

# ===============================================================
#  主流程
# ===============================================================

if [ $# -gt 0  ]; then
	SYSTEMS_LIST=$1
fi

if [ ! -e "$SYSTEMS_LIST" ];  then
	echo "无系统目录列表文件，你可以先创建一个名称", $DEFAULT_SYSTEMS_LIST ,"的默认列表文件；"
	echo "或者再一次直接输入列表文件名称："
	read SYSTEMS_LIST
fi

if [ ! -e "$SYSTEMS_LIST" ];  then 
	echo $SYSTEMS_LIST":无效系统目录列表文件，退出程序。"
	exit 1
fi

update_systems



