#!/bin/sh

# we need curl to function
if ! [ -x "$(command -v curl)" ]; then
  echo "Dependency 'curl' is missing. Please install it first then re-run this script"
  exit 1
fi

# download cache
DOWNLOAD_DIR=".download-cache"
if [ -d "/vagrant" ]; then
  DOWNLOAD_DIR="/vagrant/.download-cache"
fi
mkdir -p "$DOWNLOAD_DIR"

# defaults
JAVA_URL=""
JAVA_SLIM="no"
JAVA_DEFAULT="no"
JAVA_VERSION="11"
JAVA_DISTRIBUTION="zulu"
# uname is much more cross-linux compat than arch
JAVA_ARCH=$(uname -m)

# are we on musl, glibc, or uclibc?
echo "Detcting glibc, musl, or uclibc..."
CLIB="glibc"
IS_MUSL=$(ldd /bin/ls | grep 'musl' | head -1 | cut -d ' ' -f1)
IS_UCLIBC=$(ldd /bin/ls | grep 'uclibc' | head -1 | cut -d ' ' -f1)
if [ ! -z $IS_MUSL ]; then
  CLIB="musl"
elif [ ! -z $IS_UCLIBC ]; then
  CLIB="uclibc"
fi

# if java is missing then force this to be the default?
if ! [ -x "$(command -v java)" ]; then
  if ! [ -d "/usr/lib/jvm" ]; then
    JAVA_DEFAULT="yes"
  fi
fi

# arguments
for i in "$@"; do
  case $i in
    --url=*)
      JAVA_URL="${i#*=}"
      ;;
    --version=*)
      JAVA_VERSION="${i#*=}"
      ;;
    --distribution=*)
      JAVA_DISTRIBUTION="${i#*=}"
      ;;
    --slim)
      JAVA_SLIM="yes"
      ;;
    --default)
      JAVA_DEFAULT="yes"
      ;;
    *)
      echo "Unknown argument '$i'"
      echo "--url=[url of jdk.tar.gz] --version=[8, 11, etc] --distribution=[zulu, etc.] --slim --default --no-default"
      exit 1
      ;;
  esac
done

# if url not specified, build url
if [ -z "$JAVA_URL" ]; then
  if [ "$JAVA_DISTRIBUTION" = "zulu" ]; then
    ZPATH="zulu"
    ZVER=""
    ZOS="linux"
    ZARCH="$JAVA_ARCH"
    if [ "$JAVA_VERSION" = "17" ]; then
      ZVER="17.38.21-ca-jdk17.0.5"
    elif [ "$JAVA_VERSION" = "11" ]; then
      ZVER="11.60.19-ca-jdk11.0.17"
    elif [ "$JAVA_VERSION" = "8" ]; then
      ZVER="8.66.0.15-ca-jdk8.0.352"
    else
      echo "Unsupported version $JAVA_VERSION"
      exit 1
    fi

    # for musl builds, the ZOS needs to change
    if [ "$CLIB" = "musl" ]; then
      ZOS="linux_musl"
    fi

    if [ "$ZARCH" = "x86_64" ]; then
      ZARCH="x64"
    fi

    if [ "$ZARCH" = "aarch64" ] && [ "$ZOS" = "linux" ]; then
      # but only on java version less <= 11
      if [ "$JAVA_VERSION" -le 11 ]; then
        ZPATH="zulu-embedded"
      fi
    fi

    # https://cdn.azul.com/zulu/bin/zulu17.38.21-ca-jdk17.0.5-linux_aarch64.tar.gz
    # https://cdn.azul.com/zulu-embedded/bin/zulu8.66.0.15-ca-jdk8.0.352-linux_aarch64.tar.gz
    # https://cdn.azul.com/zulu/bin/zulu11.60.19-ca-jdk11.0.17-linux_x64.tar.gz
    # https://cdn.azul.com/zulu-embedded/bin/zulu11.60.19-ca-jdk11.0.17-linux_aarch64.tar.gz
    # https://cdn.azul.com/zulu/bin/zulu11.60.19-ca-jdk11.0.17-linux_musl_x64.tar.gz
    # https://cdn.azul.com/zulu/bin/zulu11.60.19-ca-jdk11.0.17-linux_musl_aarch64.tar.gz
    JAVA_URL="https://cdn.azul.com/${ZPATH}/bin/zulu${ZVER}-${ZOS}_${ZARCH}.tar.gz"
  else
    echo "Unsupported distribution $JAVA_DISTRIBUTION"
    exit 1
  fi
fi

JAVA_TARBALL_FILE="${JAVA_URL##*/}"

echo "Installing Java..."
echo "    arch: $JAVA_ARCH"
echo "   c-lib: $CLIB"
echo "     url: $JAVA_URL"
echo "    file: $JAVA_TARBALL_FILE"
echo "    slim: $JAVA_SLIM"
echo " default: $JAVA_DEFAULT"

# download url to file...
if [ ! -f "$DOWNLOAD_DIR/$JAVA_TARBALL_FILE" ]; then
  echo "Downloading $JAVA_URL"
  curl -s -o "$DOWNLOAD_DIR/$JAVA_TARBALL_FILE" -j -k -L "$JAVA_URL"
  if [ $? -ne 0 ]; then
    echo "Unable to download $JAVA_URL"
    exit 1
  fi
fi

# top-level directory contents will be extracted to
JAVA_DIR=`tar ztf "$DOWNLOAD_DIR/$JAVA_TARBALL_FILE" | head -1 | cut -f1 -d"/"`

if [ $? -ne 0 ]; then
  echo "Unable to list contents of tarball $JAVA_TARBALL_FILE"
  exit 1
fi


echo "Java dir: $JAVA_DIR"

rm -Rf "$JAVA_DIR"

if ! [ $? -eq 0 ]; then
  echo "Unable to remove $JAVA_DIR"
  exit 1
fi

tar zxf "$DOWNLOAD_DIR/$JAVA_TARBALL_FILE"

mkdir -p /usr/lib/jvm

rm -Rf "/usr/lib/jvm/$JAVA_DIR"

if ! [ $? -eq 0 ]; then
  echo "Unable to remove /usr/lib/jvm/$JAVA_DIR"
  exit 1
fi

if [ "$JAVA_SLIM" = "yes" ]; then
  rm -Rf "$JAVA_DIR/sample"
  rm -Rf "$JAVA_DIR/demo"
  rm -Rf "$JAVA_DIR/src.zip"
  rm -Rf "$JAVA_DIR/legal"
  rm -Rf "$JAVA_DIR/man"
fi

mv "$JAVA_DIR" /usr/lib/jvm/

if [ $? -ne 0 ]; then
  echo "Unable to mv $JAVA_DIR to /usr/lib/jvm/"
  exit 1
fi

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
