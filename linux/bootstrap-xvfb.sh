#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

#=========================================================
echo "Install Xvfb..."
#=========================================================
apt-get update
apt-get -y install xvfb xdotool x11vnc

cat << EOF > /etc/init.d/Xvfb
#! /bin/sh
### BEGIN INIT INFO
# Provides:          Xvfb
# Required-Start:    \$remote_fs \$syslog
# Required-Stop:     \$remote_fs \$syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Xvfb
# Description:       Init script for Xvfb
### END INIT INFO

# Do NOT "set -e"

DESC="Xvfb"
NAME=Xvfb
DAEMON=/usr/bin/\$NAME
SCRIPTNAME=/etc/init.d/\$NAME

#DAEMON_OPTS=":99 -ac -screen 0 1024x768x24"
DAEMON_OPTS=":99 -ac -screen 0 1366x768x24"

# exit if the package is not installed
if [ ! -x "\$DAEMON" ]; then
  echo "Xvfb is not installed. \$DAEMON is missing"
  exit 1
fi

# Read configuration variable file if it is present
[ -r /etc/default/\$NAME ] && . /etc/default/\$NAME

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.0-6) to ensure that this file is present.
. /lib/lsb/init-functions

if [ -z "\$1" ]; then
  echo "/etc/init.d/Xvfb {start|stop}"
  exit
fi

case "\$1" in
  start)
    \$DAEMON \$DAEMON_OPTS > /dev/null 2>/dev/null &
    ;;
  stop)
    killall \$NAME
    ;;
  *)
    echo "Invalid arg!"
    ;;
esac
EOF


# run at startup
chmod +x /etc/init.d/Xvfb
update-rc.d Xvfb defaults

# run now
service Xvfb start

