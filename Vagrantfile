Vagrant.configure(2) do |config|
    config.vm.define "node1" do |node1|
        node1.vm.box = "bento/ubuntu-16.04"

        # disable the synced folders because Windows doesn't like rsync
        # CentOS hack: https://github.com/mitchellh/vagrant/issues/6154
        # not using CentOS now, but that might change :)
        config.vm.synced_folder ".", "/home/vagrant/sync", disabled: true
        config.vm.synced_folder '.', '/vagrant', disabled: true

        # config.vm.network "forwarded_port", guest: 80, host: 8080
        # config.vm.network "forwarded_port", guest: 3000, host: 3000
        node1.vm.hostname = "node1"
        # For logging in through SSH, use username vagrant, password vagrant

        config.vm.provider "virtualbox" do |vb|
            vb.gui = true

            # http://www.virtualbox.org/manual/ch08.html
            # http://portalstack.blogspot.com/2013/11/vagrant-virtualbox-ubuntu-for-linux.html
            # not sure how much these help, but they don't seem to hurt :)
            vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
            vb.customize ["modifyvm", :id, "--cpus", "4"]
            vb.customize ["modifyvm", :id, "--ioapic", "on"]
            # google and vs-code depend on no graphics acceleration (or use the --disable-gpu flag)
            # vb.customize ["modifyvm", :id, "--accelerate3d", "off"]
            vb.customize ["modifyvm", :id, "--vram", "128"]
            # requres virtualbox extension pack
            vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
            vb.memory = "4096"
        end
        # Ansible chokes without this. I don't know why
        # Needs privileged: false to avoid an error
        config.vm.provision "shell", privileged: false, inline: "sudo mkdir -p /vagrant"
        # no synced folder, so we put the playbook on there manually
        config.vm.provision "file", source: "./playbook.yml", destination: "/tmp/playbook.yml"
        config.vm.provision "ansible_local" do |ansible|
            ansible.playbook = "/tmp/playbook.yml"
        end
    end
end
