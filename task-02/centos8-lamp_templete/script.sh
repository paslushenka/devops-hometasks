# Update CentOS 8 & install tools
sudo dnf -y update
sudo dnf -y nano vim mc wget net-tools lsof telnet psmisc

# Configure OpenSSH server with password authentication method 
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Install Apache
sudo dnf -y install httpd
sudo chmod 775 /var/www/html
sudo chown -R root:vagrant /var/www/html
echo Apache on CentOS 8 > /var/www/html/index.html
sudo systemctl enable httpd
sudo systemctl start httpd

# Install PHP
sudo dnf -y install php php-opcache php-gd php-mysqlnd php-json php-xml php-xmlrpc php-pear php-ldap php-odbc php-mbstring php-snmp php-soap php-zip
echo "<?php phpinfo();?>" > /var/www/html/info.php
sudo systemctl restart httpd

# Install MariaDB
sudo dnf -y install mariadb-server mariadb

sudo systemctl enable mariadb.service
sudo systemctl start mariadb.service

#sudo mysql_secure_installation

# Configure Firewalld
#sudo systemctl enable firewalld
#sudo systemctl start firewalld

# Open the SSH port 22 to allow incoming traffic
#sudo firewall-cmd --permanent --zone=public --add-service=ssh
# Rules for Apache
#sudo firewall-cmd --permanent --zone=public --add-service=http
#sudo firewall-cmd --permanent --zone=public --add-service=https
#sudo firewall-cmd --reload
