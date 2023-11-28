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

# defaults
CACHE="no"
MAVEN_VERSION="3.9.5"

# arguments
for i in "$@"; do
  case $i in
    --cache)
      CACHE="yes"
      ;;
    --version=*)
      MAVEN_VERSION="${i#*=}"
      ;;
    *)
      echo "Unknown argument '$i'"
      exit 1
      ;;
  esac
done

DOWNLOAD_DIR=.
if [ "$CACHE" = "yes" ]; then
  # download cache
  DOWNLOAD_DIR=".download-cache"
  if [ -d "/vagrant" ]; then
    DOWNLOAD_DIR="/vagrant/.download-cache"
  fi
  mkdir -p "$DOWNLOAD_DIR"
fi

echo "Installing Maven $MAVEN_VERSION..."

echo "Downloading Maven..."
# https://dlcdn.apache.org/maven/maven-3/3.8.7/binaries/apache-maven-3.8.7-bin.tar.gz
# https://archive.apache.org/dist/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.zip
wget --no-check-certificate -nc -P $DOWNLOAD_DIR "https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"

tar zxvf $DOWNLOAD_DIR/apache-maven-$MAVEN_VERSION-bin.tar.gz

if [ "$CACHE" = "no" ]; then
  rm -f $DOWNLOAD_DIR/apache-maven-$MAVEN_VERSION-bin.tar.gz
fi

mv apache-maven-$MAVEN_VERSION $MAVEN_VERSION
mkdir --parents /opt/maven
rm -Rf /opt/maven/$MAVEN_VERSION
mv $MAVEN_VERSION /opt/maven/
rm -Rf /opt/maven/current
ln -s /opt/maven/$MAVEN_VERSION /opt/maven/current

# add to profile.d
if [ -d /etc/profile.d ]; then
  # always overwrite
  echo "if [ -z \"\$M2_HOME\" ]; then M2_HOME=/opt/maven/current; export M2_HOME; fi" > /etc/profile.d/maven.sh
  #echo "if ! [[ \$PATH == *\"\$MAVEN_HOME\"* ]]; then PATH=\"\$MAVEN_HOME/bin:\$PATH\"; export PATH; fi" >> /etc/profile.d/maven.sh
  echo 'if [ ! -z "${PATH##*$M2_HOME*}" ]; then PATH="$M2_HOME/bin:$PATH"; export PATH; fi' >> /etc/profile.d/maven.sh
fi

echo "Installed Maven $MAVEN_VERSION!"
