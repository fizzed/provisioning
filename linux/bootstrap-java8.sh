#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# defaults
JAVA_TYPE="server-jre"     		# jdk, jre, or server-jre
JAVA_VERSION="1.8.0_91"

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
  *)
    echo "Unsupported java version $JAVA_VERSION (you'll need to add code to this script to correctly install it)"
    exit 1  
    ;;
esac

# http://download.oracle.com/otn-pub/java/jdk/8u91-b14/jdk-8u91-linux-x64.tar.gz

# dependencies
if type apt-get &>/dev/null; then
  sudo apt-get update
  sudo apt-get -y install curl
elif type yum &>/dev/null; then
  sudo yum update
  sudo yum -y install curl
fi

echo "Installing $JAVA_TYPE $JAVA_VERSION..."

# download and install java 8 file
curl -O -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/$JAVA_URL_DIR/$JAVA_TYPE-$JAVA_FILE_VERSION-linux-x64.tar.gz
tar zxvf $JAVA_TYPE-$JAVA_FILE_VERSION-linux-x64.tar.gz
mkdir --parents /usr/lib/jvm
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

echo "Installed $JAVA_TYPE $JAVA_VERSION"
