# Webserver with load balancing and ip failover 

### Aim: 

The main aim of the project is to provide a web server as service to clients. Since uninterrupted service is desirable, load balancing and high availability has been implemented as well.

### Description:

- **Infrastructure**

There is only one physical machine(running CentOS Linux 7) involved in the whole project. The rest of the infrastructure has been implemented using virtualization.  
_Libvirt_,an open source API has been used for this purpose. It manages _KVM/QEMU_. Although used quite interchangibly, QEMU is a hypervisor/emulator whereas KVM is a special operating mode of QEMU that uses CPU extensions(HVM) for hardware acceleration, utilising CPU feauture in Intel VT-x or AMD SVM.  
But instead of typing in the command for installing(using virsh) manually, which is not very efficient for an environmet which requires working with multiple VMs(virtual machines), the installation process has been automated using **_vagrant_**. Vagrant uses Virtual Box as its default hypervisor, but since we are using Linux, we have used Libvirt as its backend. The configuration of the _Vagrantfile_ and the network files(isolated or private network as well as NAT-enabled network, besides management network) have been uploaded in the commits. The commonly used commands in the vagrant environmet are listed:  
```
mkdir tuxlab
cd tuxlab
vagrant init
vi Vagrantfile
vi networkfile.xml
```  
Once the files are ready, we bring up the vitual machines,check its status and login remotely for working.  
```
vagrant up
vagrant status
vagrant ssh vm
```  
For details, visit http://www.vagrantup.org

- **Network Topology**

There are seven virtual machines(indicated by vm1, vm2 and so on). The virtual machines share one common management network(and hence gets an ip in specified range in lab-mgmt.xml file) and an isolated networki(lab-vm-isolate.xml file). Only one virtual machine(vm1 here) has an additional public network that can reach out to the internet. Hence that particular interface(eth2 here) gets an ip address from dhcp server as per the ip range mentioned in the concerned network file(lab-vm-net.xml here). A static ip address(10.10.10.1 here) is set to the eth1 interface of vm1 and all the other VMs get ip in the same network from vm1. IP forwarding and masquerading is enabled in vm1 interface so that the remaining virtual machines can avail internet access via vm1. The configurations for the VMs are:
  - vm1: DNS server, DHCP server and router
  - vm2, vm3: cliets
  - vm4, vm5: web servers
  - vm6, vm7: load balancers

- **Services used**

The services used and the purposes they meet are listed below:
  - **iptables** : To implement _iptables_ rules
  - **dnsmasq** : To implement _dhcp_ server
  - **bind** : To implement _dns_ server
  - **Nginx** : To implement _web server_
  - **HAProxy** : To implement _load balancing_ and _high availability_
  - **Keepalived** : To implement _ip failover_

- **Installation and Configuration**

 - **iptables**
 *Installation*: To install and start the service, type in:
 ```
 yum install iptables-services
 systemctl start iptables
 systemctl enable iptables
 systemctl status iptables
 ```
 *Configuration*:  
 Disable and mask firewalld:
 ```
 systemctl stop firewalld
 systemctl disable firewalld
 systemctl mask firewalld
 ```
 To list all the rules and save them:
 ```
 iptables -L
 iptables-save > /etc/sysconfig/iptables
 ```
 To configure vm1 as a router, the iptables commands are:
 ```
 iptables -I FORWARD -i eth2 -o eth1 -j ACCEPT
 iptables -I FORWARD -i eth1 -o eth2 -j ACCEPT
 iptables -t nat -I POSTROUTING -o eth2 -j MASQUERADE
 ```
 To enable packet forwarding:
 ```
 vi /etc/sysctl.conf
 net.ipv4.ip_forward = 1
 sysctl -p
 ```

 - **dnsmasq**  
 *Installation*: To install and start the service, type in:
 ```
 yum install dnsmasq
 systemctl start dnsmasq
 systemctl enable dnsmasq
 systmctl status dnsmasq
 ```
 *Configuration*:  
 For the service to listen on its respective port 53, the iptables command is:
 ```
 iptables -I INPUT -p udp --dport 53 -j ACCEPT
 iptables -I INPUT -p tcp --dport 53 -j ACCEPT
 ```
 The configuration file /etc/dnsmasq.conf is uploaded in the commit. After being done with the configuration, restart the service with the command:
 `
 systemctl restart dnsmasq
 `

 - **bind**  
 *Installation*: To install and start the service, type in:
 ```
 yum install bind
 systemctl start named
 systemctl enable named
 systemctl status named
 ```
 *Configuration*:  
 Open the configuration file and the zone file and edit them:
 ```
 vi /etc/named.conf
 vi /var/named/<domainname>.zone
 ```
 Open port 67 for the service to listen:
 ```
 iptables -I INPUT -p udp --dport 67 -j ACCEPT
 iptables -I INPUT -p tcp --dport 67 -j ACCEPT
 ```
 Restart the service:
 `
 systemctl restart named
 `

 - **Nginx**  
 *Installation*: To install and start the service, type in:
 ```
 yum install nginx
 systemctl start nginx
 systemctl enable nginx
 systemctl status nginx
 ```
 *Configuration*: For minimal configuration, simply add an index.html file at the default document root of nginx and restart the service
 ```
 echo "Welcome to web server" > /usr/local/nginx/html/index.html
 systemctl restart nginx
 ```
 For more information, visit http://www.nginx.com

 - **HAProxy**  
 *Installation*: To install and start the service,type in:
 ```
 yum install haproxy
 systemctl start haproxy
 systemctl enable haproxy
 systemctl status haproxy
 ```
 *Configuration*: Configure the file as uploaded in commit, and restart the service
 ```
 vi /etc/haproxy/haproxy.cfg
 systemctl restart haproxy
 ```
 For more information, visit http://www.haproxy.org

 - **Keepalived**  
 *Installation*: To install and start the service,type in:
 ```
 yum install keepalived
 systemctl start keepalived
 systemctl enable keepalived
 systemctl status keepalived
 ```
 *Configuration*: Configure the file as uploaded in commit, and restart the service
 ```
 vi /etc/keepalived/keepalived.conf
 systemctl restart keepalived
 ```
 For more information, visit http://www.keepalived.org


### Conclusion

- *Testing*  
To verify the working of the server and test load balancing and ip failover service, a request can be sent from the local host to any one of the proxy servers(using the  virtual ip, here 10.10.10.50, assigned by keepalived). While the response can be seen in the client, if one of the web servers or even one of the load balancer service is stopped, even then the client continues to recieve the response.The following script can be used in the client machine to test this:
 ```
 while sleep 1
 do
 curl www.tux.lab
 done
 ```
Hence load balancing and high availability of the web server is done successfully.
