#!/bin/sh
#
# Return codes
#  1 - generic fail
#  10 - url download failed
#  11 - os/arch is not supported
#

# we need curl to function
if ! [ -x "$(command -v curl)" ]; then
  echo "Dependency 'curl' is missing. Please install it first then re-run this script"
  exit 1
fi

# defaults
CACHE="no"
JAVA_URL=""
JAVA_SLIM="no"
JAVA_DEFAULT="no"
JAVA_VERSION="11"
JAVA_DISTRIBUTION="zulu"
# uname is much more cross-linux compat than arch
JAVA_ARCH=$(uname -m)


# are we on musl, glibc, or uclibc?
echo -n "Detecting glibc or musl... "

CLIB="glibc"
IS_MUSL=$(ldd /bin/ls | grep 'musl' | head -1 | cut -d ' ' -f1)
if [ ! -z $IS_MUSL ]; then
  CLIB="musl"
fi

echo "$CLIB"


echo -n "Detecting hardware architecture... "

# are we on armhf or armel?
if [ $JAVA_ARCH = "armv6l" ]; then
  JAVA_ARCH="armel"
elif [ $JAVA_ARCH = "arm" ] || [ $JAVA_ARCH = "armv7l" ]; then
  echo "Detecting ARM hard-float vs. soft-float..."
  IS_ARMHF=$(ls /lib/ | grep 'gnueabihf' | head -1 | cut -d ' ' -f1)
  if [ ! -z $IS_ARMHF ]; then
    JAVA_ARCH="armhf"
  else
    JAVA_ARCH="armel"
  fi
fi

echo "$JAVA_ARCH"


# if java is missing then force this to be the default?
echo -n "Detecting if java is currently missing and should be the default... "

if [ ! -x "$(command -v java)" ]; then
  if [ ! -d "/usr/lib/jvm" ]; then
    JAVA_DEFAULT="yes"
  fi
fi

echo "$JAVA_DEFAULT"


# arguments
for i in "$@"; do
  case $i in
    --use-cache)
      CACHE="yes"
      ;;
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
    --no-default)
      JAVA_DEFAULT="no"
      ;;
    *)
      echo "Unknown argument '$i'"
      echo "--url=[url of jdk.tar.gz] --version=[8, 11, etc] --distribution=[zulu, etc.] --slim --default --no-default"
      exit 1
      ;;
  esac
done

DOWNLOAD_DIR=.
if [ "$CACHE" = "yes" ]; then
  # download cache
  DOWNLOAD_DIR=".download-cache"
  if [ -d "/vagrant" ]; then
    DOWNLOAD_DIR="/vagrant/.download-cache"
  fi
  mkdir -p "$DOWNLOAD_DIR"
fi

# if url not specified, build url
if [ -z "$JAVA_URL" ]; then
  if [ "$JAVA_DISTRIBUTION" = "zulu" ]; then
    ZPATH="zulu"
    ZVER=""
    ZOS="linux"
    ZARCH="$JAVA_ARCH"
    if [ "$JAVA_VERSION" = "21" ]; then
      ZVER="21.30.15-ca-jdk21.0.1"
    elif [ "$JAVA_VERSION" = "19" ]; then
      ZVER="19.30.11-ca-jdk19.0.1"
    elif [ "$JAVA_VERSION" = "17" ]; then
      ZVER="17.46.19-ca-jdk17.0.9"
    elif [ "$JAVA_VERSION" = "11" ]; then
      ZVER="11.68.17-ca-jdk11.0.21"
    elif [ "$JAVA_VERSION" = "8" ]; then
      ZVER="8.74.0.17-ca-jdk8.0.392"
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
    elif [ "$ZARCH" = "armhf" ]; then
      ZARCH="aarch32hf"
    elif [ "$ZARCH" = "armel" ]; then
      ZARCH="aarch32sf"
    fi

    if [ "$ZARCH" = "aarch64" ] && [ "$ZOS" = "linux" ]; then
      # but only on java version less <= 11
      if [ "$JAVA_VERSION" -le 11 ]; then
        ZPATH="zulu-embedded"
      fi
    elif [ "$ZARCH" = "aarch32hf" ] && [ "$ZOS" = "linux" ]; then
      ZPATH="zulu-embedded"
    elif [ "$ZARCH" = "aarch32sf" ] && [ "$ZOS" = "linux" ]; then
      ZPATH="zulu-embedded"
    fi

    # check os/arch is supported
    if [ "$ZOS" = "linux" ] && [ "$ZARCH" = "x64" ]; then
      : # noop
    elif [ "$ZOS" = "linux" ] && [ "$ZARCH" = "aarch64" ]; then
      : # noop
    elif [ "$ZOS" = "linux" ] && [ "$ZARCH" = "aarch32hf" ]; then
      : # noop
    elif [ "$ZOS" = "linux" ] && [ "$ZARCH" = "aarch32sf" ]; then
      : # noop
    elif [ "$ZOS" = "linux_musl" ] && [ "$ZARCH" = "x64" ]; then
      : # noop
    elif [ "$ZOS" = "linux_musl" ] && [ "$ZARCH" = "aarch64" ]; then
      : # noop
    else
      ZVER=""
    fi

    if [ ! -z "$ZVER" ]; then
      # https://cdn.azul.com/zulu/bin/zulu17.38.21-ca-jdk17.0.5-linux_aarch64.tar.gz
      # https://cdn.azul.com/zulu-embedded/bin/zulu8.66.0.15-ca-jdk8.0.352-linux_aarch64.tar.gz
      # https://cdn.azul.com/zulu/bin/zulu11.60.19-ca-jdk11.0.17-linux_x64.tar.gz
      # https://cdn.azul.com/zulu-embedded/bin/zulu11.60.19-ca-jdk11.0.17-linux_aarch64.tar.gz
      # https://cdn.azul.com/zulu/bin/zulu11.60.19-ca-jdk11.0.17-linux_musl_x64.tar.gz
      # https://cdn.azul.com/zulu/bin/zulu11.60.19-ca-jdk11.0.17-linux_musl_aarch64.tar.gz
      # 
      JAVA_URL="https://cdn.azul.com/${ZPATH}/bin/zulu${ZVER}-${ZOS}_${ZARCH}.tar.gz"
    fi
  fi

  # for riscv64, we can do special handling of a JDK
  if [ -z "$JAVA_URL" ] && [ "$JAVA_ARCH" = "riscv64" ]; then
    if [ ! "$JAVA_VERSION" = "19" ]; then
      echo "Arch riscv64 present, will default to Java 19 (since it has a hotspot JIT engine)"
    fi
    JAVA_URL="https://github.com/fizzed/nitro/releases/download/builds/fizzed19.36-jdk19.0.1-linux_riscv64.tar.gz"
  fi
fi

# did we find a valid JDK?
if [ -z "$JAVA_URL" ]; then
  echo "Unsupported distribution/os/arch combo of $JAVA_ARCH / $JAVA_OS"
  exit 11
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
  curl -f -s -o "$DOWNLOAD_DIR/$JAVA_TARBALL_FILE" -j -k -L "$JAVA_URL"
  if [ $? -ne 0 ]; then
    echo "Unable to download $JAVA_URL"
    exit 10
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

# delete this download now?
if [ "$CACHE" = "no" ]; then
  rm -f "$DOWNLOAD_DIR/$JAVA_TARBALL_FILE"
fi

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
  # this is not portable across shells
  #echo "if ! [[ \$PATH == *\"\$JAVA_HOME\"* ]]; then PATH=\"\$JAVA_HOME/bin:\$PATH\"; export PATH; fi" >> /etc/profile.d/java.sh
  echo 'if [ ! -z "${PATH##*$JAVA_HOME*}" ]; then PATH="$JAVA_HOME/bin:$PATH"; export PATH; fi' >> /etc/profile.d/java.sh
fi

echo "###########################################################"
echo ""
echo " Installed $JAVA_DIR"
echo ""
/usr/lib/jvm/$JAVA_DIR/bin/java -version
echo "###########################################################"
