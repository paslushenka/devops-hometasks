sudo apt-get update
sudo apt-get install -y mc
sudo apt-get install -y lxc lxc-templates bridge-utils

cat <<PAST | tee -a /etc/default/lxc-net
      USE_LXC_BRIDGE="true"
      LXC_BRIDGE="lxcbr0"
      LXC_ADDR="172.31.2.1"
      LXC_NETMASK="255.255.255.0"
      LXC_NETWORK="172.31.2.0/24"
      LXC_DHCP_RANGE="172.31.2.2,172.31.2.254"
      LXC_DHCP_MAX="253"
      LXC_DHCP_CONFILE=/etc/lxc/dnsmasq.conf
      LXC_DOMAIN=""
 PAST

sudo systemctl enable lxc-net
sudo systemctl start lxc-net

cat <<PAST | tee /etc/lxc/default.conf
    lxc.net.0.type  = veth
    lxc.net.0.flags = up
    lxc.net.0.link  = lxcbr0
    lxc.apparmor.profile = unconfined
PAST

sudo lxc-create -t download -n centos_web1 -- -d centos -r 8 -a amd64
sudo lxc-create -t download -n centos_web2 -- -d centos -r 8 -a amd64
 
sudo lxc-start -n centos_web1
sudo lxc-start -n centos_web2

     sleep 20

# Install centos_web1
sudo lxc-attach centos_web1 -- yum -y install httpd
sudo lxc-attach centos_web1 -- systemctl enable httpd
sudo lxc-attach centos_web1 -- systemctl start httpd

# Configure centos_web1
sudo mkdir -pv /var/lib/lxc/centos_web1/rootfs/var/www/web1.org/html
sudo cp /vagrant/index.html /var/lib/lxc/centos_web1/rootfs/var/www/web1.org/html
sudo chmod -R 755 /var/lib/lxc/centos_web1/rootfs/var/www
sudo cp /vagrant/web1.conf /var/lib/lxc/centos_web1/rootfs/etc/httpd/conf.d/

# Install centos_web2
sudo lxc-attach centos_web2 -- yum -y install httpd
sudo lxc-attach centos_web2 -- yum -y install php
sudo lxc-attach centos_web2 -- systemctl enable httpd
sudo lxc-attach centos_web2 -- systemctl start httpd

# Configure centos_web2
sudo mkdir -pv /var/lib/lxc/centos_web2/rootfs/var/www/web2.org/html
sudo cp /vagrant/index.php /var/lib/lxc/centos_web2/rootfs/var/www/web2.org/html
sudo chmod -R 755 /var/lib/lxc/centos_web2/rootfs/var/www
sudo cp /vagrant/web2.conf /var/lib/lxc/centos_web2/rootfs/etc/httpd/conf.d/
sudo sed -i '/Listen 80/Listen 81' /var/lib/lxc/centos_web2/rootfs/etc/httpd/conf/httpd.conf

# Restart apache2
sudo lxc-attach centos_web1 -- systemctl restart httpd
sudo lxc-attach centos_web2 -- systemctl restart httpd

# Configure network
centos_web1_ip=$(sudo lxc-info -i -n centos_web1 | cut -d : -f 2)
centos_web2_ip=$(sudo lxc-info -i -n centos_web2 | cut -d : -f 2)

sudo iptables -F

sudo iptables -t nat -I PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination ${centos_web1_ip}:80
sudo iptables -t nat -I PREROUTING -i eth0 -p tcp --dport 81 -j DNAT --to-destination ${centos_web2_ip}:81

sudo lxc-ls -f
