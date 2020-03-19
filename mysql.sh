#!/bin/bash


init_user(){
    systemctl stop mysqld
    pkill mysqld
    groupadd   mysql
    useradd -g mysql -d  /usr/local/mysql   mysql
}

init_code(){
    cd $source_dir/lib/
    tar  -zxvf   ${mysqlTarName}.tar.gz
    if [ ! -d "/usr/local/mysql" ]; then
        mkdir  /usr/local/mysql
    else
        pkill mysql
    fi
    echo 'cp files ...'
    \cp   ${source_dir}"/lib/${mysqlTarName}/"*   /usr/local/mysql -rf
}

install_mysql(){
    cd   /usr/local/mysql
    ./bin/mysqld   --user=mysql   --basedir=/usr/local/mysql   --datadir=/usr/local/mysql/data  --initialize
}

conf_my_cnf(){

    echo "
[mysqld]
basedir=/usr/local/mysql
datadir=/usr/local/mysql/data
character_set_server=utf8
init_connect=’SET NAMES utf8’

# 允许127.0.0.1 登录
skip_name_resolve=ON
port=3306
server_id = 1
log-bin = mysql-bin
binlog-format = ROW

# 一次能处理数据包的最大大小值
max_allowed_packet=32M
sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION

[client]
default-character-set=utf8
port=3306
    "  > /etc/my.cnf

    chmod -R 644 /etc/my.cnf

}

create_start(){
    \cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld -rf
    chmod -R 755 /etc/init.d/mysqld
}

start_mysql(){
    pkill  mysql
    cd  /usr/local/mysql/bin
    ./mysqld_safe --user=mysql --skip-grant-tables --skip-networking &
    ./mysql  -uroot  -p <<EOF
use mysql;
flush privileges;
grant all privileges on *.* to 'root'@'127.0.0.1' identified by '${mysqlPassword}' with grant option;
grant all privileges on *.* to 'root'@'localhost' identified by '${mysqlPassword}' with grant option;
flush privileges;
exit
EOF
}

link_mysql(){
    if [ ! -f "/usr/bin/mysql" ]; then
        ln  -s  /usr/local/mysql/bin/mysql  /usr/bin
    fi
    if [ ! -f "/usr/bin/mysqldump" ]; then
        ln   -s  /usr/local/mysql/bin/mysqldump  /usr/bin
    fi
}

restart_mysql(){
    systemctl restart mysqld
}

init_user
init_code
install_mysql
conf_my_cnf
create_start
start_mysql
link_mysql
restart_mysql


