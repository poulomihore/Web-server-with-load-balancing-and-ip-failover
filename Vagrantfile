
Vagrant.configure("2") do |config|

	config.vm.define "vm1" do |node|
    		node.vm.box="centos/7"
    		node.vm.hostname="centos1"
		node.vm.network :private_network, libvirt__network_name: "lab-isolate", mac: "52:54:00:e1:97:99"
	end
	config.vm.define "vm2" do |node|
    		node.vm.box="centos/7"
    		node.vm.hostname="centos2"
		node.vm.network :private_network, libvirt__network_name: "lab-isolate", mac: "52:54:00:31:dc:dc", auto_config: false 
		node.vm.network :public_network, :dev => "enp2s0"
	end

	config.vm.define "vm3" do |node|
    		node.vm.box="centos/7"
    		node.vm.hostname="centos3"
		node.vm.network :private_network, libvirt__network_name: "lab-isolate", mac: "52:54:00:22:ba:6b"
	end
	config.vm.define "vm4" do |node|
    		node.vm.box="centos/7"
    		node.vm.hostname="centos4"
		node.vm.network :private_network, libvirt__network_name: "lab-isolate", mac: "52:54:00:fe:18:44"
	end

	config.vm.define "vm5" do |node|
		node.vm.box="centos/7"
		node.vm.hostname="centos5"
		node.vm.network :private_network, libvirt__network_name: "lab-isolate", mac: "52:54:00:00:e3:2a"
	end
	config.vm.define "vm6" do |node|
    		node.vm.box="centos/7"
    		node.vm.hostname="centos6"
		node.vm.network :private_network, libvirt__network_name: "lab-isolate", mac: "52:54:00:72:1a:6f"
	end

	config.vm.define "vm7" do |node|
		node.vm.box="centos/7"
		node.vm.hostname="centos7"
		node.vm.network :private_network, libvirt__network_name: "lab-isolate", mac: "52:54:00:82:00:59"
	end
#####################################################################################
	config.vm.provision "ansible" do |ansible|
		ansible.playbook = "playbook.yml"
		ansible.groups = {
			"dns" => ["vm3"],
			"web" => ["vm4", "vm5"],
			"lb" => ["vm6", "vm7"]
		}
	end
#####################################################################################
	config.vm.provider "libvirt" do |libvirt|
		libvirt.management_network_name="vagrant-mgmt"
		libvirt.management_network_address="172.16.100.0/24"
		libvirt.management_network_mode="none"
	
	end








end
