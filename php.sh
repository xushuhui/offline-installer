#!/bin/bash

init_php_user(){
    pkill php
    if [ ! -d "/usr/local/php" ]; then
        mkdir   /usr/local/php
    fi

    cd   /usr/local/php
    groupadd -r  www   && useradd -r -g www  -s /bin/false -d /usr/local/php -M www

}

init_php_export(){
    yum -y install libxml2 libxml2-devel openssl openssl-devel curl-devel bzip2-devel libjpeg-devel libpng-devel libmcrypt-devel fretype freetype-devel epel-release libmcrypt-devel expat-devel perl perl-devel apr-devel apr-util-devel httpd-devel autoconf
}

init_php_code(){
    if [ ! -f "$source_dir/lib/${phpTarName}.tar.gz" ];then
        echo "not found $source_dir/lib/${phpTarName}.tar.gz"
        exit 0
    fi
    cd $source_dir/lib/
    tar -zxvf ${phpTarName}.tar.gz
    cd ${phpTarName}
    ./buildconf --force
    ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-zlib --with-libxml-dir --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring  --with-libmbfl --enable-ftp --with-gd  --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache

    make && make install
}



init_php_conf(){
    cd $source_dir/lib/${phpTarName}
    cp php.ini-production /usr/local/php/etc/php.ini
    cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
    cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
    cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf

    # update /etc/init.d/php-fpm
    sed -i 's/php_fpm_PID\=\${prefix}\/var\/run\/php-fpm.pid/php_fpm_PID\=\/var\/run\/php-fpm.pid/g' /etc/init.d/php-fpm

    # update  /usr/local/php/etc/php-fpm.conf
    sed -i 's/\;pid \= run\/php-fpm.pid/pid \= \/var\/run\/php-fpm.pid/g' /usr/local/php/etc/php-fpm.conf
    sed -i 's/\;error_log \= log\/php-fpm.log/error_log \= \/var\/log\/php-fpm\/error.log/g' /usr/local/php/etc/php-fpm.conf
    sed -i 's/include\=NONE\/etc\/php-fpm.d\/\*.conf/include\=\/usr\/local\/etc\/php-fpm.d\/*.conf/g' /usr/local/php/etc/php-fpm.conf

    # update /usr/local/php/etc/php.ini
    # 替换字符串
    sed -i 's/\;expose_php \= On/expose_php \= Off/g' /usr/local/php/etc/php.ini
    sed -i 's/\;date.timezone \=/date.timezone \= PRC/g' /usr/local/php/etc/php.ini
    # 追加
    php_extensions=$(ls -l /usr/local/php/lib/php/extensions/ |awk '/^d/ {print $NF}')

    grep 'extension_dir = "/usr/local/php/lib/php/extensions' /usr/local/php/etc/php.ini > /dev/null
    if [ $? -eq 1 ]; then
        echo "extension_dir = \"/usr/local/php/lib/php/extensions/${php_extensions}\"" >> /usr/local/php/etc/php.ini
    fi

    # 替换行
    sed -i 's#^upload_max_filesize =.*#upload_max_filesize = 100M#g'  /usr/local/php/etc/php.ini
    sed -i 's#^post_max_size =.*#post_max_size = 100M#g'  /usr/local/php/etc/php.ini
    sed -i 's#^max_file_uploads =.*#max_file_uploads = 100#g'  /usr/local/php/etc/php.ini
    sed -i 's#^disable_functions =.*#disable_functions =#g' /usr/local/php/etc/php.ini
    ln -s /usr/local/php/bin/* /usr/local/bin/
}

init_php_rights(){
    if [ ! -d "/var/log/php-fpm/" ]; then
        mkdir -p /var/log/php-fpm/
    fi
    if [ ! -d "/var/lib/php/session" ];then
        mkdir -p /var/lib/php/session
    fi
    chown -R www:www /var/lib/php

    chmod +x /etc/init.d/php-fpm
    chkconfig --add php-fpm
    chkconfig --level 3 php-fpm on
    chkconfig php-fpm on
}

install_ext_pcntl(){
    if [ -d "${source_dir}/lib/${phpTarName}/ext/pcntl" ]; then
        cd ${source_dir}/lib/${phpTarName}/ext/pcntl
        echo ${source_dir}/lib/${phpTarName}/ext/pcntl;
        /usr/local/php/bin/phpize
        ./configure  --with-php-config=/usr/local/php/bin/php-config
        make
        make install

        grep 'extension="pcntl.so"' /usr/local/php/etc/php.ini > /dev/null
        if [ $? -eq 1 ]; then
            echo 'extension="pcntl.so"' >> /usr/local/php/etc/php.ini
        fi

    fi
}

install_ext_openssl(){
    if [ -d "${source_dir}/lib/${phpTarName}/ext/openssl" ]; then
        cd ${source_dir}/lib/${phpTarName}/ext/openssl
        if [ ! -f "config.m4" ]; then
            cp config0.m4 config.m4
        fi
        /usr/local/php/bin/phpize
        ./configure  --with-php-config=/usr/local/php/bin/php-config
        make
        make install
        grep 'extension="openssl.so"' /usr/local/php/etc/php.ini > /dev/null
        if [ $? -eq 1 ]; then
            echo 'extension="openssl.so"' >> /usr/local/php/etc/php.ini
        fi

    fi
}

install_ext_curl(){
    if [ -d "${source_dir}/lib/${phpTarName}/ext/curl" ]; then
        cd ${source_dir}/lib/${phpTarName}/ext/curl
        /usr/local/php/bin/phpize
        ./configure  --with-php-config=/usr/local/php/bin/php-config
        make
        make install
        grep 'extension="curl.so"' /usr/local/php/etc/php.ini > /dev/null
        if [ $? -eq 1 ]; then
            echo 'extension="curl.so"' >> /usr/local/php/etc/php.ini
        fi

    fi
}




install_ext_redis(){
    if [ ! -f "$source_dir/lib/phpredis-4.1.0RC3.tar.gz" ]; then
        echo "not found $source_dir/phpredis-4.1.0RC3.tar.gz"
        exit 0
    fi
    cd $source_dir/lib
    tar  -zxvf  phpredis-4.1.0RC3.tar.gz
    if [ ! -d "/usr/local/php/ext/redis" ]; then
        mkdir -p /usr/local/php/ext/redis
    fi
    \cp $source_dir/lib/phpredis-4.1.0RC3/* /usr/local/php/ext/redis -rf
    cd /usr/local/php/ext/redis

    /usr/local/php/bin/phpize
    ./configure  --with-php-config=/usr/local/php/bin/php-config

    make
    make  install

    grep 'extension="redis.so"' /usr/local/php/etc/php.ini > /dev/null
    if [ $? -eq 1 ]; then
        echo 'extension="redis.so"' >> /usr/local/php/etc/php.ini
    fi

}
install_ext_tonyenc(){
    if [ ! -f "$source_dir/lib/tonyenc.tar.gz" ]; then
        echo "not found $source_dir/tonyenc.tar.gz"
        exit 0
    fi
    cd $source_dir/lib
    tar  -zxvf  tonyenc.tar.gz
    if [ ! -d "/usr/local/php/ext/tonyenc" ]; then
        mkdir -p /usr/local/php/ext/tonyenc
    fi
    \cp $source_dir/lib/tonyenc/* /usr/local/php/ext/tonyenc -rf
    cd /usr/local/php/ext/tonyenc

    /usr/local/php/bin/phpize
    ./configure  --with-php-config=/usr/local/php/bin/php-config

    make
    make  install

    grep 'extension="tonyenc.so"' /usr/local/php/etc/php.ini > /dev/null
    if [ $? -eq 1 ]; then
        echo 'extension="tonyenc.so"' >> /usr/local/php/etc/php.ini
    fi

}
start_php(){
    service php-fpm start
}

restart_php(){
    service php-fpm restart
}

init_php_user
init_php_export
init_php_code
init_php_conf
init_php_rights
start_php



install_ext_tonyenc
#install_ext_redis

restart_php

