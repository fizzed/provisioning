#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# download cache
DOWNLOAD_DIR=".download-cache"
if [ -d "/vagrant" ]; then
  DOWNLOAD_DIR="/vagrant/.download-cache"
fi
mkdir -p "$DOWNLOAD_DIR"

# defaults
ES_VERSION="5.0.1"
ES_HEAP_SIZE="128m"
JAVA_HOME=/usr/lib/jvm/current
PORT=9200
PLUGINS=""

# arguments
for i in "$@"; do
  case $i in
    --version=*)
      ES_VERSION="${i#*=}"
      ;;
    --javahome=*)
      JAVA_HOME="${i#*=}"
      ;;
    --port=*)
      PORT="${i#*=}"
      ;;
    --heapsize=*)
      ES_HEAP_SIZE="${i#*=}"
      ;;
    --plugins=*)
      PLUGINS="${i#*=}"
      ;;
    *)
      echo "Unknown argument '$i'"
      exit 1  
      ;;
  esac
done

echo "Installing elasticsearch $ES_VERSION..."

echo "Downloading elasticsearch..."
wget --no-verbose -nc -P $DOWNLOAD_DIR https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ES_VERSION.deb
dpkg -i $DOWNLOAD_DIR/elasticsearch-$ES_VERSION.deb

# elastic has awful java detection - tell it where java_home is
echo "Configuring elasticsearch to search $JAVA_HOME for java"
echo "JAVA_HOME=\"$JAVA_HOME\"" >> /etc/default/elasticsearch

# default heap size is large for dev
echo "ES_HEAP_SIZE=\"$ES_HEAP_SIZE\"" >> /etc/default/elasticsearch

# port forwards only work to a real ip, not localhost
echo "Configuring elasticsearch to bind to all network interfaces (not just localhost by default)"
sed -i "s/^.*network\.host.*$/network.host: 0.0.0.0/" /etc/elasticsearch/elasticsearch.yml
sed -i "s/^.*http\.port.*$/http.port: $PORT/" /etc/elasticsearch/elasticsearch.yml

# run at startup
chmod +x /etc/init.d/elasticsearch
update-rc.d elasticsearch defaults 95 10

# run now
service elasticsearch restart

# install plugins
if [ ! -z "$PLUGINS" ]; then
    for i in ${PLUGINS//,/ }
    do
	echo "Installing Elastic plugin $i"
	cd /usr/share/elasticsearch
	bin/elasticsearch-plugin install $i
    done
fi

echo "###########################################################"
echo ""
echo " Installed elasticsearch $ES_VERSION"
echo ""
echo "###########################################################"
