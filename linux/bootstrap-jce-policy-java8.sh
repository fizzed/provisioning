#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# download cache
DOWNLOAD_DIR=".download-cache"
if [ -d "/vagrant" ]; then
  DOWNLOAD_DIR="/vagrant/.download-cache"
fi
mkdir -p "$DOWNLOAD_DIR"

# sudo apt-get -y install unzip

echo "Download Java8 JCE unlimited strength policy files..."
curl -o $DOWNLOAD_DIR/jce_policy-8.zip -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip

cd $DOWNLOAD_DIR
# unzip jce_policy-8.zip
/usr/lib/jvm/current/bin/jar xvf jce_policy-8.zip
cp UnlimitedJCEPolicyJDK8/*.jar /usr/lib/jvm/current/jre/lib/security/
