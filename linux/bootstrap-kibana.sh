#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# defaults
KB_VERSION="4.5.3"
ARCH="amd64"
PORT=5601
ES_URL="http://localhost:9200" # elasticsearch url

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

echo "server.port: "$PORT >> /opt/kibana/config/kibana.yml
echo "elasticsearch.url: \""$ES_URL"\"" >> /opt/kibana/config/kibana.yml

service kibana restart

echo "Installed kibana $KB_VERSION"
