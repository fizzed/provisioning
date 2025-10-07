#!/bin/sh

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
HELPERS_DIR="$TEMP_DIR/provisioning-helpers"
mkdir "$HELPERS_DIR"

curl --insecure -f -s -o "$HELPERS_DIR/blaze.jar" "https://cdn.fizzed.com/provisioning/helpers/blaze.jar"
curl --insecure -f -s -o "$HELPERS_DIR/blaze.conf" "https://cdn.fizzed.com/provisioning/helpers/blaze.conf"
curl --insecure -f -s -o "$HELPERS_DIR/blaze.java" "https://cdn.fizzed.com/provisioning/helpers/blaze.java"

java -jar "$HELPERS_DIR/blaze.jar" "$HELPERS_DIR/blaze.java" install_fastfetch "$@"

rm -Rf "$HELPERS_DIR"