# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_check_update = true

  config.vm.provider "virtualbox" do |vb|
     vb.memory = 4096
     vb.cpus = 2
     vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
     vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  config.vm.provider "hyperv" do |v, override|
     override.vm.box = "withinboredom/Trusty64"
     v.memory = 4096
     v.cpus = 2
  end

  config.vm.provision "shell", inline: <<-SHELL
  		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  		add-apt-repository \
   				"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   				$(lsb_release -cs) \
   				stable"
  		apt-get update
  		apt-get install -y linux-image-extra-$(uname -r) \
  				linux-image-extra-virtual \
  				apt-transport-https \
  				ca-certificates \
  				curl \
          make \
  				software-properties-common
  		apt-get install -y docker-ce
  		groupadd docker
  		usermod -aG docker vagrant

  		curl -L https://github.com/docker/compose/releases/download/1.14.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
  		chmod +x /usr/local/bin/docker-compose
  		curl -L https://github.com/docker/machine/releases/download/v0.12.1/docker-machine-`uname -s`-`uname -m` >/usr/local/bin/docker-machine
  		chmod +x /usr/local/bin/docker-machine
  		echo "export DO_TOKEN=REPLACE_WITH_TOKEN" >> /home/vagrant/.bashrc
  SHELL
end