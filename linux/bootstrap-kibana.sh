#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# defaults
KB_VERSION="4.5.3"
JAVA_HOME=/usr/lib/jvm/current
ARCH="amd64"

# arguments
for i in "$@"; do
  case $i in
    --version=*)
      KB_VERSION="${i#*=}"
      ;;
    --javahome=*)
      JAVA_HOME="${i#*=}"
      ;;
    --arch=*)
      ARCH="${i#*=}"
      ;;
    *)
      echo "Unknown argument '$i'"
      exit 1  
      ;;
  esac
done

echo "Installing kibana $KB_VERSION..."

echo "Downloading kibana..."
# https://download.elastic.co/kibana/kibana/kibana_4.5.3_amd64.deb
wget --no-verbose https://download.elastic.co/kibana/kibana/kibana_$KB_VERSION\_$ARCH.deb
dpkg -i kibana_$KB_VERSION\_$ARCH.deb

# tell kibana where java_home is
echo "Configuring kibana to search $JAVA_HOME for java"
echo "JAVA_HOME=\"$JAVA_HOME\"" >> /etc/default/kibana

service kibana restart

echo "Installed kibana $KB_VERSION"
