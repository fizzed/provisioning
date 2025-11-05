#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

MYSQL_ROOT_PASSWORD="$1"
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then MYSQL_ROOT_PASSWORD="test"; fi

MYSQL_VERSION="5.6.29"

echo "Installing mysql $MYSQL_VERSION..."

# mysql common
apt-get update
apt-get -y install libaio1 libnuma1 apparmor
wget https://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-common_$MYSQL_VERSION-1ubuntu14.04_amd64.deb
dpkg -i mysql-common_$MYSQL_VERSION-1ubuntu14.04_amd64.deb

# mysql server
wget https://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-community-server_$MYSQL_VERSION-1ubuntu14.04_amd64.deb
echo "mysql-community-server  mysql-community-server/re-root-pass     password	$MYSQL_ROOT_PASSWORD" | sudo debconf-set-selections
echo "mysql-community-server  mysql-community-server/root-pass        password	$MYSQL_ROOT_PASSWORD" | sudo debconf-set-selections
echo "mysql-community-server  mysql-community-server/remove-data-dir  boolean true"  | sudo debconf-set-selections
dpkg -i mysql-community-server_$MYSQL_VERSION-1ubuntu14.04_amd64.deb

# mysql client
wget https://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-community-client_$MYSQL_VERSION-1ubuntu14.04_amd64.deb
dpkg -i mysql-community-client_$MYSQL_VERSION-1ubuntu14.04_amd64.deb

# by default mysql only allows localhost (not via port forward)
echo "DELETE FROM mysql.user WHERE NOT Host = 'localhost'" | mysql -u root -p$MYSQL_ROOT_PASSWORD
echo "UPDATE mysql.user SET Host='%' where Host='localhost'" | mysql -u root -p$MYSQL_ROOT_PASSWORD
echo "GRANT ALL PRIVILEGES ON *.* TO root@localhost" | mysql -u root -p$MYSQL_ROOT_PASSWORD
echo "FLUSH PRIVILEGES" | mysql -u root -p$MYSQL_ROOT_PASSWORD

# port forwards only work to a real ip, not localhost
sed -i "s/= 127.0.0.1/= 0.0.0.0/" /etc/mysql/my.cnf

service mysql restart

echo "Installed mysql $MYSQL_VERSION"