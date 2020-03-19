#!/bin/bash

Color_Text()
{
  echo -e " \e[0;$2m$1\e[0m"
}

Echo_Red()
{
  echo $(Color_Text "$1" "31")
}

Echo_Green()
{
  echo $(Color_Text "$1" "32")
}

Echo_Yellow()
{
  echo $(Color_Text "$1" "33")
}

Echo_Blue()
{
  echo $(Color_Text "$1" "34")
}

writeLog(){
    mType=\>
    mEmpty=" "
    SERVICE_FILE=${source_dir}/log/install.log
    echo `date`${mEmpty}${mType}${mEmpty}$1 >> ${SERVICE_FILE}

}

checkRedis(){
    myredis=`ps -ef|grep redis|grep -v grep|grep -v 'su'|grep -v tail |grep -v vi|grep -v admin.sh|awk '{print $2}'`
    if [ "${myredis}" != "" ];then
        echo -e "\033[32m Redis is running \033[0m"
    else
        echo -e "\033[31m Redis is false \033[0m"
    fi
}

checkPhp(){
    myphp=`ps -ef|grep php-fpm|grep -v grep|grep -v 'su'|grep -v tail |grep -v vi|grep -v admin.sh|awk '{print $2}'`
    if [ "${myphp}" != "" ];then
        echo -e "\033[32m  php  is running \033[0m"
    else
        echo -e "\033[31m  php  is false \033[0m"
    fi
}

checkMysql(){
    mysqld=`ps -ef|grep mysqld|grep -v grep|grep -v 'su'|grep -v tail |grep -v vi|grep -v admin.sh|awk '{print $2}'`
    if [ "${mysqld}" != "" ];then
        echo -e "\033[32m mysql is running \033[0m"
    else
        echo -e "\033[31m mysql is false \033[0m"
    fi
}

checkNginx(){
    mynginx=`ps -ef|grep /usr/local/nginx/sbin/nginx|grep -v grep|grep -v 'su'|grep -v tail |grep -v vi|grep -v admin.sh|awk '{print $2}'`
    if [ "${mynginx}" != "" ];then
        echo -e "\033[32m nginx is running \033[0m"
    else
        echo -e "\033[31m nginx is false \033[0m"
    fi
}
checkJdk(){
     if [  -f "/usr/local/java/${jdkTarName}/bin/java" ];then
         echo -e "\033[32m  jdk  is ok \033[0m"
     else
        echo -e "\033[31m  jdk  is false \033[0m"
    fi
}
checkService(){
    checkRedis
    checkPhp
    checkMysql
    checkNginx
}


