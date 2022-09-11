Vagrant.configure("2") do |config|
	config.vm.box = "ubuntu/jammy64"

    config.vm.network "forwarded_port", guest: 80, host: 80
    config.vm.network "forwarded_port", guest: 443, host: 443

	config.vm.provider "virtualbox" do |vb|
		vb.name = "ssl.local.x-shell.codes"
		vb.cpus = 1
		vb.memory = 4096
	end
end
