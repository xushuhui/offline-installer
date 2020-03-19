#!/bin/bash

export MAIN_HOME=$PWD/


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

###########################################nginx#######################################
start_nginx()
{
    NGINX_PROCPID=`ps -ef|grep /usr/local/nginx/sbin/nginx|grep -v grep|grep -v "su"|grep -v tail |grep -v vi|grep -v admin.sh|awk '{print $2}'`
    if [ "$NGINX_PROCPID" != "" ]
    then
        Echo_Green "nginx is already running pid[$NGINX_PROCPID]\n"
    else
        Echo_Yellow "Starting nginx ..."
		/usr/local/nginx/sbin/nginx
		show_nginx
    fi

}

stop_nginx()
{
        Echo_Yellow "Stoping nginx ..."
        pkill nginx

}

show_nginx()
{
        Echo_Yellow "================[nginx process]======================"
        ps -ef|grep nginx|grep -v "grep"|grep -v "su"|grep -v tail|grep -v vi
        Echo_Yellow "====================================================="
}

restart_nginx()
{
        stop_nginx
        start_nginx
}

###########################################mysql#######################################

start_mysql()
{
    MYSQL_PROCPID=`ps -ef|grep /usr/local/mysql/bin/mysqld|grep -v grep|grep -v "su"|grep -v tail |grep -v vi|grep -v admin.sh|awk '{print $2}'`
    if [ "$MYSQL_PROCPID" != "" ]
    then
        Echo_Green "mysql is already running pid[$MYSQL_PROCPID]\n"
    else
        Echo_Yellow "Starting mysql ..."
		service mysqld start
		show_mysql
    fi

}

stop_mysql()
{
        Echo_Yellow "Stoping mysql ..."
        for proc in `ps -ef|grep mysqld |grep -v grep|grep -v "su"|grep -v tail |grep -v vi|awk '{print $2}'`
        do
			echo "kill -9 $proc"
			kill -9 $proc
        done

}

show_mysql()
{
        Echo_Yellow "================[mysqld process]====================="
        ps -ef|grep /usr/local/mysql/bin/mysqld|grep -v "grep"|grep -v "su"|grep -v tail|grep -v vi
        Echo_Yellow "====================================================="
}
restart_mysql()
{
        stop_mysql
        start_mysql
}

###########################################php#######################################
start_php()
{
    PHP_PROCPID=`ps -ef|grep php-fpm|grep -v grep|grep -v "su"|grep -v tail |grep -v vi|grep -v admin.sh|awk '{print $2}'`
    if [ "$PHP_PROCPID" != "" ]
    then
        Echo_Green "php-fpm is already running pid[$PHP_PROCPID]\n"
    else
        Echo_Yellow "Starting php-fpm ..."
		service php-fpm start
		show_php
    fi

}

stop_php()
{
        Echo_Yellow "Stoping php-fpm ..."
        for proc in `ps -ef|grep php-fpm |grep -v grep|grep -v "su"|grep -v tail |grep -v vi|awk '{print $2}'`
        do
			Echo_Yellow "kill -9 $proc"
			kill -9 $proc
        done

}

show_php()
{
        Echo_Yellow "================[php-fpm process]===================="
        ps -ef|grep php-fpm|grep -v "grep"|grep -v "su"|grep -v tail|grep -v vi
        Echo_Yellow "====================================================="
}
restart_php()
{
        stop_php
        start_php
}

###########################################redis#######################################
start_redis(){
    REDIS_PROCPID=`ps -ef|grep redis|grep -v grep|grep -v "su"|grep -v tail |grep -v vi|grep -v admin.sh|awk '{print $2}'`
        if [ "$REDIS_PROCPID" != "" ]
        then
            Echo_Green "redis is already running pid[$REDIS_PROCPID]\n"
        else
            Echo_Yellow "Starting redis ..."

            echo  1024  > /proc/sys/net/core/somaxconn
            sysctl  -p
            echo never > /sys/kernel/mm/transparent_hugepage/enabled

    		cd /usr/local/redis/bin
            ./redis-server conf/redis_6380.conf
            show_redis
        fi
    cd $MAIN_HOME
}

stop_redis(){
    Echo_Yellow "Stoping redis ..."
    pkill redis
}

show_redis(){
    Echo_Yellow "================[redis process]======================"
    ps -ef|grep redis|grep -v "grep"|grep -v "su"|grep -v tail|grep -v vi
    Echo_Yellow "====================================================="
}

redis_restart(){
    stop_redis
    start_redis
}

###########################################heat_jump#######################################
start_heat_jump(){
    REDIS_PROCPID=`ps -ef|grep heat_jump|grep -v grep|grep -v "su"|grep -v tail |grep -v vi|grep -v admin.sh|awk '{print $2}'`
        if [ "$REDIS_PROCPID" != "" ]
        then
            Echo_Green "heat_jump is already running pid[$REDIS_PROCPID]\n"
        else
            Echo_Yellow "Starting heat_jump ..."
            cd /usr/local/nginx/html/ids_web/shell
            ./admin.sh start_heat_jump
        fi
    cd $MAIN_HOME
}

stop_heat_jump()
{
        Echo_Yellow "Stoping heat_jump ..."
        for proc in `ps -ef|grep heat_jump |grep -v grep|grep -v "su"|grep -v tail |grep -v vi|awk '{print $2}'`
        do
			Echo_Yellow "kill -9 $proc"
			kill -9 $proc
        done
}

show_heat_jump(){
    Echo_Yellow "================[heat_jump process]=================="
    ps -ef|grep heat_jump|grep -v "grep"|grep -v "su"|grep -v tail|grep -v vi
    Echo_Yellow "====================================================="
}

restart_heat_jump(){
    stop_heat_jump
    start_heat_jump
}

#######################################################################################

start()
{
    start_nginx
    start_mysql
    start_redis
    start_php
    start_heat_jump
}

stop()
{
    stop_php
    stop_nginx
    stop_mysql
    stop_redis
    stop_heat_jump
}

show()
{
    show_nginx
    show_mysql
    show_php
    show_redis
    show_heat_jump
}

restart()
{
    stop
    start
}

if [ "$#" -eq 2 ]
then
        Echo_Blue "Usge:./installer start|stop|restart"
fi

case "$1" in
        start_nginx) start_nginx
        ;;
        stop_nginx) stop_nginx
        ;;
        restart_nginx) restart_nginx
        ;;
        start_mysql) start_mysql
        ;;
        stop_mysql) stop_mysql
        ;;
        restart_mysql) restart_mysql
        ;;
        start_php) start_php
        ;;
        stop_php) stop_php
        ;;
        restart_php) restart_php
        ;;
        start_redis) start_redis
        ;;
        stop_redis) stop_redis
        ;;
        restart_redis) restart_redis
        ;;
        start_heat_jump) start_heat_jump
        ;;
        stop_heat_jump) stop_heat_jump
        ;;
        restart_heat_jump) restart_heat_jump
        ;;
        start) start
        ;;
        stop) stop
        ;;
        restart) restart
        ;;
        show) show
        ;;
        *) echo "Usge:
        一.命令介绍:
        installer start                    开启所有服务
        installer stop                     停止所有服务
        installer restart                  重启所有服务
        installer show                     查看所有服务

        installer start_nginx              开启nginx服务
        installer stop_nginx               停止nginx服务
        installer restart_nginx            重启nginx服务

        installer start_mysql              开启mysql服务
        installer stop_mysql               停止mysql服务
        installer restart_mysql            重启mysql服务

        installer start_php                开启php服务
        installer stop_php                 停止php服务
        installer restart_php              重启php服务

        installer start_redis              开启redis服务
        installer stop_redis               停止redis服务
        installer restart_redis            重启redis服务

        installer start_heat_jump          开启心跳服务
        installer stop_heat_jump           停止心跳服务
        installer restart_heat_jump        重启心跳服务

        "
        ;;
esac

