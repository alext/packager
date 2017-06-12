# -*- mode: ruby -*-
# vi: set ft=ruby:

MEMSIZE = "1024"
NCPU = "2"

Vagrant.configure("2") do |config|

  config.vm.hostname = "packager"

  config.vm.box = "ubuntu/xenial64"

  config.vm.provider :virtualbox do |vb|
    vb.customize [ "modifyvm", :id, "--memory", MEMSIZE, "--cpus", NCPU ]
    vb.customize ["modifyvm", :id, "--rtcuseutc", "on"]
  end

  config.vm.synced_folder ".", "/home/ubuntu/packager"

  $stderr.puts "WARNING: The guest has access to your ~/.gnupg directory"
  config.vm.synced_folder "~/.gnupg", "/home/ubuntu/.gnupg"

  config.vm.provision :shell, :path => "tools/bootstrap"

  if File.exist? 'Vagrantfile.local'
    instance_eval File.read('Vagrantfile.local'), 'Vagrantfile.local'
  end

end
