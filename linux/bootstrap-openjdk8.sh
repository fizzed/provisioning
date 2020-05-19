#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# download cache
DOWNLOAD_DIR=".download-cache"
if [ -d "/vagrant" ]; then
  DOWNLOAD_DIR="/vagrant/.download-cache"
fi
mkdir -p "$DOWNLOAD_DIR"

# defaults
JAVA_TYPE="jre"     		# jdk, jre, or server-jre
JAVA_VERSION="8u252"

# arguments
for i in "$@"; do
  case $i in
    --type=*)
      JAVA_TYPE="${i#*=}"
      ;;
    --version=*)
      JAVA_VERSION="${i#*=}"
      ;;
    *)
      echo "Unknown argument '$i'"
      echo "--type=[jdk|jre] --version=[8u252|...]"
      exit 1  
      ;;
  esac
done

# java type valid?
case $JAVA_TYPE in
  jdk|jre)
    ;;
  *)
    echo "Unsupported java type $JAVA_TYPE (must be jdk, jre, or server-jre)"
    exit 1
    ;;
esac

# java versions valid? (we have to setup stuff so versions must be manually supported)
case $JAVA_VERSION in
  8u252)
    JAVA_FILE_VERSION="8u252b09"
    JAVA_URL_DIR="jdk8u252-b09"
    ;;
  *)
    echo "Unsupported java version $JAVA_VERSION (you'll need to add code to this script to correctly install it)"
    exit 1  
    ;;
esac

# https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u252-b09/OpenJDK8U-jre_x64_linux_hotspot_8u252b09.tar.gz

# dependencies
if type apt-get &>/dev/null; then
  sudo apt-get update
  sudo apt-get -y install curl
elif type yum &>/dev/null; then
  sudo yum update
  sudo yum -y install curl
fi

echo "Installing $JAVA_TYPE $JAVA_VERSION..."

# download file if it doesn't exist yet
JAVA_TARBALL_FILE="OpenJDK8U-${JAVA_TYPE}_x64_linux_hotspot_${JAVA_FILE_VERSION}.tar.gz"
JAVA_URL="https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/$JAVA_URL_DIR/$JAVA_TARBALL_FILE"

if [ ! -f "$DOWNLOAD_DIR/$JAVA_TARBALL_FILE" ]; then
  echo "Downloading $JAVA_URL"
  curl -o "$DOWNLOAD_DIR/$JAVA_TARBALL_FILE" -j -k -L "$JAVA_URL"
fi

JAVA_DIR=$JAVA_URL_DIR
if [ "$JAVA_TYPE" = "jre" ]; then
  JAVA_DIR=$JAVA_DIR-jre
fi

# jdk8u252-b09-jre
tar zxvf $DOWNLOAD_DIR/$JAVA_TARBALL_FILE
mkdir --parents /usr/lib/jvm
rm -f /usr/lib/jvm/current
rm -Rf /usr/lib/jvm/jdk$JAVA_VERSION
mv $JAVA_DIR /usr/lib/jvm/
ln -s /usr/lib/jvm/$JAVA_DIR /usr/lib/jvm/current

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
echo " Installed $JAVA_TYPE $JAVA_VERSION"
echo ""
echo "###########################################################"
