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
JAVA_DISTRIBUTION=""
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
if [ $JAVA_ARCH = "x86_64" ]; then
  JAVA_ARCH="x64"
elif [ $JAVA_ARCH = "i686" ]; then
  JAVA_ARCH="x32"
elif [ $JAVA_ARCH = "aarch64" ]; then
  JAVA_ARCH="arm64"  
elif [ $JAVA_ARCH = "armv6l" ]; then
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

JAVA_OS="linux"
if [ "$CLIB" = "musl" ]; then
  JAVA_OS="linux_musl"
fi


#
# Automatically generated list of urls (do not edit by hand)
#
if [ "$JAVA_URL" = "" ]; then
  if [ "$JAVA_DISTRIBUTION" = "" ] || [ "$JAVA_DISTRIBUTION" = "zulu" ]; then
    if [ "$JAVA_VERSION" = "21" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu21.30.15-ca-jdk21.0.1-linux_x64.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu21.30.15-ca-jdk21.0.1-linux_aarch64.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu21.30.15-ca-jdk21.0.1-linux_musl_x64.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu21.30.15-ca-jdk21.0.1-linux_musl_aarch64.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
      fi
    fi
    if [ "$JAVA_VERSION" = "17" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu17.46.19-ca-jdk17.0.9-linux_x64.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "x32" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu17.46.19-ca-jdk17.0.9-linux_i686.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu17.46.19-ca-jdk17.0.9-linux_aarch64.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          JAVA_URL="https://cdn.azul.com/zulu-embedded/bin/zulu17.44.53-ca-jdk17.0.8.1-linux_aarch32hf.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu17.46.19-ca-jdk17.0.9-linux_musl_x64.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu17.46.19-ca-jdk17.0.9-linux_musl_aarch64.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
      fi
    fi
    if [ "$JAVA_VERSION" = "11" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu11.68.17-ca-jdk11.0.21-linux_x64.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "x32" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu11.68.17-ca-jdk11.0.21-linux_i686.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu11.68.17-ca-jdk11.0.21-linux_aarch64.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          JAVA_URL="https://cdn.azul.com/zulu-embedded/bin/zulu11.64.19-ca-jdk11.0.19-linux_aarch32hf.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          JAVA_URL="https://cdn.azul.com/zulu-embedded/bin/zulu11.66.19-ca-jdk11.0.20.1-linux_aarch32sf.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu11.68.17-ca-jdk11.0.21-linux_musl_x64.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu11.66.19-ca-jdk11.0.20.1-linux_musl_aarch64.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
      fi
    fi
    if [ "$JAVA_VERSION" = "8" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu8.74.0.17-ca-jdk8.0.392-linux_x64.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "x32" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu8.74.0.17-ca-jdk8.0.392-linux_i686.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu-embedded/bin/zulu8.74.0.17-ca-jdk8.0.392-linux_aarch64.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          JAVA_URL="https://cdn.azul.com/zulu-embedded/bin/zulu8.72.0.17-ca-jdk8.0.382-linux_aarch32hf.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          JAVA_URL="https://cdn.azul.com/zulu-embedded/bin/zulu8.72.0.17-ca-jdk8.0.382-linux_aarch32sf.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu8.74.0.17-ca-jdk8.0.392-linux_musl_x64.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu8.72.0.17-ca-jdk8.0.382-linux_musl_aarch64.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
      fi
    fi
    if [ "$JAVA_VERSION" = "7" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu7.56.0.11-ca-jdk7.0.352-linux_x64.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "x32" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu7.56.0.11-ca-jdk7.0.352-linux_i686.tar.gz"
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
      fi
    fi
  fi
fi
if [ "$JAVA_URL" = "" ]; then
  if [ "$JAVA_DISTRIBUTION" = "" ] || [ "$JAVA_DISTRIBUTION" = "nitro" ]; then
    if [ "$JAVA_VERSION" = "21" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          JAVA_URL="https://github.com/fizzed/nitro/releases/download/builds/fizzed19.36-jdk19.0.1-linux_riscv64.tar.gz"
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
      fi
    fi
    if [ "$JAVA_VERSION" = "17" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          JAVA_URL="https://github.com/fizzed/nitro/releases/download/builds/fizzed19.36-jdk19.0.1-linux_riscv64.tar.gz"
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
      fi
    fi
    if [ "$JAVA_VERSION" = "11" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          JAVA_URL="https://github.com/fizzed/nitro/releases/download/builds/fizzed19.36-jdk19.0.1-linux_riscv64.tar.gz"
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
      fi
    fi
    if [ "$JAVA_VERSION" = "8" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          JAVA_URL="https://github.com/fizzed/nitro/releases/download/builds/fizzed19.36-jdk19.0.1-linux_riscv64.tar.gz"
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
      fi
    fi
    if [ "$JAVA_VERSION" = "7" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
      fi
    fi
  fi
fi

#
# End of automatically generated list of urls
#

# did we find a valid JDK?
if [ -z "$JAVA_URL" ]; then
  echo "Unsupported java installer distribution/version distro=$JAVA_DISTRIBUTION, version=$JAVA_VERSION, arch=$JAVA_ARCH"
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
  curl --insecure -f -s -o "$DOWNLOAD_DIR/$JAVA_TARBALL_FILE" -j -k -L "$JAVA_URL"
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
