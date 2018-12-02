#!/usr/bin/env bash
#asdfasdf
# Update Package Sources
sudo apt-get update

# Install Nginx
sudo apt-get install -y nginx
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

# Install Redis
sudo apt-get install -y redis-server

# Install MariaDB
# @todo Run the few steps listed in the article to create another admin mysql user
# https://www.digitalocean.com/community/tutorials/how-to-install-mariadb-on-debian-9
sudo apt install -y mariadb-server

# Install Tools
sudo apt-get install -y vim htop

# Install Varnish 5.x
# https://guides.wp-bullet.com/install-varnish-5-debian-9-stretch-using-repository/
wget https://packagecloud.io/varnishcache/varnish5/gpgkey -O - | sudo apt-key add -
sudo apt-get install apt-transport-https debian-archive-keyring -y
echo "deb https://packagecloud.io/varnishcache/varnish5/debian/ stretch main" | sudo tee -a /etc/apt/sources.list.d/varnishcache_varnish5.list
echo "deb-src https://packagecloud.io/varnishcache/varnish5/debian/ stretch main" | sudo tee -a /etc/apt/sources.list.d/varnishcache_varnish5.list
sudo apt-get update
sudo apt-get install -y varnish

# LetsEncrypt
# https://certbot.eff.org/lets-encrypt/debianstretch-nginx
sudo apt-get install -y python-certbot-nginx -t stretch-backports

# Install PHP 7.2
# https://www.chris-shaw.com/blog/installing-php-7.2-on-debian-8-jessie-and-debian-9-stretch
sudo mkdir /var/log/php-fpm
sudo apt-get install -y apt-transport-https lsb-release ca-certificates
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
sudo apt-get update
sudo apt-get install -y php7.2 php7.2-cli php7.2-common php7.2-curl php7.2-gd php7.2-json php7.2-mbstring php7.2-mysql php7.2-opcache php7.2-readline php7.2-xml php7.2-fpm

# Install Wordpress CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

