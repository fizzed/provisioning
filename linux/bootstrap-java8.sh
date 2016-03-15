#!/bin/sh

##############################################
# Install script for Oracle Java 8
#  for debian, ubuntu, and centos
#
# Usage:
#  arg0: "jre", "server-jre", or "jdk" (defaults to server-jre)
#  config.vm.provision "shell", path: "linux/bootstrap-java8.sh", args: "server-jre"
#
##############################################

export DEBIAN_FRONTEND=noninteractive

# jdk, jre, or server-jre
JAVA_TYPE="$1"
if [ -z "$JAVA_TYPE" ]; then JAVA_TYPE="server-jre"; fi

JAVA_VERSION="1.8.0_74"
JAVA_FILE_VERSION="8u74"

# dependencies
if type apt-get &>/dev/null; then
  sudo apt-get update
  sudo apt-get -y install curl
elif type yum &>/dev/null; then
  sudo yum update
  sudo yum -y install curl
fi

echo "Installing $JAVA_TYPE $JAVA_VERSION..."

# download and install java 8 server jre
curl -O -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u74-b02/$JAVA_TYPE-$JAVA_FILE_VERSION-linux-x64.tar.gz
tar zxvf $JAVA_TYPE-$JAVA_FILE_VERSION-linux-x64.tar.gz
mkdir --parents /usr/lib/jvm
mv jdk$JAVA_VERSION /usr/lib/jvm/
ln -s /usr/lib/jvm/jdk$JAVA_VERSION /usr/lib/jvm/current

# does /etc/environment exist?
if [ -f /etc/environment ]; then
  # remove then add java to path in environment
  echo "Adding jvm to /etc/environment"
  sed -e 's|/usr/lib/jvm/current/bin:||g' -i /etc/environment
  sed -e 's|PATH="\(.*\)"|PATH="/usr/lib/jvm/current/bin:\1"|g' -i /etc/environment

  # add java_home to environment
  if ! grep JAVA_HOME /etc/environment > /dev/null; then
    echo "JAVA_HOME=/usr/lib/jvm/current" >> /etc/environment
  fi
fi

# does /etc/profile.d exist? (in case /etc/environment not used)
if [ -d /etc/profile.d ]; then
  if [ ! -f /etc/profile.d/java.sh ]; then
    echo "if [ -z \"\$JAVA_HOME\" ]; then JAVA_HOME=/usr/lib/jvm/current; export JAVA_HOME; fi" > /etc/profile.d/java.sh    
    echo "if ! [[ \$PATH == *\"\$JAVA_HOME\"* ]]; then PATH=\"\$JAVA_HOME/bin:\$PATH\"; export PATH; fi" >> /etc/profile.d/java.sh
  fi
fi

echo "Installed $JAVA_TYPE $JAVA_VERSION"
