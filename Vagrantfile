# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.define "mail" do |mail|
        mail.vm.box = "debian-8.2"
        mail.vm.box_url = "https://github.com/one-love/vagrant-base-box/releases/download/v0.1-alpha/debian-8.2-x86_64.box"
        mail.vm.network :private_network, ip: "192.168.17.10"
        mail.vm.hostname = "vagrant.mail.tilda.center"
        mail.vm.network "forwarded_port", guest: 5232, host: 5232
        mail.hostsupdater.aliases = [
            "vagrant.mailman.tilda.center",
            "vagrant.jabber.tilda.center",
        ]
        mail.vm.provision :ansible do |ansible|
            ansible.playbook = "provision/site.yml"
            ansible.host_key_checking = false
            ansible.groups = {
                "vagrant" => ["mail"],
            }
        end
    end
end
