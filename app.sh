#!/bin/bash

if [ -z ${webroot} ]; then
    Echo_Red 'webroot path is empty!'
    exit 0
fi

if [ -z ${redisPort} ]; then
     Echo_Red 'redis Port path is empty!'
    exit 0
fi

if [ -z ${mysqlPassword} ]; then
    Echo_Red 'mysql Password path is empty!'
    exit 0
fi

if [ -z ${source_dir} ]; then
    Echo_Red 'source_dir is empty!'
    exit 0
fi



#  tar -zcvf ${appName}.tar.gz ${appName}/*  将${appName}文件夹压缩打包
tar_code(){
    cd ${source_dir}/code
    tar -zxvf ${appName}.tar.gz
    if [ ! -d ${webroot} ]; then
        mkdir ${webroot}
    fi
    \cp ${source_dir}/code/${appName}/* ${webroot} -rf
}

update_config(){
    sed -i "s/'app_debug' => true/'app_debug' => false/g" ${webroot}config/config.php
    sed -i "s/'port' => 6380/'port' => ${redisPort}/g" ${webroot}config/config.php

    sed -i "s/'debug'           => true/'debug'           => false/g" ${webroot}config/database.php
    sed -i "s/'password'        => '123456'/'password'        => ${mysqlPassword}/g" ${webroot}config/database.php

   
    chown -R www:www ${webroot}
    chown -R www:www ${webroot}*

}

tar_code
update_config



