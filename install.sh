#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

source_dir=$(pwd)
source ${source_dir}/log.sh

# check if user is root
if [ $(id -u) != "0" ]; then
    Echo_Red "Error: you must be root to run this script:  su root "
    exit 1
fi

chmod -R 777 ${source_dir}/*


######## you source name in lib ( not include .tar.gz ) #########
mysqlTarName="mysql-5.7.25-el7-x86_64"
nginxTarName="nginx-1.15.2"
phpTarName="php-7.2.12"
jdkTarName="jdk1.8.0_202"
redisTarName="redis-stable"
redisVersion="-4.0.10"
pythonTarName="Python-3.7.2"
appName="sm_tp5"
#################################################################

Echo_Blue '================================================'
Echo_Blue '=============== 66 ========== 66 ==============='
Echo_Blue '============= 666666 ====== 666666 ============='
Echo_Blue '============ 66666666 ==== 66666666 ============'
Echo_Blue '=========== 6666666666 66 6666666666 ==========='
Echo_Blue '============ 6666666666666666666666 ============'
Echo_Blue '============= 66666666666666666666 ============='
Echo_Blue '=============== 6666666666666666 ==============='
Echo_Blue '================= 666666666666 ================='
Echo_Blue '==================== 666666 ===================='
Echo_Blue '======================= ========================'
Echo_Blue "================================================"
Echo_Blue "============= lnmp install offline ============="
Echo_Blue "================================================"
Echo_Yellow "mysql: "${mysqlTarName}
Echo_Yellow "nginx: "${nginxTarName}
Echo_Yellow " php : "${phpTarName}
Echo_Yellow "redis: "${redisTarName}${redisVersion}
Echo_Blue "================================================"

if [ "$#" -eq 2 ]
then
        Echo_Blue "Usge:./install.sh lnmp|mysql|redis|nginx|php|app|installer|python"
fi
case "$1" in
    lnmp)
        Echo_Yellow 'start to install lnmp.......................'
        Echo_Yellow "[[[[[***If you have some database data,please backup before***]]]]]"
        Echo_Blue 'Are you sure to do it ? (y/n)'
        read isinstall
        if [[ ${isinstall} != 'yes' ]] && [[ ${isinstall} != 'y' ]] && [[ ${isinstall} != 'YES' ]] && [[ ${isinstall} != 'Y' ]]; then
            exit 1
        fi
        Echo_Yellow 'Mysql root password(default 123456):'
        read mysqlPassword
        if [ -z ${mysqlPassword} ]; then
            mysqlPassword=123456
        fi
        Echo_Yellow 'This web for thinkphp5 '
        Echo_Yellow 'web path( for example /usr/local/nginx/html/ids_web/ ):'
        read webroot
        if [ -z ${webroot} ]; then
            webroot="/usr/local/nginx/html/ids_web/"
        fi
        Echo_Yellow 'Nginx service Listen port(default 443):'
        read nginxPort
        if [ -z ${nginxPort} ]; then
            nginxPort=443
        fi
        Echo_Yellow 'Redis service Listen port(default 6379):'
        read redisPort
        if [ -z ${redisPort} ]; then
            redisPort=6379
        fi
        cd ${source_dir}
        source mysql.sh
        cd ${source_dir}
        source nginx.sh
        cd ${source_dir}
        source redis.sh
        cd ${source_dir}
        source php.sh
        cd ${source_dir}

        cd ${source_dir}
        \cp ${source_dir}/bin/installer.sh /usr/local/bin/installer -rf
        chmod -R 777 /usr/local/bin/installer
        sed -i "s/redis_6380.conf/redis_${redisPort}.conf/g" /usr/local/bin/installer
        sed -i "s/grep redis/grep redis-server/g" /usr/local/bin/installer

        grep "installer start" /etc/rc.local > /dev/null
        if [ $? -eq 1 ]; then
            echo installer start >> /etc/rc.local
        fi

        cd ${source_dir}

        source app.sh
        firewall-cmd --zone=public --add-service=https --permanent
        firewall-cmd --zone=public --add-port=${nginxPort} --permanent
        firewall-cmd --reload

        installer restart
        checkService

        Echo_Green "try:  installer "

    ;;
    mysql)
        Echo_Yellow 'start to install mysql.......................'
        Echo_Yellow "***If you have some database data,please backup before***"
        Echo_Blue 'Are you sure to do it ? (y/n)'
        read isinstall
        if [[ ${isinstall} != 'yes' ]] && [[ ${isinstall} != 'y' ]] && [[ ${isinstall} != 'YES' ]] && [[ ${isinstall} != 'Y' ]]; then
            exit 1
        fi
        Echo_Yellow 'Mysql root password(default 123456):'
        read mysqlPassword
        if [ -z ${mysqlPassword} ]; then
            mysqlPassword=123456
        fi
        cd ${source_dir}
        source mysql.sh
        checkMysql
    ;;
    redis)
        Echo_Yellow 'start to install redis.......................'
        Echo_Yellow 'Redis service Listen port(default 6379):'
        read redisPort
        if [ -z ${redisPort} ]; then
            redisPort=6379
        fi
        cd ${source_dir}
        source redis.sh
        checkRedis
    ;;
    nginx)
        Echo_Yellow 'start to install nginx.......................'
        Echo_Yellow 'This web for thinkphp5 '
        Echo_Yellow 'web path( for example /usr/local/nginx/html/ids_web/ ):'
        read webroot
        if [ -z ${webroot} ]; then
            webroot="/usr/local/nginx/html/ids_web/"
        fi
        Echo_Yellow 'Listen port(default 80):'
        read nginxPort
        if [ -z ${nginxPort} ]; then
            nginxPort=80
        fi
        cd ${source_dir}
        source nginx.sh
        checkNginx
    ;;
    php)
        Echo_Yellow 'start to install php.......................'
        cd ${source_dir}
        source php.sh
        checkPhp
    ;;
     jdk)
        Echo_Yellow 'start to install jdk.......................'
        cd ${source_dir}
        source jdk.sh
        checkJdk
    ;;
    app)
        Echo_Yellow 'Mysql root password(default 123456):'
        read mysqlPassword
        if [ -z ${mysqlPassword} ]; then
            mysqlPassword=123456
        fi
        Echo_Yellow 'This web for thinkphp5 '
        Echo_Yellow 'web path( for example /usr/local/nginx/html/ids_web/ ):'
        read webroot
        if [ -z ${webroot} ]; then
            webroot="/usr/local/nginx/html/ids_web/"
        fi
        Echo_Yellow 'Nginx service Listen port(default 443):'
        read nginxPort
        if [ -z ${nginxPort} ]; then
            nginxPort=443
        fi
        Echo_Yellow 'Redis service Listen port(default 6379):'
        read redisPort
        if [ -z ${redisPort} ]; then
            redisPort=6379
        fi

        rm /usr/local/nginx/html/50x.html -rf
        rm /usr/local/nginx/html/index.html -rf

        cd ${source_dir}
        source app.sh

        firewall-cmd --zone=public --add-service=https --permanent
        firewall-cmd --zone=public --add-port=${nginxPort} --permanent
        firewall-cmd --reload

        installer restart
        checkService
        Echo_Green "try:  installer "
    ;;
    installer)
        Echo_Yellow 'Redis service Listen port(default 6379):'
        read redisPort
        if [ -z ${redisPort} ]; then
            redisPort=6379
        fi

        cd ${source_dir}
        \cp ${source_dir}/bin/installer.sh /usr/local/bin/installer -rf
        chmod -R 777 /usr/local/bin/installer
        sed -i "s/redis_6380.conf/redis_${redisPort}.conf/g" /usr/local/bin/installer
        sed -i "s/grep redis/grep redis-server/g" /usr/local/bin/installer

        #  检查/etc/rc.local 中是否有 installer start
        grep "installer start" /etc/rc.local > /dev/null
        if [ $? -eq 1 ]; then
            echo installer start >> /etc/rc.local
        fi

        installer restart
    ;;
    python)
        cd ${source_dir}
        source python.sh
    ;;
    *)
        Echo_Blue "Usge:./install.sh lnmp|mysql|redis|nginx|php|app|installer|python"
        exit 1
    ;;
esac

exit 1


