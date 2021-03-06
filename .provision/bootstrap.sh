#!/usr/bin/env bash


# nginx
sudo apt-get update
sudo apt-get -y install php5 php5-cli php5-fpm
sudo apt-get -y install zip unzip git nginx
sudo service nginx start

# set up nginx server
sudo cp /vagrant/.provision/nginx/nginx.conf /etc/nginx/sites-available/site.conf
sudo chmod 644 /etc/nginx/sites-available/site.conf
sudo ln -s /etc/nginx/sites-available/site.conf /etc/nginx/sites-enabled/site.conf
sudo service nginx restart

export DEBIAN_FRONTEND=noninteractive
# sudo apt-get -y install passwdqc
# MSPW=$(pwqgen)
# For dev purposes, doesn't really matter what the mysql root password is. This (hopefully) establishes
# a a base root/root configuration. 
echo "mysql-server mysql-server/root_password password root" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password root" | sudo debconf-set-selections


sudo apt-get -y install mysql-server
sudo apt-get -y install php5-mysql php5-mcrypt php5-gd 

# Run the secure installation script for mySQL. Take defaults.
# sudo /usr/bin/mysql_secure_installation --use-default

# Create testDB for DKAN to connect to.
mysql -u root -p"root" -e "CREATE DATABASE DKAN_TEST;"

## Install and verify Python version.
# sudo apt-get -y install python3 python3-pip
# python3 --version
# Install fabric for system management. 
# pip3 install fabric


# clean /var/www
sudo rm -Rf /var/www
# symlink /var/www => /vagrant
sudo ln -s /home/vagrant/dkan/ /var/www

# Restart PHP Services before drush. 
sudo service php5-fpm restart
# Download latest stable release using the code below or browse to github.com/drush-ops/drush/releases.
php -r "readfile('http://files.drush.org/drush.phar');" > /tmp/drush

# Test your install.
php /tmp/drush core-status

# Make `drush` executable as a command from anywhere. Destination can be anywhere on $PATH.
chmod +x /tmp/drush
sudo mv /tmp/drush /usr/local/bin

# # Configure apache servername
# echo "ServerName dkan-test.local.com" | sudo tee -a /etc/apache2/apache2.conf
# sudo service apache2 restart



# Optional. Enrich the bash startup file with completion and aliases.
sudo drush init --add-path

# # Install DKAN, finally. 
# git clone --branch 7.x-1.x https://github.com/NuCivic/dkan.git
# cd dkan
# sudo drush make --prepare-install drupal-org-core.make webroot --yes
# sudo rsync -av . webroot/profiles/dkan --exclude webroot
# sudo drush -y make --no-core --contrib-destination=./ drupal-org.make webroot/profiles/dkan --no-recursion
# cd webroot 
git clone --branch master https://github.com/nuams/dkan-drops-7.git dkan
cd dkan
unzip master.zip

# Install dkan verbose. 
sudo drush -y site-install dkan --account-name=admin --account-pass=admin --db-url="mysql://root:root@localhost/DKAN_TEST" --verbose
# Set default admin password.
drush upwd admin --password=admin
sudo service nginx restart