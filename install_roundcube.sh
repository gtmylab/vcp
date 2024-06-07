#!/bin/bash

# Step 1: Download and extract Roundcube
cd /tmp
wget https://github.com/roundcube/roundcubemail/releases/download/1.6.2/roundcubemail-1.6.2-complete.tar.gz
tar -xvf roundcubemail-1.6.2-complete.tar.gz
sudo mv roundcubemail-1.6.2 /var/www/html/roundcube

# Step 2: Get MySQL root password from Vesta configuration
MYSQL_CONF="/usr/local/vesta/conf/mysql.conf"
MYSQL_PASSWORD=$(grep -oP "PASSWORD='\K[^']+" $MYSQL_CONF)

# Step 3: Update MySQL configuration
sudo bash -c 'cat <<EOF >> /etc/my.cnf
[mysqld]
innodb_large_prefix=1
innodb_file_format=Barracuda
innodb_file_per_table=1
EOF'

# Step 4: Restart MariaDB
sudo systemctl restart mariadb

# Step 5: Configure MySQL for Roundcube
MYSQL_ROOT_PASSWORD=$MYSQL_PASSWORD
mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<MYSQL_SCRIPT
CREATE DATABASE round_cube;
CREATE USER 'round_cubeuser'@'localhost' IDENTIFIED BY 'M8sjs902Mnha';
GRANT ALL PRIVILEGES ON round_cube.* TO 'round_cubeuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
MYSQL_SCRIPT

# Step 6: Configure Roundcube
cd /var/www/html/roundcube/config
cp config.inc.php.sample config.inc.php

sed -i "s|mysql://roundcube:pass@localhost/roundcubemail|mysql://round_cubeuser:M8sjs902Mnha@localhost/round_cube|" config.inc.php

# Step 7: Initialize Roundcube database
cd /var/www/html/roundcube
sudo php bin/initdb.sh --dir=SQL --create

# Step 8: Configure Apache
sudo bash -c 'cat <<EOF > /etc/httpd/conf.d/roundcube.conf
Alias /roundcube /var/www/html/roundcube

<Directory /var/www/html/roundcube>
    Options -Indexes
    AllowOverride All
    Order allow,deny
    allow from all
</Directory>
EOF'

sudo chown -R apache:apache /var/www/html/roundcube/
sudo systemctl restart httpd

# Step 9: Configure Nginx
sudo bash -c 'cat <<EOF > /etc/nginx/conf.d/roundcube.conf
server {
    listen 80;

    location /roundcube {
        proxy_pass http://127.0.0.1:8080/roundcube;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF'

# Step 10: Restart Nginx
sudo systemctl restart nginx

# Step 11: Backup and replace Exim configuration
sudo cp /etc/exim/exim.conf /etc/exim/exim.conf.bak
sudo rm /etc/exim/exim.conf
wget https://raw.githubusercontent.com/gtmylab/vcp/main/exim.conf -O /etc/exim/exim.conf

sudo systemctl restart exim

# Step 12: Success message
echo "Roundcube installation was successful."
