#!/bin/bash
 
create_jdk_dir(){

    if [ ! -d "/usr/local/java" ]; then
        mkdir   /usr/local/java
    fi
    Echo_Yellow 'create_jdk_dir'
}
init_jdk_code(){
    if [ ! -f "$source_dir/lib/${jdkTarName}.tar.gz" ];then
        echo "not found $source_dir/lib/${jdkTarName}.tar.gz"
        exit 0
    fi
    cd $source_dir/lib/
    tar -zxvf ${jdkTarName}.tar.gz -C /usr/local/java/


}

init_jdk_environment(){
    echo "export JAVA_HOME=/usr/local/java/${jdkTarName}
export JRE_HOME=\${JAVA_HOME}/jre
export CLASSPATH=.:\${JAVA_HOME}/lib:\${JRE_HOME}/lib
export PATH=\${JAVA_HOME}/bin:\$PATH" >> /etc/profile
    source /etc/profile
}
create_jdk_dir
init_jdk_code
init_jdk_environment