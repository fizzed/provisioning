#!/bin/sh

##############################################
# Install script for Apache Maven
#  for debian, ubuntu, and centos
#
# Usage:
#  arg0: "maven_version_number"
#  config.vm.provision "shell", path: "linux/bootstrap-maven.sh", args: "3.6.3"
#
##############################################

# download cache
DOWNLOAD_DIR=".download-cache"
if [ -d "/vagrant" ]; then
  DOWNLOAD_DIR="/vagrant/.download-cache"
fi
mkdir -p "$DOWNLOAD_DIR"

# defaults
MAVEN_VERSION="3.8.1"

# arguments
for i in "$@"; do
  case $i in
    --version=*)
      MAVEN_VERSION="${i#*=}"
      ;;
    *)
      echo "Unknown argument '$i'"
      exit 1  
      ;;
  esac
done

echo "Installing Maven $MAVEN_VERSION..."

echo "Downloading Maven..."
wget --no-verbose -nc -P $DOWNLOAD_DIR "http://apache.spinellicreations.com/maven/maven-3/3.6.3/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz"

tar zxvf $DOWNLOAD_DIR/apache-maven-$MAVEN_VERSION-bin.tar.gz
mv apache-maven-$MAVEN_VERSION $MAVEN_VERSION
mkdir --parents /opt/maven
mv $MAVEN_VERSION /opt/maven/
ln -s /opt/maven/$MAVEN_VERSION /opt/maven/current

# add to profile.d
if [ -d /etc/profile.d ]; then
  # always overwrite
  echo "if [ -z \"\$MAVEN_HOME\" ]; then MAVEN_HOME=/opt/maven/current; export MAVEN_HOME; fi" > /etc/profile.d/maven.sh    
  echo "if ! [[ \$PATH == *\"\$MAVEN_HOME\"* ]]; then PATH=\"\$MAVEN_HOME/bin:\$PATH\"; export PATH; fi" >> /etc/profile.d/maven.sh
fi

echo "Installed Maven $MAVEN_VERSION!"
