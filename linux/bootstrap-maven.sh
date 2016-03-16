#!/bin/sh

##############################################
# Install script for Apache Maven
#  for debian, ubuntu, and centos
#
# Usage:
#  arg0: "maven_version_number"
#  config.vm.provision "shell", path: "linux/bootstrap-maven.sh", args: "3.3.9"
#
##############################################

MAVEN_VERSION="$1"
if [ -z "$MAVEN_VERSION" ]; then MAVEN_VERSION="3.3.9"; fi

echo "Installing Maven $MAVEN_VERSION..."

curl -O "http://apache.spinellicreations.com/maven/maven-3/3.3.9/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz"
tar zxvf apache-maven-$MAVEN_VERSION-bin.tar.gz
mkdir --parents /opt/maven
mv apache-maven-$MAVEN_VERSION /opt/maven/$MAVEN_VERSION
ln -s /opt/maven/$MAVEN_VERSION /opt/maven/current

# add to profile.d
if [ -d /etc/profile.d ]; then
  # always overwrite
  echo "if [ -z \"\$MAVEN_HOME\" ]; then MAVEN_HOME=/opt/maven/current; export MAVEN_HOME; fi" > /etc/profile.d/maven.sh    
  echo "if ! [[ \$PATH == *\"\$MAVEN_HOME\"* ]]; then PATH=\"\$MAVEN_HOME/bin:\$PATH\"; export PATH; fi" >> /etc/profile.d/maven.sh
fi

echo "Installed Maven $MAVEN_VERSION!"
