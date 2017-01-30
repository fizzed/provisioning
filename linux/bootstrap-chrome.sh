#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# download cache
DOWNLOAD_DIR=".download-cache"
if [ -d "/vagrant" ]; then
  DOWNLOAD_DIR="/vagrant/.download-cache"
fi
mkdir -p "$DOWNLOAD_DIR"

echo "Download the latest chrome..."
wget --no-verbose -nc -P $DOWNLOAD_DIR "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
dpkg -i $DOWNLOAD_DIR/google-chrome-stable_current_amd64.deb
apt-get install -y -f

