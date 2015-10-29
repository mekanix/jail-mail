# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.define "mail" do |mail|
        mail.vm.box = "debian-8.0"
        mail.vm.box_url = "ftp://ftp.lugons.org/vagrant/debian-8.0-x86_64.box"
        mail.vm.network :private_network, ip: "192.168.17.10"
        mail.vm.hostname = "vagrant.mail.tilda.center"
        mail.hostsupdater.aliases = ["vagrant.mailman.tilda.center"]
        mail.vm.provision :ansible do |ansible|
            ansible.playbook = "provision/site.yml"
            ansible.host_key_checking = false
            ansible.groups = {
                "vagrant" => ["mail"],
            }
        end
    end
end
