#!/bin/bash

create_nginx_user(){
    pkill nginx
    writeLog 'create_nginx_user'
    groupadd nginx
    useradd -g nginx nginx -s /bin/false
    mkdir   /usr/local/nginx
}

init_nginx_code(){
    cd  $source_dir/lib/
    writeLog 'tar nginx'
    tar  -zxvf  ${nginxTarName}.tar.gz
    cd  $source_dir/lib/${nginxTarName}/
}

init_nginx_export(){
    yum -y install pcre-devel openssl openssl-devel gcc-c++ gcc
    yum -y groupinstall “Development Tools”
    yum  -y  install  libaio
    writeLog 'configure make'
    ./configure --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module
    make
    make  install
}

conf_nginx(){

    cd /usr/local/nginx/conf
    cp nginx.conf nginx.conf.bk
    writeLog 'write conf'
    cat > /usr/local/nginx/conf/nginx.conf <<EOF

worker_processes  auto;
worker_rlimit_nofile 51200;

events {
	    use epoll;
        worker_connections 51200;
        multi_accept on;
}

http {
	    include       mime.types;
        default_type  application/octet-stream;

        server_names_hash_bucket_size 128;
        client_header_buffer_size 32k;
        large_client_header_buffers 4 32k;
        client_max_body_size 50m;

        sendfile   on;
        tcp_nopush on;

        keepalive_timeout 60;

        tcp_nodelay on;

        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
        fastcgi_buffer_size 64k;
        fastcgi_buffers 4 64k;
        fastcgi_busy_buffers_size 128k;
        fastcgi_temp_file_write_size 256k;

        gzip on;
        gzip_min_length  1k;
        gzip_buffers     4 16k;
        gzip_http_version 1.1;
        gzip_comp_level 2;
        gzip_types     text/plain application/javascript application/x-javascript text/javascript text/css application/xml application/xml+rss;
        gzip_vary on;
        gzip_proxied   expired no-cache no-store private auth;
        gzip_disable   "MSIE [1-6]\.";
        #gzip_disable "MSIE [1-6]\.(?!.*SV1)";
        #gzip_disable msie6;

        #limit_conn_zone \$binary_remote_addr zone=perip:10m;
        ##If enable limit_conn_zone,add "limit_conn perip 10;" to server section.

        server_tokens off;
        access_log on;

    include vhost/*.conf;

}
EOF
    ln -s /usr/local/nginx/sbin/* /usr/local/bin/
}

conf_port(){
    if [ ! -d "/usr/local/nginx/conf/vhost" ]; then
        mkdir /usr/local/nginx/conf/vhost
    fi

    if [ ! -f "/usr/local/nginx/conf/vhost/${nginxPort}.conf" ]; then
        touch /usr/local/nginx/conf/vhost/${nginxPort}.conf
    fi
    cat > /usr/local/nginx/conf/vhost/${nginxPort}.conf <<EOF

 server {
     listen       ${nginxPort};
     server_name  localhost;

     #ssl_certificate      /usr/local/ssl/nginx.crt;
     #ssl_certificate_key  /usr/local/ssl/nginx.key;

     #ssl_session_cache    shared:SSL:1m;
     #ssl_session_timeout  5m;

     #ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
     #ssl_ciphers HIGH:!aNULL:!eNULL:!SSLv2:!SSLv3;

     #ssl_prefer_server_ciphers  on;

     #server_tokens off;

     #root /usr/local/nginx/html/ids_web/public;
     root ${webroot}public;

     location / {
         root   html;
         index  index.html index.htm;
     }

     error_page   500 502 503 504  /50x.html;
     location = /50x.html {
         root   html;
     }

    location ~* \.(htaccess|sql)\$ {
         deny all;
     }

     location ^~ /sql {
             deny all;
     }

    location ^~ /t {
             deny all;
     }

#	location ^~ /inner_socket {
#                deny all;
#        }

    location ^~ /upload {
             deny all;
     }

    location ^~ /site {
             deny all;
     }

    location ~ \.php\$ {
         fastcgi_pass   127.0.0.1:9000;
         #fastcgi_index  index.php;
         # fastcgi_param  SCRIPT_FILENAME  /scripts\$fastcgi_script_name;
         include fastcgi.conf;
         fastcgi_param PHP_ADMIN_VALUE "open_basedir=\$document_root/../:/tmp/:/proc/";
    }

    location ~ / {
        index index.html index.htm index.php;
        if (!-e \$request_filename) {
            rewrite ^/index.php(.*)\$ /index.php?s=\$1 last;
            rewrite ^(.*)\$ /index.php?s=\$1 last;
            break;
        }
    }

}

EOF

}

conf_ssl(){
    if [ ! -d "/usr/local/ssl" ]; then
        mkdir /usr/local/ssl
    fi
    openssl req -x509 -nodes -days 36500 -newkey rsa:2048 -keyout /usr/local/ssl/nginx.key -out /usr/local/ssl/nginx.crt
}

start_nginx(){
    pkill nginx
    /usr/local/nginx/sbin/nginx
}


create_nginx_user
init_nginx_code
init_nginx_export
conf_nginx
conf_port
#conf_ssl
start_nginx
