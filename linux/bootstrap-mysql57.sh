#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# we only support ubuntu
. /etc/lsb-release

if [ -z "${DISTRIB_RELEASE}" ]; then
  echo "This script only supports versions of ubuntu..."
  exit 1
fi

# ${DISTRIB_RELEASE} will be 14.04 or 16.04

# defaults
MYSQL_VERSION="5.7.14"
MYSQL_ROOT_PASSWORD="test"
MYSQL_CREATE_DB=

# arguments
for i in "$@"; do
  case $i in
    --version=*)
      MYSQL_VERSION="${i#*=}"
      ;;
    --rootpw=*)
      MYSQL_ROOT_PASSWORD="${i#*=}"
      ;;
    --createdb=*)
      MYSQL_CREATE_DB="${i#*=}"
      ;;
    *)
      echo "Unknown argument '$i'"
      exit 1
      ;;
  esac
done

echo "Installing mysql ${MYSQL_VERSION} for Ubuntu ${DISTRIB_RELEASE}..."

# mysql common
apt-get update
apt-get -y install libaio1 libnuma1 apparmor libmecab2 psmisc
wget --no-verbose https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-common_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb
dpkg -i mysql-common_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb

# mysql client
echo "Downloading mysql-community-client..."
wget --no-verbose https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-client_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb
dpkg -i mysql-community-client_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb

# mysql client #2
echo "Downloading mysql-client..."
wget --no-verbose https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-client_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb
dpkg -i mysql-client_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb

# mysql server
echo "Downloading mysql-community-server..."
wget --no-verbose https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-server_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb
echo "mysql-community-server  mysql-community-server/re-root-pass     password	$MYSQL_ROOT_PASSWORD" | sudo debconf-set-selections
echo "mysql-community-server  mysql-community-server/root-pass        password	$MYSQL_ROOT_PASSWORD" | sudo debconf-set-selections
echo "mysql-community-server  mysql-community-server/remove-data-dir  boolean true"  | sudo debconf-set-selections
dpkg -i mysql-community-server_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb

# mysql server #2
echo "Downloading mysql-server..."
wget --no-verbose https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-server_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb
dpkg -i mysql-server_${MYSQL_VERSION}-1ubuntu${DISTRIB_RELEASE}_amd64.deb

# by default mysql only allows localhost (not via port forward)
echo "DELETE FROM mysql.user WHERE NOT Host = 'localhost'" | mysql -u root -p$MYSQL_ROOT_PASSWORD
echo "UPDATE mysql.user SET Host='%' where Host='localhost'" | mysql -u root -p$MYSQL_ROOT_PASSWORD
echo "GRANT ALL PRIVILEGES ON *.* TO root@localhost" | mysql -u root -p$MYSQL_ROOT_PASSWORD
echo "FLUSH PRIVILEGES" | mysql -u root -p$MYSQL_ROOT_PASSWORD

# port forwards only work to a real ip, not localhost
sed -i "s/= 127.0.0.1/= 0.0.0.0/" /etc/mysql/my.cnf

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

echo "Installed mysql ${MYSQL_VERSION}"
