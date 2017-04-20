#!/bin/sh

# Set a default password
echo "ubuntu:ubuntu" | chpasswd

# The version of usbmuxd which comes with Ubuntu 16.04 is slightly outdated; we publish a PPA archive with
# udpated binaries. Alternatively, you can install from source or just use the inbox version
# /vagrant/install-usbmuxd.sh
add-apt-repository -y ppa:quamotion/ppa
apt-get update
apt-get install -y usbmuxd libimobiledevice-utils

# This installs the .NET Core dependencies. Quamotion ships with .NET Core, so you don't need to install
# .NET Core itself, but its dependencies must be installed manually.
# This script is based on the .NET Core docker images: 
# https://github.com/dotnet/dotnet-docker/blob/master/1.1/debian/runtime/Dockerfile
apt-get install -y libc6 libcurl3 libgcc1 libgssapi-krb5-2 libicu55 liblttng-ust0 libssl1.0.0 libstdc++6 libunwind8 libuuid1 zlib1g

# Install python for simple scripting
apt-get install -y python3 python3-pip
pip3 install selenium quamotion

# android-sdk-platform-tools-common adds udev rules for Android devices;
# jq is used for scripting
apt-get install -y android-sdk-platform-tools-common
apt-get install -y libgdiplus
apt-get install -y jq

# Download and install the Quamotion software
version=0.1.6573
wget -nv -nc https://qmcdn.blob.core.windows.net/download/quamotion-webdriver.$version-ubuntu.16.04-x64.tar.gz -O /vagrant/quamotion-webdriver.$version-ubuntu.16.04-x64.tar.gz
mkdir -p /usr/share/quamotion/
tar -C /usr/share/quamotion/ -xzf /vagrant/quamotion-webdriver.$version-ubuntu.16.04-x64.tar.gz

# Use the official Ubuntu files for these dependencies
rm /usr/share/quamotion/libcairo.so.2
ln -s /usr/lib/x86_64-linux-gnu/libcairo.so.2 /usr/share/quamotion/libcairo.so.2

rm /usr/share/quamotion/libexif.so.12
ln -s /usr/lib/x86_64-linux-gnu/libexif.so.12 /usr/share/quamotion/libexif.so.12

rm /usr/share/quamotion/libfontconfig.so.1
ln -s /usr/lib/x86_64-linux-gnu/libfontconfig.so.1 /usr/share/quamotion/libfontconfig.so.1

rm /usr/share/quamotion/libfreetype.so.6
ln -s /usr/lib/x86_64-linux-gnu/libfreetype.so.6 /usr/share/quamotion/libfreetype.so.6

rm /usr/share/quamotion/libgdiplus.so
ln -s /usr/lib/libgdiplus.so /usr/share/quamotion/libgdiplus.so

rm /usr/share/quamotion/libgif.so.7
ln -s /usr/lib/x86_64-linux-gnu/libgif.so.7 /usr/share/quamotion/libgif.so.7

rm /usr/share/quamotion/libjpeg.so.8
ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so.8 /usr/share/quamotion/libjpeg.so.8

rm /usr/share/quamotion/libpixman-1.so.0
ln -s /usr/lib/x86_64-linux-gnu/libpixman-1.so.0 /usr/share/quamotion/libpixman-1.so.0

rm /usr/share/quamotion/libpng12.so.0
ln -s /usr/lib/x86_64-linux-gnu/libpng12.so.0 /usr/share/quamotion/libpng12.so.0

rm /usr/share/quamotion/libtiff.so.5
ln -s /usr/lib/x86_64-linux-gnu/libtiff.so.5 /usr/share/quamotion/libtiff.so.5

# Listen on all IP addresses; port forwarding on VMs arrives on the interface connected to the vLAN which has
# a non-loopback IP
cat /usr/share/quamotion/appsettings.json | jq '.webdriver.webDriverUrl="http://0.0.0.0:17894"' | tee /usr/share/quamotion/appsettings.tmp.json > /dev/null
cat /usr/share/quamotion/appsettings.tmp.json | jq '.webdriver.frontendEnabled=true' | tee /usr/share/quamotion/appsettings.json > /dev/null
rm /usr/share/quamotion/appsettings.tmp.json

# Enable running as a SystemD service
mkdir -p /usr/lib/systemd/system/
cp /vagrant/quamotion.service /usr/lib/systemd/system/
cp /vagrant/quamotion.sudoers /etc/sudoers.d/

# If available, copy the Quamotion license file, the iOS developer disk images
# and apps to the 
mkdir -p /usr/share/quamotion/App_Data/
mkdir -p /usr/share/quamotion/App_Data/apps/
mkdir -p /usr/share/quamotion/App_Data/devimg/

if [ -f /vagrant/.license ]; then
   cp /vagrant/.license /usr/share/quamotion/App_Data/
fi

if [ -d /vagrant/devimg ]; then
   cp -r /vagrant/devimg/ /usr/share/quamotion/App_Data/
fi

if [ -d /vagrant/apps ]; then
   cp -r /vagrant/apps/ /usr/share/quamotion/App_Data/
fi

chown -R ubuntu /usr/share/quamotion/App_Data/

# Good to go!
# Enable the quamotion service so that it persists between reboots
systemctl enable --now quamotion
