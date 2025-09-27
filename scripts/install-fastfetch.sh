#!/bin/sh

### BEGIN BLAZE.JAR INSTALL

# we need java to function
if ! [ -x "$(command -v java)" ]; then
  echo "Dependency 'java' is missing. Please install it first then re-run this script"
  exit 1
fi

# we need curl to function
if ! [ -x "$(command -v curl)" ]; then
  echo "Dependency 'curl' is missing. Please install it first then re-run this script"
  exit 1
fi

# we need to download provisioning blaze.jar, blaze.conf, blaze.java
TEMP_DIR=/tmp
HELPERS_DIR="$TEMP_DIR/.provisioning-helpers"
mkdir -p "$HELPERS_DIR"

curl --insecure -f -s -o "$HELPERS_DIR/blaze.jar" "https://raw.githubusercontent.com/jjlauer/provisioning/master/helpers/blaze.jar"
curl --insecure -f -s -o "$HELPERS_DIR/blaze.conf" "https://raw.githubusercontent.com/jjlauer/provisioning/master/helpers/blaze.conf"
curl --insecure -f -s -o "$HELPERS_DIR/blaze.java" "https://raw.githubusercontent.com/jjlauer/provisioning/master/helpers/blaze.java"

### END BLAZE.JAR INSTALL

java -jar "$HELPERS_DIR/blaze.jar" "$HELPERS_DIR/blaze.java" install_fastfetch

rm -Rf "$HELPERS_DIR"