#!/usr/bin/env bash

# Disabling NGINX in favor of Apache
# # nginx
# sudo apt-get update
# sudo apt-get -y install nginx
# sudo service nginx start

# # set up nginx server
# sudo cp /vagrant/.provision/nginx/nginx.conf /etc/nginx/sites-available/site.conf
# sudo chmod 644 /etc/nginx/sites-available/site.conf
# sudo ln -s /etc/nginx/sites-available/site.conf /etc/nginx/sites-enabled/site.conf
# sudo service nginx restart



sudo apt-get update
sudo apt-get -y passwdqc
# MSPW=$(pwqgen)
# For dev purposes, doesn't really matter what the mysql root password is. This (hopefully) establishes
# a a base root/root configuration. 
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again root'
# Do not forget libapache2-mod-php5 - can be very annoying dealing with apache without it. 
sudo apt-get -y install git apache2 mysql-server libapache2-mod-auth-mysql php5 php5-cli php5-mysql libapache2-mod-php5 php5-mcrypt php5-gd

# Run the secure installation script for mySQL. Take defaults.
sudo /usr/bin/mysql_secure_installation --use-default

# Create testDB for DKAN to connect to.
mysql -u root -p"root" -e "CREATE DATABASE DKAN_TEST;"

## Install and verify Python version.
# sudo apt-get -y install python3 python3-pip
# python3 --version
# pip3 install fabric


# clean /var/www
sudo rm -Rf /var/www

# symlink /var/www => /vagrant
ln -s /home/vagrant/dkan/webroot /var/www/html

# Download latest stable release using the code below or browse to github.com/drush-ops/drush/releases.
php -r "readfile('http://files.drush.org/drush.phar');" > /tmp/drush

# Test your install.
php /tmp/drush core-status

# Make `drush` executable as a command from anywhere. Destination can be anywhere on $PATH.
chmod +x /tmp/drush
sudo mv /tmp/drush /usr/local/bin

# Configure apache servername
echo "ServerName dkan-test.local.com" | sudo tee /etc/apache2/apache2.conf
sudo service apache2 restart

# Optional. Enrich the bash startup file with completion and aliases.
drush init

# Install DKAN, finally. 
git clone --branch 7.x-1.x https://github.com/NuCivic/dkan.git
cd dkan
drush make --prepare-install drupal-org-core.make webroot --yes
rsync -av . webroot/profiles/dkan --exclude webroot
drush -y make --no-core --contrib-destination=./ drupal-org.make webroot/profiles/dkan --no-recursion
cd webroot 
# Question re placement of why. @designist thinks after drush based on make above.
drush -y site-install dkan --db-url="mysql://root:root@localhost/dkan_test"