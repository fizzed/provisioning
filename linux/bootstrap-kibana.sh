#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# defaults
KB_VERSION="4.5.3"
ARCH="amd64"
PORT=5601
ES_URL="http://localhost:9200" # elasticsearch url
INDEX=""

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
    *)
      echo "Unknown argument '$i'"
      exit 1  
      ;;
  esac
done

echo "Installing kibana $KB_VERSION..."

echo "Downloading kibana..."
wget --no-verbose https://download.elastic.co/kibana/kibana/kibana_$KB_VERSION\_$ARCH.deb
dpkg -i kibana_$KB_VERSION\_$ARCH.deb

echo "server.port: "$PORT >> /opt/kibana/config/kibana.yml
echo "elasticsearch.url: \""$ES_URL"\"" >> /opt/kibana/config/kibana.yml

# run at startup
chmod +x /etc/init.d/kibana
update-rc.d kibana defaults 94 11

# run now
service kibana restart

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
