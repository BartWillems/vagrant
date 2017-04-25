#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as a root user!"
    exit 1
fi

# Folder in which to install Quamotion
prefix=/usr/local/share

# Set a default password
echo "vagrant:vagrant" | chpasswd

yum install -y nano # Your favourite text editor here
yum install -y psmisc # provides killall
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
mkdir -p $prefix/quamotion/
tar -C $prefix/quamotion/ -xzf /vagrant/quamotion-webdriver.$version-rhel.7-x64.tar.gz

# Listen on all IP addresses; port forwarding on VMs arrives on the interface connected to the vLAN which has
# a non-loopback IP
cat $prefix/quamotion/appsettings.json | jq '.webdriver.webDriverUrl="http://0.0.0.0:17894"' | tee $prefix/quamotion/appsettings.tmp.json > /dev/null
cat $prefix/quamotion/appsettings.tmp.json | jq '.webdriver.frontendEnabled=true' | tee $prefix/quamotion/appsettings.json > /dev/null
rm $prefix/quamotion/appsettings.tmp.json

mkdir -p /usr/lib/systemd/system/
cp /vagrant/quamotion.service /usr/lib/systemd/system/

# If available, copy the Quamotion license file, the iOS developer disk images
# and apps to the 
mkdir -p $prefix/quamotion/App_Data/
mkdir -p $prefix/quamotion/App_Data/apps/
mkdir -p $prefix/quamotion/App_Data/devimg/

if [ -f /qmdata/.license ]; then
   cp /qmdata/.license $prefix/quamotion/App_Data/
fi

if [ -d /qmdata/devimg ]; then
   cp -r /qmdata/devimg/ $prefix/quamotion/App_Data/
fi

if [ -d /qmdata/apps ]; then
   cp -r /qmdata/apps/ $prefix/quamotion/App_Data/
fi

chown -R vagrant $prefix/quamotion/App_Data/

# These files came via yum, so we don't need them in the Quamotion folder. We're likely to remove
# the these dependencies from our packages alltogether and just take a dependency on the various
# Linux distribution packages
rm $prefix/quamotion/idevice*
rm $prefix/quamotion/iproxy
rm $prefix/quamotion/libcairo.so.2
rm $prefix/quamotion/libexif.so.12
rm $prefix/quamotion/libfontconfig.so.1
rm $prefix/quamotion/libfreetype.so.6
rm $prefix/quamotion/libgdiplus.so
rm $prefix/quamotion/libgif.so.7
rm $prefix/quamotion/libglib-2.0.so.0
rm $prefix/quamotion/libimobiledevice.so
rm $prefix/quamotion/libjpeg.so.8
rm $prefix/quamotion/libpixman-1.so.0
rm $prefix/quamotion/libpng12.so.0
rm $prefix/quamotion/libtiff.so.5
rm $prefix/quamotion/plistutil
rm $prefix/quamotion/usbmuxd

ln -s /usr/bin/idevice_id $prefix/quamotion/idevice_id
ln -s /usr/bin/idevicebackup $prefix/quamotion/idevicebackup
ln -s /usr/bin/idevicebackup2 $prefix/quamotion/idevicebackup2
ln -s /usr/bin/idevicecrashreport $prefix/quamotion/idevicecrashreport
ln -s /usr/bin/idevicedate $prefix/quamotion/idevicedate
ln -s /usr/bin/idevicedebug $prefix/quamotion/idevicedebug
ln -s /usr/bin/idevicedebugserverproxy $prefix/quamotion/idevicedebugserverproxy
ln -s /usr/bin/idevicediagnostics $prefix/quamotion/idevicediagnostics
ln -s /usr/bin/ideviceenterrecovery $prefix/quamotion/ideviceenterrecovery
ln -s /usr/bin/ideviceimagemounter $prefix/quamotion/ideviceimagemounter
ln -s /usr/bin/ideviceinfo $prefix/quamotion/ideviceinfo
ln -s /usr/bin/idevicename $prefix/quamotion/idevicename
ln -s /usr/bin/idevicenotificationproxy $prefix/quamotion/idevicenotificationproxy
ln -s /usr/bin/idevicepair $prefix/quamotion/idevicepair
ln -s /usr/bin/ideviceprovision $prefix/quamotion/ideviceprovision
ln -s /usr/bin/idevicescreenshot $prefix/quamotion/idevicescreenshot
ln -s /usr/bin/idevicesyslog $prefix/quamotion/idevicesyslog

ln -s /usr/bin/iproxy $prefix/quamotion/iproxy
ln -s /usr/lib64/libcairo.so.2 $prefix/quamotion/libcairo.so.2
ln -s /usr/lib64/libexif.so.12 $prefix/quamotion/libexif.so.12
ln -s /usr/lib64/libfontconfig.so.1 $prefix/quamotion/libfontconfig.so.1
ln -s /usr/lib64/libfreetype.so.6 $prefix/quamotion/libfreetype.so.6
ln -s /usr/lib64/libgdiplus.so.0 $prefix/quamotion/libgdiplus.so
ln -s /usr/lib64/libgif.so.4 $prefix/quamotion/libgif.so.7
ln -s /usr/lib64/libglib-2.0.so.0 $prefix/quamotion/libglib-2.0.so.0
ln -s /usr/lib64/libimobiledevice.so $prefix/quamotion/libimobiledevice.so
ln -s /usr/lib64/libjpeg.so.62 $prefix/quamotion/libjpeg.so.8
ln -s /usr/lib64/libpixman-1.so.0 $prefix/quamotion/libpixman-1.so.0
ln -s /usr/lib64/libpng15.so.15 $prefix/quamotion/libpng12.so.0
ln -s /usr/lib64/libtiff.so.5 $prefix/quamotion/libtiff.so.5
ln -s /usr/bin/plistutil $prefix/quamotion/plistutil
ln -s /usr/sbin/usbmuxd $prefix/quamotion/usbmuxd

# Good to go!
# Enable the quamotion service so that it persists between reboots
systemctl enable --now quamotion