#!/bin/sh

mkdir -p ~/git/

apt-get install -y build-essential autoconf libtool pkg-config libssl-dev libusb-1.0-0-dev

git clone https://github.com/libimobiledevice/libplist ~/git/libplist
git clone https://github.com/libimobiledevice/libusbmuxd ~/git/libusbmuxd
git clone https://github.com/libimobiledevice/libimobiledevice ~/git/libimobiledevice
git clone https://github.com/libimobiledevice/usbmuxd ~/git/usbmuxd

cd ~/git/libplist
./autogen.sh --prefix=/usr/
make
make install

cd ~/git/libusbmuxd
./autogen.sh --prefix=/usr/
make
make install

cd ~/git/libimobiledevice
./autogen.sh --prefix=/usr/
make
make install

cd ~/git/usbmuxd
./autogen.sh --prefix=/usr/
make
make install
