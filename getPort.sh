#!/bin/bash

# portRange="80-81" 	# 可用于读取配置文件
# rangeStart=$(echo ${portRange} | awk -F '-' '{print $1}')
# rangeEnd=$(echo ${portRange} | awk -F '-' '{print $2}')

rangeStart=$1
rangeEnd=$2

if [ $1 -le $2 ]; then
	echo "123" > /dev/null
else
	echo "error: please check port range"
	exit
fi

PORT=0
# 判断当前端口是否被占用，没被占用返回0，反之1
function Listening {
   # 不严谨写法
   # TCPListeningnum=`netstat -an | grep ":$1 " | awk '$1 == "tcp" && $NF == "LISTEN" {print $0}' | wc -l`
   # UDPListeningnum=`netstat -an | grep ":$1 " | awk '$1 == "udp" && $NF == "0.0.0.0:*" {print $0}' | wc -l`
   # 严谨写法 -- 修改时间 2022-07-22
   TCPListeningnum=`netstat -an | grep ":$1 " | awk '/^tcp.*/ && $NF == "LISTEN" {print $0}' | wc -l`
   UDPListeningnum=`netstat -an | grep ":$1 " | awk '/^udp.*/ && $NF == "0.0.0.0:*" {print $0}' | wc -l`
   (( Listeningnum = TCPListeningnum + UDPListeningnum ))
   if [ $Listeningnum == 0 ]; then
       echo "0"
   else
       echo "1"
   fi
}

# 指定区间随机数
function random_range {
   shuf -i $1-$2 -n1
}

# 得到随机端口
function get_random_port {
   templ=0
   cnt=0
   while [[ $PORT == 0 && $cnt -le 100 ]]; do
       cnt=`expr $cnt + 1`
       temp1=`random_range $1 $2`
       if [ `Listening $temp1` == 0 ] ; then
              PORT=$temp1
       fi
   done
   echo "$PORT"
}

# main
get_random_port ${rangeStart} ${rangeEnd};
    