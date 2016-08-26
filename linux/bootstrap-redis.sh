#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# defaults
VERSION="3.2.3"
HOST=0.0.0.0
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
wget http://download.redis.io/releases/redis-$VERSION.tar.gz
tar zxvf redis-$VERSION.tar.gz
cd redis-$VERSION
make
make install
echo -n | utils/install_server.sh

# See: http://redis.io/topics/faq
sysctl vm.overcommit_memory=1

# bind to any port (not just default of localhost)
if [ ! -z "$HOST" ]; then
  sed -i "s/bind 127.0.0.1/bind $HOST/g" /etc/redis/6379.conf
  echo "Configured redis to bind to $HOST"
fi

# set an auth password?
if [ ! -z "$PASSWORD" ]; then
  sed -i "s/^# requirepass.*/requirepass $PASSWORD/g" /etc/redis/6379.conf
  echo "Configured redis with auth password $PASSWORD"
fi

service redis_6379 restart

echo "Installed redis $VERSION"

