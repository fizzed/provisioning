#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# download cache
DOWNLOAD_DIR=".download-cache"
if [ -d "/vagrant" ]; then
  DOWNLOAD_DIR="/vagrant/.download-cache"
fi
mkdir -p "$DOWNLOAD_DIR"

# defaults
JAVA_URL="https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u252-b09/OpenJDK8U-jdk_x64_linux_hotspot_8u252b09.tar.gz"
JAVA_SLIM="no"
JAVA_DEFAULT="no"

# arguments
for i in "$@"; do
  case $i in
    --url=*)
      JAVA_URL="${i#*=}"
      ;;
    --slim)
      JAVA_SLIM="yes"
      ;;
    --default)
      JAVA_DEFAULT="yes"
      ;;
    *)
      echo "Unknown argument '$i'"
      echo "--url=[url of jdk.tar.gz] --slim --default"
      exit 1
      ;;
  esac
done

# dependencies
if ! [ -x "$(command -v curl)" ]; then
  if type apt-get &>/dev/null; then
    sudo apt-get update
    sudo apt-get -y install curl
  elif type yum &>/dev/null; then
    sudo yum update
    sudo yum -y install curl
  fi
fi

JAVA_TARBALL_FILE="${JAVA_URL##*/}"

# force this to be the default?
if ! [ -x "$(command -v java)" ]; then
  JAVA_DEFAULT="yes"
fi

echo "Installing Java..."
echo "     url: $JAVA_URL"
echo "    file: $JAVA_TARBALL_FILE"
echo "    slim: $JAVA_SLIM"
echo " default: $JAVA_DEFAULT"

# download url to file...
if [ ! -f "$DOWNLOAD_DIR/$JAVA_TARBALL_FILE" ]; then
  echo "Downloading $JAVA_URL"
  curl -o "$DOWNLOAD_DIR/$JAVA_TARBALL_FILE" -j -k -L "$JAVA_URL"
fi

# top-level directory contents will be extracted to
JAVA_DIR=`tar ztf "$DOWNLOAD_DIR/$JAVA_TARBALL_FILE" | head -1 | cut -f1 -d"/"`

echo "  dir: $JAVA_DIR"

rm -Rf "$JAVA_DIR"
tar zxvf "$DOWNLOAD_DIR/$JAVA_TARBALL_FILE"
mkdir --parents /usr/lib/jvm
rm -Rf "/usr/lib/jvm/$JAVA_DIR"

if [ "$JAVA_SLIM" = "yes" ]; then
  rm -Rf "$JAVA_DIR/sample"
  rm -Rf "$JAVA_DIR/demo"
  rm -Rf "$JAVA_DIR/src.zip"
  rm -Rf "$JAVA_DIR/legal"
  rm -Rf "$JAVA_DIR/man"
fi

mv "$JAVA_DIR" /usr/lib/jvm/

# make this the default?
if [ "$JAVA_DEFAULT" = "yes" ]; then
  rm -f /usr/lib/jvm/current
  ln -s "/usr/lib/jvm/$JAVA_DIR" /usr/lib/jvm/current
fi

# does /etc/environment exist?
if [ -f /etc/environment ]; then
  # remove then add java to path in environment
  echo "Adding jvm to /etc/environment"
  sed -e 's|/usr/lib/jvm/current/bin:||g' -i /etc/environment
  sed -e 's|PATH="\(.*\)"|PATH="/usr/lib/jvm/current/bin:\1"|g' -i /etc/environment

  # add java_home to environment
  if ! grep JAVA_HOME /etc/environment > /dev/null; then
    echo "JAVA_HOME=/usr/lib/jvm/current" >> /etc/environment
  fi
fi

# does /etc/profile.d exist? (in case /etc/environment not used)
if [ -d /etc/profile.d ]; then
  # always overwrite
  echo "if [ -z \"\$JAVA_HOME\" ]; then JAVA_HOME=/usr/lib/jvm/current; export JAVA_HOME; fi" > /etc/profile.d/java.sh    
  echo "if ! [[ \$PATH == *\"\$JAVA_HOME\"* ]]; then PATH=\"\$JAVA_HOME/bin:\$PATH\"; export PATH; fi" >> /etc/profile.d/java.sh
fi

echo "###########################################################"
echo ""
echo " Installed $JAVA_DIR"
echo ""
/usr/lib/jvm/$JAVA_DIR/bin/java -version
echo "###########################################################"
