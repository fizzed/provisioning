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
JAVA_SLIM="yes"
JAVA_DEFAULT="no"
JAVA_VERSION="17"
JAVA_DISTRIBUTION=""
# uname is much more cross-linux compat than arch
JAVA_ARCH=$(uname -m)
JAVA_TARGET_DISTRO=""
JAVA_TARGET_VERSION=""

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
    --arch=*)
      JAVA_ARCH="${i#*=}"
      ;;  
    --distribution=*)
      JAVA_DISTRIBUTION="${i#*=}"
      ;;
    --no-slim)
      JAVA_SLIM="no"
      ;;
    --default)
      JAVA_DEFAULT="yes"
      ;;
    --no-default)
      JAVA_DEFAULT="no"
      ;;
    *)
      echo "Unknown argument '$i'"
      echo "--url=[url of jdk.tar.gz] --version=[8, 11, etc] --arch=[x64, x32, arm64, etc] --distribution=[zulu, liberica, temurin, etc.] --no-slim --default --no-default"
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


#if [ -w "/usr/lib/jvm" ]; then
#  echo "Directory /usr/lib/jvm is writable :-)"
#else
#  echo "Directory /usr/lib/jvm is NOT writable (perhaps you did not run with sudo?)"
#  exit 1
#fi

#
# Automatically generated list of urls (do not edit by hand)
#
if [ "$JAVA_URL" = "" ]; then
  if [ "$JAVA_DISTRIBUTION" = "" ] || [ "$JAVA_DISTRIBUTION" = "zulu" ]; then
    if [ "$JAVA_VERSION" = "25" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu25.28.85-ca-jdk25.0.0-linux_x64.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="25.0.0.36"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu25.28.85-ca-jdk25.0.0-linux_aarch64.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="25.0.0.36"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu25.28.85-ca-jdk25.0.0-linux_musl_x64.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="25.0.0.36"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu25.28.85-ca-jdk25.0.0-linux_musl_aarch64.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="25.0.0.36"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
    fi
    if [ "$JAVA_VERSION" = "21" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu21.44.17-ca-jdk21.0.8-linux_x64.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="21.0.8.9"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu21.44.17-ca-jdk21.0.8-linux_aarch64.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="21.0.8.9"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu21.44.17-ca-jdk21.0.8-linux_musl_x64.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="21.0.8.9"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu21.44.17-ca-jdk21.0.8-linux_musl_aarch64.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="21.0.8.9"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
    fi
    if [ "$JAVA_VERSION" = "17" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu17.60.17-ca-jdk17.0.16-linux_i686.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="17.0.16.8"
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu17.60.17-ca-jdk17.0.16-linux_x64.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="17.0.16.8"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          JAVA_URL="https://cdn.azul.com/zulu-embedded/bin/zulu17.60.17-ca-jdk17.0.16-c2-linux_aarch32hf.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="17.0.16.8"
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu17.60.17-ca-jdk17.0.16-linux_aarch64.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="17.0.16.8"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu17.60.17-ca-jdk17.0.16-linux_musl_x64.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="17.0.16.8"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu17.60.17-ca-jdk17.0.16-linux_musl_aarch64.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="17.0.16.8"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
    fi
    if [ "$JAVA_VERSION" = "11" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu11.82.19-ca-jdk11.0.28-linux_i686.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="11.0.28.6"
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu11.82.19-ca-jdk11.0.28-linux_x64.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="11.0.28.6"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          JAVA_URL="https://cdn.azul.com/zulu-embedded/bin/zulu11.82.19-ca-jdk11.0.28-linux_aarch32sf.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="11.0.28.6"
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          JAVA_URL="https://cdn.azul.com/zulu-embedded/bin/zulu11.82.19-ca-jdk11.0.28-linux_aarch32hf.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="11.0.28.6"
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu11.82.19-ca-jdk11.0.28-linux_aarch64.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="11.0.28.6"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu11.82.19-ca-jdk11.0.28-linux_musl_x64.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="11.0.28.6"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu11.82.19-ca-jdk11.0.28-linux_musl_aarch64.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="11.0.28.6"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
    fi
    if [ "$JAVA_VERSION" = "8" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu8.88.0.19-ca-jdk8.0.462-linux_i686.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="8.0.462.8"
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu8.88.0.19-ca-jdk8.0.462-linux_x64.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="8.0.462.8"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          JAVA_URL="https://cdn.azul.com/zulu-embedded/bin/zulu8.88.0.19-ca-jdk8.0.462-linux_aarch32sf.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="8.0.462.8"
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          JAVA_URL="https://cdn.azul.com/zulu-embedded/bin/zulu8.88.0.19-ca-jdk8.0.462-linux_aarch32hf.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="8.0.462.8"
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu8.88.0.19-ca-jdk8.0.462-linux_aarch64.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="8.0.462.8"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu8.88.0.19-ca-jdk8.0.462-linux_musl_x64.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="8.0.462.8"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://cdn.azul.com/zulu/bin/zulu8.88.0.19-ca-jdk8.0.462-linux_musl_aarch64.tar.gz"
          JAVA_TARGET_DISTRO="zulu"
          JAVA_TARGET_VERSION="8.0.462.8"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
    fi
  fi
fi
if [ "$JAVA_URL" = "" ]; then
  if [ "$JAVA_DISTRIBUTION" = "" ] || [ "$JAVA_DISTRIBUTION" = "liberica" ]; then
    if [ "$JAVA_VERSION" = "25" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/25+37/bellsoft-jdk25+37-linux-amd64.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="25.0.0.37"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/25+37/bellsoft-jdk25+37-linux-aarch64.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="25.0.0.37"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/25+37/bellsoft-jdk25+37-linux-riscv64.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="25.0.0.37"
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/25+37/bellsoft-jdk25+37-linux-ppc64le.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="25.0.0.37"
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/25+37/bellsoft-jdk25+37-linux-x64-musl.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="25.0.0.37"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/25+37/bellsoft-jdk25+37-linux-aarch64-musl.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="25.0.0.37"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
    fi
    if [ "$JAVA_VERSION" = "21" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/21.0.8+12/bellsoft-jdk21.0.8+12-linux-i586.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="21.0.8.12"
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/21.0.8+12/bellsoft-jdk21.0.8+12-linux-amd64.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="21.0.8.12"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/21.0.8+12/bellsoft-jdk21.0.8+12-linux-arm32-vfp-hflt.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="21.0.8.12"
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/21.0.8+12/bellsoft-jdk21.0.8+12-linux-aarch64.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="21.0.8.12"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/21.0.8+12/bellsoft-jdk21.0.8+12-linux-riscv64.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="21.0.8.12"
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/21.0.8+12/bellsoft-jdk21.0.8+12-linux-ppc64le.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="21.0.8.12"
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/21.0.8+12/bellsoft-jdk21.0.8+12-linux-x64-musl.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="21.0.8.12"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/21.0.8+12/bellsoft-jdk21.0.8+12-linux-aarch64-musl.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="21.0.8.12"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
    fi
    if [ "$JAVA_VERSION" = "17" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/17.0.16+12/bellsoft-jdk17.0.16+12-linux-i586.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="17.0.16.12"
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/17.0.16+12/bellsoft-jdk17.0.16+12-linux-amd64.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="17.0.16.12"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/17.0.16+12/bellsoft-jdk17.0.16+12-linux-arm32-vfp-hflt.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="17.0.16.12"
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/17.0.16+12/bellsoft-jdk17.0.16+12-linux-aarch64.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="17.0.16.12"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/17.0.16+12/bellsoft-jdk17.0.16+12-linux-riscv64.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="17.0.16.12"
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/17.0.16+12/bellsoft-jdk17.0.16+12-linux-ppc64le.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="17.0.16.12"
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/17.0.16+12/bellsoft-jdk17.0.16+12-linux-x64-musl.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="17.0.16.12"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/17.0.16+12/bellsoft-jdk17.0.16+12-linux-aarch64-musl.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="17.0.16.12"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
    fi
    if [ "$JAVA_VERSION" = "11" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/11.0.28+12/bellsoft-jdk11.0.28+12-linux-i586.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="11.0.28.12"
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/11.0.28+12/bellsoft-jdk11.0.28+12-linux-amd64.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="11.0.28.12"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/11.0.28+12/bellsoft-jdk11.0.28+12-linux-arm32-vfp-hflt.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="11.0.28.12"
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/11.0.28+12/bellsoft-jdk11.0.28+12-linux-aarch64.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="11.0.28.12"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/11.0.28+12/bellsoft-jdk11.0.28+12-linux-ppc64le.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="11.0.28.12"
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/11.0.28+12/bellsoft-jdk11.0.28+12-linux-x64-musl.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="11.0.28.12"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/11.0.28+12/bellsoft-jdk11.0.28+12-linux-aarch64-musl.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="11.0.28.12"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
    fi
    if [ "$JAVA_VERSION" = "8" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/8u462+11/bellsoft-jdk8u462+11-linux-i586.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="8.0.462.11"
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/8u462+11/bellsoft-jdk8u462+11-linux-amd64.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="8.0.462.11"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/8u462+11/bellsoft-jdk8u462+11-linux-aarch64.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="8.0.462.11"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/8u462+11/bellsoft-jdk8u462+11-linux-ppc64le.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="8.0.462.11"
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/8u462+11/bellsoft-jdk8u462+11-linux-x64-musl.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="8.0.462.11"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://github.com/bell-sw/Liberica/releases/download/8u462+11/bellsoft-jdk8u462+11-linux-aarch64-musl.tar.gz"
          JAVA_TARGET_DISTRO="liberica"
          JAVA_TARGET_VERSION="8.0.462.11"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
    fi
  fi
fi
if [ "$JAVA_URL" = "" ]; then
  if [ "$JAVA_DISTRIBUTION" = "" ] || [ "$JAVA_DISTRIBUTION" = "temurin" ]; then
    if [ "$JAVA_VERSION" = "25" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25%2B36/OpenJDK25U-jdk_x64_linux_hotspot_25_36.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="25.0.0.36"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          JAVA_URL="https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25%2B36/OpenJDK25U-jdk_riscv64_linux_hotspot_25_36.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="25.0.0.36"
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          JAVA_URL="https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25%2B36/OpenJDK25U-jdk_s390x_linux_hotspot_25_36.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="25.0.0.36"
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          JAVA_URL="https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25%2B36/OpenJDK25U-jdk_ppc64le_linux_hotspot_25_36.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="25.0.0.36"
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25%2B36/OpenJDK25U-jdk_x64_alpine-linux_hotspot_25_36.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="25.0.0.36"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25%2B36/OpenJDK25U-jdk_aarch64_alpine-linux_hotspot_25_36.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="25.0.0.36"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
    fi
    if [ "$JAVA_VERSION" = "21" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.8%2B9/OpenJDK21U-jdk_x64_linux_hotspot_21.0.8_9.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="21.0.8.9"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.8%2B9/OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.8_9.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="21.0.8.9"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          JAVA_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.8%2B9/OpenJDK21U-jdk_riscv64_linux_hotspot_21.0.8_9.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="21.0.8.9"
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          JAVA_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.8%2B9/OpenJDK21U-jdk_s390x_linux_hotspot_21.0.8_9.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="21.0.8.9"
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          JAVA_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.8%2B9/OpenJDK21U-jdk_ppc64le_linux_hotspot_21.0.8_9.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="21.0.8.9"
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.8%2B9/OpenJDK21U-jdk_x64_alpine-linux_hotspot_21.0.8_9.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="21.0.8.9"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.8%2B9/OpenJDK21U-jdk_aarch64_alpine-linux_hotspot_21.0.8_9.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="21.0.8.9"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
    fi
    if [ "$JAVA_VERSION" = "17" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.16%2B8/OpenJDK17U-jdk_x64_linux_hotspot_17.0.16_8.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="17.0.16.8"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          JAVA_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.16%2B8/OpenJDK17U-jdk_arm_linux_hotspot_17.0.16_8.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="17.0.16.8"
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.16%2B8/OpenJDK17U-jdk_aarch64_linux_hotspot_17.0.16_8.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="17.0.16.8"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          JAVA_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.16%2B8/OpenJDK17U-jdk_riscv64_linux_hotspot_17.0.16_8.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="17.0.16.8"
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          JAVA_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.16%2B8/OpenJDK17U-jdk_s390x_linux_hotspot_17.0.16_8.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="17.0.16.8"
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          JAVA_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.16%2B8/OpenJDK17U-jdk_ppc64le_linux_hotspot_17.0.16_8.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="17.0.16.8"
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.16%2B8/OpenJDK17U-jdk_x64_alpine-linux_hotspot_17.0.16_8.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="17.0.16.8"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
    fi
    if [ "$JAVA_VERSION" = "11" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.28%2B6/OpenJDK11U-jdk_x64_linux_hotspot_11.0.28_6.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="11.0.28.6"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          JAVA_URL="https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.28%2B6/OpenJDK11U-jdk_arm_linux_hotspot_11.0.28_6.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="11.0.28.6"
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          JAVA_URL="https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.28%2B6/OpenJDK11U-jdk_aarch64_linux_hotspot_11.0.28_6.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="11.0.28.6"
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          JAVA_URL="https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.28%2B6/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.28_6.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="11.0.28.6"
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          JAVA_URL="https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.28%2B6/OpenJDK11U-jdk_ppc64le_linux_hotspot_11.0.28_6.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="11.0.28.6"
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          JAVA_URL="https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.28%2B6/OpenJDK11U-jdk_x64_alpine-linux_hotspot_11.0.28_6.tar.gz"
          JAVA_TARGET_DISTRO="temurin"
          JAVA_TARGET_VERSION="11.0.28.6"
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
    fi
    if [ "$JAVA_VERSION" = "8" ]; then
      if [ "$JAVA_OS" = "linux" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
          : # does not exist
        fi
      fi
      if [ "$JAVA_OS" = "linux_musl" ]; then
        if [ "$JAVA_ARCH" = "x32" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "x64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armel" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "armhf" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "arm64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "riscv64" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "mips64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "s390x" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64le" ]; then
          : # does not exist
        fi
        if [ "$JAVA_ARCH" = "ppc64" ]; then
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
JAVA_TARGET_SYMLINK="jdk-$JAVA_VERSION"
JAVA_TARGET_DIR="$JAVA_TARGET_DISTRO-jdk-$JAVA_TARGET_VERSION"

echo "Installing Java..."
echo "    arch: $JAVA_ARCH"
echo "   c-lib: $CLIB"
echo "     url: $JAVA_URL"
echo "    file: $JAVA_TARBALL_FILE"
echo "    slim: $JAVA_SLIM"
echo " default: $JAVA_DEFAULT"
echo "  distro: $JAVA_TARGET_DISTRO"
echo " version: $JAVA_TARGET_VERSION"
echo "  target: $JAVA_TARGET_DIR"

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

rm -Rf "/usr/lib/jvm/$JAVA_TARGET_DIR"

if ! [ $? -eq 0 ]; then
  echo "Unable to remove /usr/lib/jvm/$JAVA_TARGET_DIR"
  exit 1
fi

if [ "$JAVA_SLIM" = "yes" ]; then
  rm -Rf "$JAVA_DIR/sample"
  rm -Rf "$JAVA_DIR/demo"
  rm -Rf "$JAVA_DIR/src.zip"
  rm -Rf "$JAVA_DIR/legal"
  rm -Rf "$JAVA_DIR/man"
fi

mv "$JAVA_DIR" "/usr/lib/jvm/$JAVA_TARGET_DIR"

if [ $? -ne 0 ]; then
  echo "Unable to mv $JAVA_DIR to /usr/lib/jvm/$JAVA_TARGET_DIR"
  exit 1
fi

# make this the default for the java version symlink
rm -f "/usr/lib/jvm/$JAVA_TARGET_SYMLINK"
ln -s "/usr/lib/jvm/$JAVA_TARGET_DIR" "/usr/lib/jvm/$JAVA_TARGET_SYMLINK"

# make this the default?
if [ "$JAVA_DEFAULT" = "yes" ]; then
  rm -f /usr/lib/jvm/current
  ln -s "/usr/lib/jvm/$JAVA_TARGET_SYMLINK" /usr/lib/jvm/current
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

# Check if the path already exists in secure_path
if ! grep -q "secure_path.*/usr/lib/jvm/current/bin" /etc/sudoers; then
    # If the path doesn't exist, add it to the secure_path line
    # This assumes secure_path is defined with "Defaults secure_path="
    sudo sed "s#^Defaults\s*secure_path=\"\([^\"]*\)\"\(.*\)#Defaults secure_path=\"\1:/usr/lib/jvm/current/bin\"\2#" "/etc/sudoers" > /tmp/sudoers
    sudo mv /tmp/sudoers /etc/sudoers
    #sudo sed -i -r -e '/^\s*Defaults\s+secure_path/ s[=(.*)[=\1:/usr/lib/jvm/current/bin[' /etc/sudoers
    #sudo sed -i -r -e '/^\s*Defaults\s+secure_path/ s[=(.*)[=\1:/usr/lib/jvm/current/bin[' /etc/sudoers
    #sudo sed -i -r "/^Defaults\\s+secure_path/ s[=(.*)[=\\1:$SUDO_PATH[" /etc/sudoers
    echo "Added '/usr/lib/jvm/current/bin' to secure_path in /etc/sudoers"
else
    echo "'/usr/lib/jvm/current/bin' already exists in secure_path in /etc/sudoers"
fi

echo "###########################################################"
echo ""
echo " Installed $JAVA_DIR -> /usr/lib/jvm/$JAVA_TARGET_DIR"
echo ""
/usr/lib/jvm/$JAVA_TARGET_DIR/bin/java -version
echo "###########################################################"
