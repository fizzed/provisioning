#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# defaults
ES_VERSION="2.3.2"

# arguments
for i in "$@"; do
  case $i in
    --version=*)
      ES_VERSION="${i#*=}"
      ;;
    *)
      echo "Unknown argument '$i'"
      exit 1  
      ;;
  esac
done

echo "Installing elasticsearch $ES_VERSION..."

echo "Downloading elasticsearch..."
wget --no-verbose https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/$ES_VERSION/elasticsearch-$ES_VERSION.deb
dpkg -i elasticsearch-$ES_VERSION.deb

echo "Installed elasticsearch $ES_VERSION"