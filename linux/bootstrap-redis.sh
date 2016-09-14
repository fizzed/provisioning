#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# download cache
DOWNLOAD_DIR=".download-cache"
if [ -d "/vagrant" ]; then
  DOWNLOAD_DIR="/vagrant/.download-cache"
fi
mkdir -p "$DOWNLOAD_DIR"

# defaults
VERSION="3.2.3"
HOST=0.0.0.0
PORT=
PASSWORD=

# arguments
for i in "$@"; do
  case $i in
    --version=*)
      VERSION="${i#*=}"
      ;;
    --host=*)
      HOST="${i#*=}"
      ;;
    --port=*)
      PORT="${i#*=}"
      ;;
    --password=*)
      PASSWORD="${i#*=}"
      ;;
    *)
      echo "Unknown argument '$i'"
      exit 1  
      ;;
  esac
done

echo "Installing redis $VERSION..."

echo "Downloading redis source..."
# https://github.com/digitalocean/do_user_scripts/blob/master/Ubuntu-14.04/no-sql/redis.yml
wget --no-verbose -nc -P $DOWNLOAD_DIR http://download.redis.io/releases/redis-$VERSION.tar.gz
tar zxvf $DOWNLOAD_DIR/redis-$VERSION.tar.gz
cd redis-$VERSION
make
make install
echo -n | utils/install_server.sh

# See: http://redis.io/topics/faq
sysctl vm.overcommit_memory=1

service redis_6379 stop

# /etc/redis/6379.conf by default
REDIS_CONFIG=/etc/redis/6379.conf

# bind to a different default port?
if [ ! -z "$PORT" ]; then
  sed -i "s/port 6379/port $PORT/g" $REDIS_CONFIG
  sed -i "s/REDISPORT=\".*\"/REDISPORT=\"$PORT\"/g" /etc/init.d/redis_6379
  echo "Configured redis to use port $PORT"
fi

# bind to any port (not just default of localhost)
if [ ! -z "$HOST" ]; then
  sed -i "s/bind 127.0.0.1/bind $HOST/g" $REDIS_CONFIG
  echo "Configured redis to bind to $HOST"
fi

# set an auth password?
if [ ! -z "$PASSWORD" ]; then
  sed -i "s/^# requirepass.*/requirepass $PASSWORD/g" $REDIS_CONFIG
  echo "Configured redis with auth password $PASSWORD"
fi

service redis_6379 start

echo "Installed redis $VERSION"

