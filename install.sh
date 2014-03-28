#!/bin/bash
#
# jmeter-ec2 - Install Script (Runs on remote ec2 server)
#

# Source the jmeter-ec2.properties file, establishing these constants.
. /tmp/jmeter-ec2.properties

REMOTE_HOME=$1
INSTALL_JAVA=$2
JMETER_VERSION=$3
GROOVY_VER=2.2.2

function install_groovy() {
    wget -q -O groovy.zip http://dl.bintray.com/groovy/maven/groovy-binary-$GROOVY_VER.zip
    unzip $REMOTE_HOME/groovy.zip $REMOTE_HOME/$JMETER_VERSION/lib/ext/    
}

function install_jmeter_plugins() {
    wget -q -O $REMOTE_HOME/JMeterPlugins.jar https://s3.amazonaws.com/jmeter-ec2/JMeterPlugins.jar
    mv $REMOTE_HOME/JMeterPlugins.jar $REMOTE_HOME/$JMETER_VERSION/lib/ext/
}

function install_mysql_driver() {
    wget -q -O $REMOTE_HOME/mysql-connector-java-5.1.16-bin.jar https://s3.amazonaws.com/jmeter-ec2/mysql-connector-java-5.1.16-bin.jar
    mv $REMOTE_HOME/mysql-connector-java-5.1.16-bin.jar $REMOTE_HOME/$JMETER_VERSION/lib/
}

cd $REMOTE_HOME

if [ $INSTALL_JAVA -eq 1 ] ; then
    # install java
	
	#ubuntu
	sudo apt-get update #update apt-get
	sudo DEBIAN_FRONTEND=noninteractive apt-get -qqy install default-jre
	wait

#    bits=`getconf LONG_BIT`
#    if [ $bits -eq 32 ] ; then
#        wget -q -O $REMOTE_HOME/jre-6u30-linux-i586-rpm.bin https://s3.amazonaws.com/jmeter-ec2/jre-6u30-linux-i586-rpm.bin
#        chmod 755 $REMOTE_HOME/jre-6u30-linux-i586-rpm.bin
#        $REMOTE_HOME/jre-6u30-linux-i586-rpm.bin
#    else # 64 bit
#        wget -q -O $REMOTE_HOME/jre-6u30-linux-x64-rpm.bin https://s3.amazonaws.com/jmeter-ec2/jre-6u30-linux-i586-rpm.bin
#        chmod 755 $REMOTE_HOME/jre-6u30-linux-x64-rpm.bin
#        $REMOTE_HOME/jre-6u30-linux-x64-rpm.bin
#    fi

fi

# install jmeter
case "$JMETER_VERSION" in

jakarta-jmeter-2.5.1)
    # JMeter version 2.5.1
    wget -q -O $REMOTE_HOME/$JMETER_VERSION.tgz http://archive.apache.org/dist/jmeter/binaries/$JMETER_VERSION.tgz
    tar -xf $REMOTE_HOME/$JMETER_VERSION.tgz
    # install jmeter-plugins [http://code.google.com/p/jmeter-plugins/]
    install_jmeter_plugins
    # install mysql jdbc driver
	install_mysql_driver
    install_groovy
    ;;

apache-jmeter-*)
    # JMeter version 2.x
    wget -q -O $REMOTE_HOME/$JMETER_VERSION.tgz http://archive.apache.org/dist/jmeter/binaries/$JMETER_VERSION.tgz
    tar -xf $REMOTE_HOME/$JMETER_VERSION.tgz
    # install jmeter-plugins [http://code.google.com/p/jmeter-plugins/]
    install_jmeter_plugins
    # install mysql jdbc driver
	install_mysql_driver
    install_groovy
    ;;
    
*)
    echo "Please check the value of JMETER_VERSION in the properties file, $JMETER_VERSION is not recognised."
esac

echo "software installed"
