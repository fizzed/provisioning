#!/bin/bash

# https://devpress.csdn.net/cloudnative/62f2dd72c6770329307f7265.html
wget https://github.com/traefik/traefik/releases/download/v3.0.0-beta4/traefik_v3.0.0-beta4_linux_amd64.tar.gz
tar zxvf ./traefik_v3.0.0-beta4_linux_amd64.tar.gz

cp ./traefik /usr/local/bin
chown root:root /usr/local/bin/traefik
chmod 755 /usr/local/bin/traefik

# give the traefik binary the ability to bind to privileged ports (80, 443) as non-root
setcap 'cap_net_bind_service=+ep' /usr/local/bin/traefik

useradd --shell /usr/sbin/nologin -r traefik

mkdir -p /etc/traefik
mkdir -p /etc/traefik/acme
mkdir -p /etc/traefik/dynamic
chown -R root:root /etc/traefik

touch /var/log/traefik.log
chown traefik:traefik /var/log/traefik.log

if [ ! -f /etc/traefik/traefik.yaml ]; then
cat <<EOF > /etc/traefik/traefik.yaml
global:
  checkNewVersion: false
  sendAnonymousUsage: false

api:
  dashboard: true

entryPoints:
  http:
    address: ":80"

  https:
    address: ":443"
    http2:
      maxConcurrentStreams: 250
    http:
      tls: {}

providers:
  file:
    directory: "/etc/traefik/dynamic/"
    watch: true

log:
  level: INFO
  filePath: "/var/log/traefik.log"
EOF
fi


chown -R traefik:traefik /etc/traefik/*



cat <<EOF > /etc/systemd/system/traefik.service
[Unit]
Description=traefik proxy
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service

[Service]
Restart=on-abnormal
User=traefik
Group=traefik
ExecStart=/usr/local/bin/traefik --configfile=/etc/traefik/traefik.yaml
LimitNOFILE=1048576
PrivateTmp=true
PrivateDevices=false
ProtectHome=true
ProtectSystem=full
ReadWriteDirectories=/etc/traefik/acme
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

chown root:root /etc/systemd/system/traefik.service
chmod 644 /etc/systemd/system/traefik.service
systemctl daemon-reload
systemctl start traefik.service
