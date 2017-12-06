#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# download cache
DOWNLOAD_DIR=".download-cache"
if [ -d "/vagrant" ]; then
  DOWNLOAD_DIR="/vagrant/.download-cache"
fi
mkdir -p "$DOWNLOAD_DIR"

# defaults
ACCESS_KEY=minio
ACCESS_SECRET=changeme
PORT=8999
EXPORT_DIR=/home/vagrant/minio

# arguments
for i in "$@"; do
  case $i in
    --access-key=*)
      ACCESS_KEY="${i#*=}"
      ;;
    --access-secret=*)
      ACCESS_SECRET="${i#*=}"
      ;;
    --port=*)
      PORT="${i#*=}"
      ;;
    --export-dir=*)
      EXPORT_DIR="${i#*=}"
      ;;
    *)
      echo "Unknown argument '$i'"
      exit 1  
      ;;
  esac
done

echo "Installing minio..."

echo "Downloading minio..."
wget --no-verbose -nc -P $DOWNLOAD_DIR https://dl.minio.io/server/minio/release/linux-amd64/minio
cp $DOWNLOAD_DIR/minio /usr/local/bin
chmod +x /usr/local/bin/minio

mkdir -p $EXPORT_DIR

cat <<EOM >/usr/local/bin/minio-boot.sh
MINIO_ACCESS_KEY="$ACCESS_KEY" MINIO_SECRET_KEY="$ACCESS_SECRET" minio server --address 0.0.0.0:$PORT $EXPORT_DIR
EOM

chmod +x /usr/local/bin/minio-boot.sh

# add to /etc/rc.local
sed -i -e '$i \sudo /usr/local/bin/minio-boot.sh &\n' /etc/rc.local

# run it now
/usr/local/bin/minio-boot.sh >/dev/null 2>&1 &

echo "Installed minio"
