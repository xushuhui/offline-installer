#!/bin/bash


init_environment(){
    yum -y install zlib zlib-devel
    yum -y install bzip2 bzip2-devel
    yum -y install ncurses ncurses-devel
    yum -y install readline readline-devel
    yum -y install openssl openssl-devel
    yum -y install openssl-static
    yum -y install xz lzma xz-devel
    yum -y install sqlite sqlite-devel
    yum -y install gdbm gdbm-devel
    yum -y install tk tk-devel
    yum -y install libffi libffi-devel
}
init_python(){
    cd ${source_dir}/lib
    tar -zxvf ${pythonTarName}.tgz
    \cp ${pythonTarName} /usr/local/${pythonTarName} -rf
    cd /usr/local/${pythonTarName}
    ./configure --prefix=/usr/python --enable-shared CFLAGS=-fPIC --enable-optimizations
    make
    make install
}

link_python(){
    mv /usr/bin/python /usr/bin/python.bak
    ln -s /usr/python/bin/python3 /usr/bin/python3
    ln -s /usr/python/bin/pip3 /usr/bin/pip3
    ln -s /usr/bin/python3 /usr/bin/python
    touch /etc/ld.so.conf.d/python3.conf
    echo /usr/local/${pythonTarName} > /etc/ld.so.conf.d/python3.conf
    python -V
}

init_environment
init_python
link_python
