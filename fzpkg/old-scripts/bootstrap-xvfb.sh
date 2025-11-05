#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

#=========================================================
echo "Install Xvfb..."
#=========================================================
apt-get update
apt-get -y install xvfb xdotool x11vnc

cat << EOF > /etc/systemd/system/Xvfb.service
[Unit]
Description=X Virtual Frame Buffer Service
After=network.target
StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
Restart=on-failure
RestartSec=2s
ExecStart=/usr/bin/Xvfb :99 -ac -screen 0 1366x768x24

[Install]
WantedBy=multi-user.target
EOF

# run at startup
systemctl daemon-reload
systemctl enable Xvfb.service

# run now
systemctl start Xvfb.service
