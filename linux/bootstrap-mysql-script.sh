#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

MYSQL_USER="$1"
if [ -z "$MYSQL_USER" ]; then echo "First arg must be mysql user"; exit 1; fi

MYSQL_PW="$2"
if [ -z "$MYSQL_PW" ]; then echo "Second arg must be mysql password"; exit 1; fi

MYSQL_DB="$3"
if [ -z "$MYSQL_DB" ]; then echo "Third arg must be mysql database"; exit 1; fi

MYSQL_SCRIPT="$4"
if [ -z "$MYSQL_SCRIPT" ]; then echo "Fourth arg must be path to mysql script (on guest)"; exit 1; fi

cat "$MYSQL_SCRIPT" | mysql -u $MYSQL_USER -p$MYSQL_PW $MYSQL_DB

echo "Executed mysql script $MYSQL_SCRIPT on $MYSQL_DB as $MYSQL_USER"
