# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/focal64"

    config.vm.define "master" do |master|
      master.vm.box = "ubuntu/focal64"
      master.vm.network "private_network", ip: "192.168.56.2"
      master.vm.hostname = "kubemaster"
      master.vm.provider "virtualbox" do |vb|
        vb.memory = "2048"
        vb.name = "kubemaster"
        vb.cpus = 2
      end
      master.vm.provision "shell" do |sh|
        sh.args = ["enp0s8"]
        sh.path = "configura-host.sh"
      end
      master.vm.provision "shell", path: "dns.sh"
    end

    config.vm.define "node1" do |node1|
      node1.vm.box = "ubuntu/focal64"
      node1.vm.network "private_network", ip: "192.168.56.3"
      node1.vm.hostname = "kubenode1"
      node1.vm.provider "virtualbox" do |vb|
        vb.memory = "2048"
        vb.name = "kubenode1"
        vb.cpus = 2
      end
      node1.vm.provision "shell" do |sh|
        sh.args = ["enp0s8"]
        sh.path = "configura-host.sh"
      end
      node1.vm.provision "shell", path: "dns.sh"
    end

    config.vm.define "node2" do |node2|
      node2.vm.box = "ubuntu/focal64"
      node2.vm.network "private_network", ip: "192.168.56.4"
      node2.vm.hostname = "kubenode2"
      node2.vm.provider "virtualbox" do |vb|
        vb.memory = "2048"
        vb.name = "kubenode2"
        vb.cpus = 2
      end
      node2.vm.provision "shell" do |sh|
        sh.args = ["enp0s8"]
        sh.path = "configura-host.sh"
      end
      node2.vm.provision "shell", path: "dns.sh"
    end
    
end
