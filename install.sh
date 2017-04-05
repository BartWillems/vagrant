#!/bin/sh

# This installs the .NET Core dependencies. Quamotion ships with .NET Core, so you don't need to install
# .NET Core itself, but its dependencies must be installed manually.
# This script is based on the .NET Core docker images: 
# https://github.com/dotnet/dotnet-docker/blob/master/1.1/debian/runtime/Dockerfile
apt-get update
apt-get install -y libc6 libcurl3 libgcc1 libgssapi-krb5-2 libicu55 liblttng-ust0 libssl1.0.0 libstdc++6 libunwind8 libuuid1 zlib1g
echo "ubuntu:ubuntu" | chpasswd

# Install python for simple scripting
apt-get install -y python python-pip
pip install quamotion

# usbmuxd enables connections to iOS devices
apt-get install -y usbmuxd
apt-get install -y jq libimobiledevice-utils

# Download and install the Quamotion software
wget -nv -nc https://qmcdn.blob.core.windows.net/download/quamotion-webdriver.0.1.6515-ubuntu.16.04-x64.tar.gz -O ~/quamotion-webdriver.0.1.6515-ubuntu.16.04-x64.tar.gz
mkdir -p /usr/share/quamotion/
tar -C /usr/share/quamotion/ -xzf ~/quamotion-webdriver.0.1.6515-ubuntu.16.04-x64.tar.gz

# Listen on all IP addresses; port forwarding on VMs arrives on the interface connected to the vLAN which has
# a non-loopback IP
cat /usr/share/quamotion/appsettings.json | jq '.webdriver.webDriverUrl="http://0.0.0.0:17894"' | tee /usr/share/quamotion/appsettings.json > /dev/null

# Enable running as a SystemD service
mkdir -p /usr/lib/systemd/system/
cp /vagrant/quamotion.service /usr/lib/systemd/system/
cp /vagrant/quamotion.sudoers /etc/sudoers.d/

# Good to go!
systemctl start quamotion