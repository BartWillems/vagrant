#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as a root user!"
    exit 1
fi

# Set a default password
echo "vagrant:vagrant" | chpasswd

yum install -y libunwind gettext libcurl-devel openssl-devel zlib libicu-devel

yum install -y epel-release
yum install -y python34 python34-pip
pip3 install selenium quamotion

yum install -y android-tools
yum install -y libgdiplus
yum install -y jq

# Download updated versions of libimobiledevice, usbmuxd
wget -nv -nc http://download.opensuse.org/repositories/home:qmfrederik/RHEL_7/home:qmfrederik.repo -O /etc/yum.repos.d/quamotion.repo
yum install -y libimobiledevice-devel usbmuxd

# Download the Quamotion software
version=0.1.6573
wget -nv -nc https://qmcdn.blob.core.windows.net/download/quamotion-webdriver.$version-rhel.7.0-x64.tar.gz -O /vagrant/quamotion-webdriver.$version-rhel.7-x64.tar.gz
mkdir -p /usr/local/share/quamotion/
tar -C /usr/local/share/quamotion/ -xzf /vagrant/quamotion-webdriver.$version-rhel.7-x64.tar.gz

# Listen on all IP addresses; port forwarding on VMs arrives on the interface connected to the vLAN which has
# a non-loopback IP
cat /usr/local/share/quamotion/appsettings.json | jq '.webdriver.webDriverUrl="http://0.0.0.0:17894"' | tee /usr/local/share/quamotion/appsettings.tmp.json > /dev/null
cat /usr/local/share/quamotion/appsettings.tmp.json | jq '.webdriver.frontendEnabled=true' | tee /usr/local/share/quamotion/appsettings.json > /dev/null
rm /usr/local/share/quamotion/appsettings.tmp.json

mkdir -p /usr/lib/systemd/system/
cp /vagrant/quamotion.service /usr/lib/systemd/system/

# If available, copy the Quamotion license file, the iOS developer disk images
# and apps to the 
mkdir -p /usr/local/share/quamotion/App_Data/
mkdir -p /usr/local/share/quamotion/App_Data/apps/
mkdir -p /usr/local/share/quamotion/App_Data/devimg/

if [ -f /vagrant/.license ]; then
   cp /vagrant/.license /usr/local/share/quamotion/App_Data/
fi

if [ -d /vagrant/devimg ]; then
   cp -r /vagrant/devimg/ /usr/local/share/quamotion/App_Data/
fi

if [ -d /vagrant/apps ]; then
   cp -r /vagrant/apps/ /usr/local/share/quamotion/App_Data/
fi

chown -R vagrant /usr/local/share/quamotion/App_Data/

# Good to go!
# Enable the quamotion service so that it persists between reboots
systemctl enable --now quamotion