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

Running a script
----------------

To run a demo script, first SSH into your box:

```
vagrant ssh
```

Then, launch the demo-ios.py Python script:

```
/vagrant/demo-ios.py
```

Useful commands
---------------

Start, restart and stop the Quamotion service:

```
sudo systemctl start quamotion
sudo systemctl restart quamotion
sudo systemctl stop quamotion
```

To enable or disable the front-end, edit `/usr/share/quamotion/appsettings.json` and set the `frontendEnabled` value to `true` or `false.

Procedure for connecting an iOS device
--------------------------------------

* Open VirtualBox
* Open the settings for your Vagrant VM
* Click USB
* Add your iPhome to your VM
* You may need to unplug and reconnect your iPhone
* On your iPhone, trust your VM if required
* Restart the Quamotion service if required
* In the WebDriver, make sure the device is visible and open the remote screen
* On your device, go to Settings, Developer and active the Enable UI Automation options

Monitoring Scripts with Centreon
--------------------------------

Monitoring the output of scripts with Centreon is easy! We recommend you execute your scripts remotely using
SSH.

To do so:

* On your Centreon machine, set up a SSH which allows the poller to remotely connect to your WebDriver box:
  ```
  sudo su - centreon-engine
  ssh-keygen -t rsa
  ssh-copy-id {user}@{WebDriver-host}
  ```
* Under _Configuration_, _Commands_, add a new Check command which executes your script:
  ```
  $USER1$/check_by_ssh -H {WebDriver-host} -l {user} -C "{path_to_your_script}"
  ```
* Configure your host to use this script, or create a new service which uses this script
* [Deploy your configuration](https://documentation.centreon.com/docs/centreon/en/latest/configuration_guide/deploy.html#deployconfiguration)

Documentation
-------------

* [Selenium with Python](http://selenium-python.readthedocs.io/)