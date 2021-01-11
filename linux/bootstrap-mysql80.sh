#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# we only support ubuntu
. /etc/lsb-release

if [ -z "${DISTRIB_RELEASE}" ]; then
  echo "This script only supports versions of ubuntu..."
  exit 1
fi

# download cache
DOWNLOAD_DIR=".download-cache"
if [ -d "/vagrant" ]; then
  DOWNLOAD_DIR="/vagrant/.download-cache"
fi
mkdir -p "$DOWNLOAD_DIR"

# ${DISTRIB_RELEASE} will be 14.04 or 16.04

# defaults
MYSQL_VERSION="8.0.22"
MYSQL_HOST="0.0.0.0"
MYSQL_PORT="3306"
MYSQL_ROOT_PASSWORD="test"
MYSQL_CREATE_DB=
MYSQL_PERFORMANCE_SCHEMA="off"

# arguments
for i in "$@"; do
  case $i in
    --version=*)
      MYSQL_VERSION="${i#*=}"
      ;;
    --host=*)
      MYSQL_HOST="${i#*=}"
      ;;
    --port=*)
      MYSQL_PORT="${i#*=}"
      ;;
    --rootpw=*)
      MYSQL_ROOT_PASSWORD="${i#*=}"
      ;;
    --createdb=*)
      MYSQL_CREATE_DB="${i#*=}"
      ;;
    --perfschema=*)
      MYSQL_PERFORMANCE_SCHEMA="${i#*=}"
      ;;
    *)
      echo "Unknown argument '$i'"
      exit 1
      ;;
  esac
done

echo "Installing mysql ${MYSQL_VERSION} for Ubuntu ${DISTRIB_RELEASE}..."

apt-get update
apt-get -y install libaio1 libnuma1 apparmor libmecab2 psmisc

# mysql common
# https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-common_8.0.22-1ubuntu20.04_amd64.deb
wget --no-verbose -nc -P $DOWNLOAD_DIR https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-common_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb
dpkg -i $DOWNLOAD_DIR/mysql-common_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb

# mysql client core
echo "Downloading mysql-community-client-plugins..."
wget --no-verbose -nc -P $DOWNLOAD_DIR https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-community-client-plugins_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb
dpkg -i $DOWNLOAD_DIR/mysql-community-client-plugins_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb

# mysql client core
echo "Downloading mysql-community-client-core..."
wget --no-verbose -nc -P $DOWNLOAD_DIR https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-community-client-core_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb
dpkg -i $DOWNLOAD_DIR/mysql-community-client-core_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb

# mysql client
echo "Downloading mysql-community-client..."
wget --no-verbose -nc -P $DOWNLOAD_DIR https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-community-client_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb
dpkg -i $DOWNLOAD_DIR/mysql-community-client_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb

# mysql client #2
echo "Downloading mysql-client..."
wget --no-verbose -nc -P $DOWNLOAD_DIR https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-client_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb
dpkg -i $DOWNLOAD_DIR/mysql-client_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb

# mysql server
echo "Downloading mysql-community-server..."
wget --no-verbose -nc -P $DOWNLOAD_DIR https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-community-server_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb
echo "mysql-community-server  mysql-community-server/re-root-pass     password	$MYSQL_ROOT_PASSWORD" | sudo debconf-set-selections
echo "mysql-community-server  mysql-community-server/root-pass        password	$MYSQL_ROOT_PASSWORD" | sudo debconf-set-selections
echo "mysql-community-server  mysql-community-server/remove-data-dir  boolean true"  | sudo debconf-set-selections
dpkg -i $DOWNLOAD_DIR/mysql-community-server_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb

# mysql server #2
echo "Downloading mysql-server..."
wget --no-verbose -nc -P $DOWNLOAD_DIR https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-server_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb
dpkg -i $DOWNLOAD_DIR/mysql-server_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb

# by default mysql only allows localhost (not via port forward)
echo "DELETE FROM mysql.user WHERE NOT Host = 'localhost'" | mysql -u root -p$MYSQL_ROOT_PASSWORD
echo "UPDATE mysql.user SET Host='%' where Host='localhost'" | mysql -u root -p$MYSQL_ROOT_PASSWORD
echo "GRANT ALL PRIVILEGES ON *.* TO root@localhost" | mysql -u root -p$MYSQL_ROOT_PASSWORD
echo "FLUSH PRIVILEGES" | mysql -u root -p$MYSQL_ROOT_PASSWORD

# old way (5.7.14+ no longer set values in my.cnf)
#sed -i "s/= 127.0.0.1/= $MYSQL_HOST/" /etc/mysql/my.cnf
#sed -i "s/= 3306/= $MYSQL_PORT/" /etc/mysql/my.cnf

# host & port
echo "[client]" > /etc/mysql/conf.d/binding.cnf
echo "port = $MYSQL_PORT" >> /etc/mysql/conf.d/binding.cnf
echo "[mysqld]" >> /etc/mysql/conf.d/binding.cnf
echo "bind-address = $MYSQL_HOST" >> /etc/mysql/conf.d/binding.cnf
echo "port = $MYSQL_PORT" >> /etc/mysql/conf.d/binding.cnf

# disable performance schema?
if [ "$MYSQL_PERFORMANCE_SCHEMA" = "off" ]; then
  echo "[mysqld]" > /etc/mysql/conf.d/perfschema.cnf
  echo "performance_schema = OFF" >> /etc/mysql/conf.d/perfschema.cnf
fi

service mysql restart

# create a database?
if [ ! -z "$MYSQL_CREATE_DB" ]; then
  IFS=","
  for DATABASE in $MYSQL_CREATE_DB
  do
    echo "Creating database $DATABASE..."
    echo "CREATE DATABASE $DATABASE" | mysql -u root -p$MYSQL_ROOT_PASSWORD
  done
fi

echo "###########################################################"
echo ""
echo " Installed MySQL ${MYSQL_VERSION}"
echo "  root pw: $MYSQL_ROOT_PASSWORD"
echo "     host: $MYSQL_HOST"
echo "     port: $MYSQL_PORT"
echo ""
echo "###########################################################"
