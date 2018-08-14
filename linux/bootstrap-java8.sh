#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# download cache
DOWNLOAD_DIR=".download-cache"
if [ -d "/vagrant" ]; then
  DOWNLOAD_DIR="/vagrant/.download-cache"
fi
mkdir -p "$DOWNLOAD_DIR"

# defaults
JAVA_TYPE="server-jre"     		# jdk, jre, or server-jre
JAVA_VERSION="1.8.0_181"
JAVA_HASH=

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
      echo "--type=[jdk|jre|server-jre] --version=[1.8.0_151|1.8.0_144|...]"
      exit 1  
      ;;
  esac
done

# java type valid?
case $JAVA_TYPE in
  jdk|jre|server-jre)
    ;;
  *)
    echo "Unsupported java type $JAVA_TYPE (must be jdk, jre, or server-jre)"
    exit 1
    ;;
esac

# java versions valid? (we have to setup stuff so versions must be manually supported)
case $JAVA_VERSION in
  1.8.0_74)
    JAVA_FILE_VERSION="8u74"
    JAVA_URL_DIR="8u74-b02"
    ;;
  1.8.0_91)
    JAVA_FILE_VERSION="8u91"
    JAVA_URL_DIR="8u91-b14"
    ;;
  1.8.0_101)
    JAVA_FILE_VERSION="8u101"
    JAVA_URL_DIR="8u101-b13"
    ;;
  1.8.0_102)
    JAVA_FILE_VERSION="8u102"
    JAVA_URL_DIR="8u102-b14"
    ;;
  1.8.0_121)
    JAVA_FILE_VERSION="8u121"
    JAVA_URL_DIR="8u121-b13"
    JAVA_HASH="/e9e7ea248e2c4826b92b3f075a80e441"
    ;;
  1.8.0_144)
    JAVA_FILE_VERSION="8u144"
    JAVA_URL_DIR="8u144-b01"
    JAVA_HASH="/090f390dda5b47b9b721c7dfaa008135"
    ;;
  1.8.0_151)
    JAVA_FILE_VERSION="8u151"
    JAVA_URL_DIR="8u151-b12"
    JAVA_HASH="/e758a0de34e24606bca991d704f6dcbf"
    ;;
  1.8.0_161)
    JAVA_FILE_VERSION="8u161"
    JAVA_URL_DIR="8u161-b12"
    JAVA_HASH="/2f38c3b165be4555a1fa6e98c45e0808"
    ;;
  1.8.0_181)
    JAVA_FILE_VERSION="8u181"
    JAVA_URL_DIR="8u181-b13"
    JAVA_HASH="/96a7b8442fe848ef90c96a2fad6ed6d1"
    ;;
  *)
    echo "Unsupported java version $JAVA_VERSION (you'll need to add code to this script to correctly install it)"
    exit 1  
    ;;
esac

# http://download.oracle.com/otn-pub/java/jdk/8u91-b14/jdk-8u91-linux-x64.tar.gz
# http://download.oracle.com/otn-pub/java/jdk/8u101-b13/jdk-8u101-linux-x64.tar.gz
# http://download.oracle.com/otn-pub/java/jdk/8u102-b14/jdk-8u102-linux-x64.tar.gz

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
JAVA_TARBALL_FILE="$JAVA_TYPE-$JAVA_FILE_VERSION-linux-x64.tar.gz"
# http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/server-jre-8u121-linux-x64.tar.gz
JAVA_URL="http://download.oracle.com/otn-pub/java/jdk/$JAVA_URL_DIR$JAVA_HASH/$JAVA_TARBALL_FILE"
if [ ! -f "$DOWNLOAD_DIR/$JAVA_TARBALL_FILE" ]; then
  echo "Downloading $JAVA_URL"
  curl -o "$DOWNLOAD_DIR/$JAVA_TARBALL_FILE" -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" "$JAVA_URL"
fi

tar zxvf $DOWNLOAD_DIR/$JAVA_TYPE-$JAVA_FILE_VERSION-linux-x64.tar.gz
mkdir --parents /usr/lib/jvm
rm -f /usr/lib/jvm/current
rm -Rf /usr/lib/jvm/jdk$JAVA_VERSION
mv jdk$JAVA_VERSION /usr/lib/jvm/
ln -s /usr/lib/jvm/jdk$JAVA_VERSION /usr/lib/jvm/current

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
