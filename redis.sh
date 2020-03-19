#!/bin/bash

init_redis_code(){
    pkill redis
    if [ ! -d "/usr/local/redis" ]; then
        mkdir  /usr/local/redis
    fi
    cd /usr/local/redis
    \cp $source_dir/lib/${redisTarName}.tar.gz /usr/local/redis/ -rf
    tar  -zxvf  ${redisTarName}.tar.gz
    \cp /usr/local/redis/${redisTarName}/* /usr/local/redis -rf

    make
    make  install
    make PREFIX=/usr/local/redis install

    if [ ! -d "/usr/local/redis/bin/conf" ]; then
        mkdir  /usr/local/redis/bin/conf
    fi

    if [ ! -d "/usr/local/redis/bin/data" ]; then
        mkdir  /usr/local/redis/bin/data
    fi

    if [ ! -d "/usr/local/redis/log" ]; then
        mkdir   /usr/local/redis/log
    fi

}

init_redis_conf(){
    \cp /usr/local/redis/${redisTarName}/redis.conf /usr/local/redis/bin/conf/redis_${redisPort}.conf -rf
    cd  /usr/local/redis/bin/conf
    sed -i "s/port 6379/port ${redisPort}/g" redis_${redisPort}.conf
    sed -i "s/daemonize no/daemonize yes/g" redis_${redisPort}.conf
    sed -i "s/logfile \"\"/logfile \"\/usr\/local\/redis\/log\/redis_${redisPort}.log\"/g" redis_${redisPort}.conf
    sed -i "s/pidfile \/var\/run\/redis_6379.pid/logfile \"\/usr\/local\/redis\/log\/redis_${redisPort}.log\"/g" redis_${redisPort}.conf
    sed -i "s/dbfilename dump.rdb/dbfilename dump_${redisPort}.rdb/g" redis_${redisPort}.conf
    # 替换文件内容
    sed -i "s/dir \.\//dir \.\/data/g" redis_${redisPort}.conf

}

system_support(){
    echo  1024  > /proc/sys/net/core/somaxconn

    grep "vm.overcommit_memory=1" /etc/sysctl.conf > /dev/null
    if [ $? -eq 1 ]; then
        echo "vm.overcommit_memory=1" >> /etc/sysctl.conf
    fi
    # 判断 /et/sysctl.conf 文件中是否有 net.core.somaxconn=1024 字符串
    grep "net.core.somaxconn=1024" /etc/sysctl.conf > /dev/null
    if [ $? -eq 1 ]; then
        echo "net.core.somaxconn=1024" >> /etc/sysctl.conf
    fi
    sysctl  -p

    echo never > /sys/kernel/mm/transparent_hugepage/enabled
    grep "echo never >  /sys/kernel/mm/transparent_hugepage/enabled" /etc/rc.local > /dev/null
    if [ $? -eq 1 ]; then
        echo "echo never >  /sys/kernel/mm/transparent_hugepage/enabled" >>  /etc/rc.local
    fi

}

start_redis(){
    cd  /usr/local/redis/bin
    ./redis-server  ./conf/redis_${redisPort}.conf
}

init_redis_code
init_redis_conf
system_support
start_redis



