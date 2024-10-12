Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.network "private_network", ip: "192.168.100.10"
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 7077, host: 7077
  config.vm.network "forwarded_port", guest: 50070, host: 50070
  config.vm.hostname = "spark-cluster"
  config.disksize.size = '20GB'
  config.vm.provider "virtualbox" do |vb|
      vb.memory = "7168"
      vb.cpus = 6
 end
 config.vm.provision "shell", path: "set-up.sh"
 end
