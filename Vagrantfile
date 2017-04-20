# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # We use Ubuntu 16.04. You should be free to update to a more recent version of the Ubuntu
  # 16.04 Vagrant box at any time; we pin a specific version here to make the builds reproducable.
  config.vm.box = "ubuntu/xenial64"
  config.vm.box_version = "20170419.0.0"

  config.vm.network "forwarded_port", guest: 17894, host: 8081

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "1024"
    vb.cpus = "2"

    vb.customize ["modifyvm", :id, "--usb", "on"]
    vb.customize ["modifyvm", :id, "--usbehci", "on"]
  end

  config.vm.provision "shell", path: "install.sh"
end
