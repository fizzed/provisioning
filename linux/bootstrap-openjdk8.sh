#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# download cache
DOWNLOAD_DIR=".download-cache"
if [ -d "/vagrant" ]; then
  DOWNLOAD_DIR="/vagrant/.download-cache"
fi
mkdir -p "$DOWNLOAD_DIR"

# defaults
JAVA_JVM="hotspot"
JAVA_VERSION="222"

# arguments
for i in "$@"; do
  case $i in
    --jvm=*)
      JAVA_JVM="${i#*=}"
      ;;
    --version=*)
      JAVA_VERSION="${i#*=}"
      ;;
    *)
      echo "Unknown argument '$i'"
      echo "--jvm=[hotspot|openj9] --version=[222|...]"
      exit 1  
      ;;
  esac
done

# java type valid?
case $JAVA_JVM in
  hotspot|openj9)
    ;;
  *)
    echo "Unsupported java jvm $JAVA_JVM (must be hotspot, or openj9)"
    exit 1
    ;;
esac

# java versions valid? (we have to setup stuff so versions must be manually supported)
case $JAVA_VERSION in
  222)
    JAVA_FILE_VERSION="b10"
    ;;
  *)
    echo "Unsupported java version $JAVA_VERSION (you'll need to add code to this script to correctly install it)"
    exit 1  
    ;;
esac

# https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u222-b10/OpenJDK8U-jdk_x64_linux_hotspot_8u222b10.tar.gz

# dependencies
if type apt-get &>/dev/null; then
  sudo apt-get update
  sudo apt-get -y install curl
elif type yum &>/dev/null; then
  sudo yum update
  sudo yum -y install curl
fi

echo "Installing Java 8-$JAVA_VERSION ($JAVA_JVM)..."

# download file if it doesn't exist yet
JAVA_TARBALL_FILE="OpenJDK8U-jdk_x64_linux_${JAVA_JVM}_8u${JAVA_VERSION}${JAVA_FILE_VERSION}.tar.gz"
JAVA_URL="https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u$JAVA_VERSION-$JAVA_FILE_VERSION/$JAVA_TARBALL_FILE"
if [ ! -f "$DOWNLOAD_DIR/$JAVA_TARBALL_FILE" ]; then
  echo "Downloading $JAVA_URL"
  curl -o "$DOWNLOAD_DIR/$JAVA_TARBALL_FILE" -j -k -L "$JAVA_URL"
fi

tar zxvf $DOWNLOAD_DIR/$JAVA_TARBALL_FILE

mkdir --parents /usr/lib/jvm
rm -f /usr/lib/jvm/current
# jdk8u222-b10
TARGET_DIR=openjdk-1.8.0_${JAVA_VERSION}
mv jdk8u${JAVA_VERSION}-${JAVA_FILE_VERSION} /usr/lib/jvm/${TARGET_DIR}
ln -s /usr/lib/jvm/${TARGET_DIR} /usr/lib/jvm/current

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
