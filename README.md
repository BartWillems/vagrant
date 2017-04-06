Automate iOS and Android devices using Quamotion
================================================

This repository contains Vagrant scripts for creating a new VirtualBox virtual machine, capable
of automating iOS and Android devices using Quamotion.

The VM includes Quamotion, running as a SystemD service, and the Python interface, which you can use
for writing test automation scripts.

Requirements
------------

To use this Vagrant box, you'll need to install:
* [VirtualBox and the VirtualBox extension pack](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant](https://www.vagrantup.com/)
* A Git client

Getting started
---------------

```
cd ~/
git clone https://github.com/quamotion/vagrant
cd vagrant
vagrant up
```

Navigate to http://localhost:8081/ to make sure the Vagrant box is working correctly.

If you want to open a SSH connection to the VM, just type `vagrant ssh`.

Prepopulating your Vagrant box
------------------------------

For the best experience, you can prepopulate your Vagrant box with iOS Developer Disk images,
a Quamotion license and applications.

To copy the iOS Developer Disk images, run the following command:

```
mkdir -p devimg
cp -r /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/* devimg/
```