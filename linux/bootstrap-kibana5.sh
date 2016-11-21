#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# download cache
DOWNLOAD_DIR=".download-cache"
if [ -d "/vagrant" ]; then
  DOWNLOAD_DIR="/vagrant/.download-cache"
fi
mkdir -p "$DOWNLOAD_DIR"

# defaults
KB_VERSION="5.0.1"
ARCH="amd64"
PORT=5601
ES_URL="http://localhost:9200" # elasticsearch url
INDEX=""
PLUGINS=""

# arguments
for i in "$@"; do
  case $i in
    --version=*)
      KB_VERSION="${i#*=}"
      ;;
    --arch=*)
      ARCH="${i#*=}"
      ;;
    --port=*)
      PORT="${i#*=}"
      ;;
    --es_url=*)
      ES_URL="${i#*=}"
      ;;
    --index=*)
      INDEX="${i#*=}"
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

echo "Installing kibana $KB_VERSION..."

echo "Downloading kibana..."
wget --no-verbose -nc -P $DOWNLOAD_DIR https://artifacts.elastic.co/downloads/kibana/kibana-$KB_VERSION-$ARCH.deb
dpkg -i $DOWNLOAD_DIR/kibana-$KB_VERSION-$ARCH.deb

ES_URL_ESC=$(echo $ES_URL |sed -e 's/[\/&]/\\&/g')
sed -i "s/^.*server\.port.*$/server.port: $PORT/" /etc/kibana/kibana.yml
sed -i "s/^.*elasticsearch\.url.*$/elasticsearch.url: $ES_URL_ESC/" /etc/kibana/kibana.yml

# run at startup
chmod +x /etc/init.d/kibana
update-rc.d kibana defaults 94 11

# install plugins
if [ ! -z "$PLUGINS" ]; then
    for i in ${PLUGINS//,/ }
    do
	echo "Installing Kibana plugin $i"
	cd /usr/share/kibana
	bin/kibana-plugin install $i
    done
fi

# run now
service kibana restart

# install default index
while true;
do
    echo "Waiting for Elasticsearch to start..."
    curl -s -X GET $ES_URL
    if [ $? -eq "0" ]; then
        echo "Elasticsearch started!"
	if [ ! -z "$INDEX" ]; then
	    echo "Installing default index pattern $INDEX"
	    # set the default index
	    #  >= v5 https://github.com/elastic/kibana/issues/5199
	    #  <  v5 https://discuss.elastic.co/t/kibana-4-unattended-configuration-of-default-index-pattern/1737/3
	    curl -XPUT $ES_URL/.kibana/index-pattern/$INDEX -d "{\"title\" : \"$INDEX\", \"timeFieldName\" : \"@timestamp\"}"
	    curl -XPUT $ES_URL/.kibana/config/$KB_VERSION -d "{\"defaultIndex\" : \"$INDEX\"}"
	fi
        break
    fi
    sleep 1s
done

echo "Installed kibana $KB_VERSION"
