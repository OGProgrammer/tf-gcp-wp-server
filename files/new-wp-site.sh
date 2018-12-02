#!/usr/bin/env bash
#usage ./new-wp-site.sh acme acme.com

portCounterFile=/home/ogp/files/.php-fpm-port-counter
newSite="$1"
newSiteDomain="$2"
if [ -z "${newSite}" ]; then
    echo "A clean string for the site. Ex: mysite"
    exit
fi
if [ -z "${newSiteDomain}" ]; then
    echo "The domain name of the site. Ex: mysite.com"
    exit
fi

# Add the group and user
sudo groupadd $newSite
sudo useradd -g $newSite $newSite

# Redic defaults
sudo sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" /etc/php/7.2/fpm/php.ini

# Add the fpm bits
if [ ! -f /etc/php/7.2/fpm/pool.d/$newSite.conf ]; then
    # Pull in the counter variable
    if [ ! -f ${portCounterFile} ]; then
        echo "RDF_PHP_FPM_PORT=9000" | sudo tee -a $portCounterFile
    fi
    source $portCounterFile
    newPortNumber=$(($RDF_PHP_FPM_PORT+1))
    >$portCounterFile
    echo "RDF_PHP_FPM_PORT=$newPortNumber" | sudo tee -a $portCounterFile

    sudo cp /home/ogp/files/php72-fpm-pool-template.dist /etc/php/7.2/fpm/pool.d/$newSite.conf
    sudo sed -i "s/template/$newSite/g" /etc/php/7.2/fpm/pool.d/$newSite.conf
    sudo sed -i "s/9001/$newPortNumber/g" /etc/php/7.2/fpm/pool.d/$newSite.conf
fi
# Add the nginx stuff
if [ ! -f /etc/nginx/sites-available/$newSite ]; then
    # Pull in the counter variable
    source $portCounterFile
    sudo cp /home/ogp/files/nginx-template.dist /etc/nginx/sites-available/$newSite
    sudo sed -i "s/template.com/$newSiteDomain/g" /etc/nginx/sites-available/$newSite
    sudo sed -i "s/template/$newSite/g" /etc/nginx/sites-available/$newSite
    sudo sed -i "s/9001/$RDF_PHP_FPM_PORT/g" /etc/nginx/sites-available/$newSite
fi
if [ ! -f /etc/nginx/conf.d/uploads.conf ]; then
    sudo cp /home/ogp/files/nginx-uploads.conf /etc/nginx/conf.d/uploads.conf
fi
if [ ! -f /etc/nginx/snippets/drop.conf ]; then
    sudo cp /home/ogp/files/nginx-drop.conf /etc/nginx/snippets/drop.conf
fi
if [ ! -f /etc/nginx/snippets/ssl_lockdown.conf ]; then
    sudo cp /home/ogp/files/nginx-ssl-lockdown.conf /etc/nginx/snippets/ssl_lockdown.conf
fi

# Create the db for wp
NEW_DB_PW=$(echo -n $newSite | sha1sum | cut -c -40)
NEW_DB_WP=wp_$(echo $newSite)
NEW_DB_USER=$(echo $newSite)
NEW_ADMIN_PW=$(echo -n $newSite`date +"%m-%d-%y"` | sha1sum | cut -c -20)

# WordPress
sudo mkdir /var/www/$newSite
sudo chown -R $newSite:$newSite /var/www/$newSite
sudo -u $newSite wp core download --path=/var/www/$newSite

# Do it live
sudo ln -s /etc/nginx/sites-available/$newSite /etc/nginx/sites-enabled/$newSite

# Bounce services
sudo service php7.2-fpm restart
sudo service nginx restart

# Get an SSL Cert
if sudo certbot certonly --webroot -w /var/www/$newSite -d $newSiteDomain -d www.$newSiteDomain -m josh@remotedevforce.com ; then
    sudo sed -i "s/    listen  80;/#    listen  80;/g" /etc/nginx/sites-available/$newSite
    sudo sed -i "s/#~SSL~/ /g" /etc/nginx/sites-available/$newSite
    # Bounce it
    sudo service php7.2-fpm restart
    sudo service nginx restart
fi

# Create Mysql Database + User
sudo mysql -e "CREATE DATABASE $NEW_DB_WP; CREATE USER \"$NEW_DB_USER\"@\"localhost\" IDENTIFIED BY '$NEW_DB_PW'; GRANT ALL PRIVILEGES ON $NEW_DB_WP.* TO \"$NEW_DB_USER\"@\"localhost\"; FLUSH PRIVILEGES;"
#echo "New password for user $NEW_DB_USER for db $NEW_DB_WP is $NEW_DB_PW"

# Configure WordPress website
cd /var/www/$newSite
sudo -u $newSite wp core config --path=/var/www/$newSite --dbhost=127.0.0.1 --dbname=$NEW_DB_WP --dbuser=$NEW_DB_USER --dbpass=$NEW_DB_PW
sudo -u $newSite wp core install --path=/var/www/$newSite --url=$newSiteDomain --title=$newSite --admin_user=$newSite --admin_password=$NEW_ADMIN_PW --admin_email=josh@remotedevforce.com
echo "New WordPress user created for https://$newSiteDomain with the username $newSite and password $NEW_ADMIN_PW"
