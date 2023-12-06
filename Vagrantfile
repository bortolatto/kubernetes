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

    config.vm.define "kubemaster" do |node|
      node.vm.box = "ubuntu/focal64"
      node.vm.network "private_network", ip: "192.168.56.32"
      node.vm.hostname = "kubemaster"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = "2048"
        vb.name = "kubemaster"
        vb.cpus = 2
      end
      config.vm.provision "ansible" do |ansible|
        ansible.playbook = "ansible/containerd-install.yml"        
      end
      config.vm.provision "ansible" do |ansible|
        ansible.playbook = "ansible/kubeadm-install.yml"        
      end
      config.vm.provision "ansible" do |ansible|
        ansible.playbook = "ansible/kubeadm-bootstrap.yml"        
      end
    end

    config.vm.define "kubenode01" do |node|
      node.vm.box = "ubuntu/focal64"
      node.vm.network "private_network", ip: "192.168.56.33"
      node.vm.hostname = "kubenode01"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = "2048"
        vb.name = "kubenode01"
        vb.cpus = 2
      end
      config.vm.provision "ansible" do |ansible|
        ansible.playbook = "ansible/containerd-install.yml"        
      end
      config.vm.provision "ansible" do |ansible|
        ansible.playbook = "ansible/kubeadm-install.yml"        
      end
    end
#
    #config.vm.define "kubenode02" do |node|
    #  node.vm.box = "ubuntu/focal64"
    #  node.vm.network "private_network", ip: "192.168.56.34"
    #  node.vm.hostname = "kubenode02"
    #  node.vm.provider "virtualbox" do |vb|
    #    vb.memory = "2048"
    #    vb.name = "kubenode02"
    #    vb.cpus = 2
    #  end
    #end

end