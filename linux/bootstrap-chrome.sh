#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

#=========================================================
echo "Install XvFB..."
#=========================================================
apt-get -y install xvfb
/usr/bin/Xvfb :99 -screen 0 1024x768x24

#=========================================================
echo "Download the latest chrome..."
#=========================================================
wget "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb
apt-get install -y -f

#=========================================================
#echo "Download latest chrome driver..."
#=========================================================
#CHROMEDRIVER_VERSION=$(curl "http://chromedriver.storage.googleapis.com/LATEST_RELEASE")
#wget "http://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip"
#unzip chromedriver_linux64.zip
#rm chromedriver_linux64.zip
#chown vagrant:vagrant chromedriver



