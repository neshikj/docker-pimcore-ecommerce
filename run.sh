#!/bin/bash

# Temp. start mysql to do all the install stuff
/usr/bin/mysqld_safe > /dev/null 2>&1 &

# Install composer if needed
if [ ! -x /usr/local/bin/composer ]; then

    echo "Installing Composer ... "
    cd /tmp

    EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

    if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
    then
        >&2 echo 'ERROR: Invalid installer signature'
        rm composer-setup.php
        exit 1
    fi

    php composer-setup.php --quiet
    mv composer.phar /usr/local/bin/composer
    rm composer-setup.php
fi

# Install composer dependencies if needed
if [ ! -x /var/www/vendor ]; then

    # Installing composer and npm packages, also grunt for the stylesheets
    echo "Installing dependencies ..."
    cd /var/tmp
    echo "Downloading Pimcore 5 Skeleton ... "
    echo "Installing Pimcore 5 dependencies (composer) ..."
    composer global require hirak/prestissimo
    COMPOSER_MEMORY_LIMIT=-1 composer create-project pimcore/demo-ecommerce ecommerce
    cp -R /var/tmp/ecommerce/. /var/www
    rm -rf /var/tmp/ecommerce
    chown -R www-data:www-data /var/www
    chmod -R 777 /var/www/var
    mv /var/www/system.docker.php /var/www/var/config/system.php
fi

mysql -u root -e "CREATE DATABASE pimcore charset=utf8mb4;"
mysql -u root -e "set global innodb_file_format = 'Barracuda';"
mysql -u root -e "set global innodb_large_prefix = ON;"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'ecommerce'@'%' IDENTIFIED BY 'passw0rd' WITH GRANT OPTION;"

cd /var/www
./vendor/bin/pimcore-install --admin-username admin --admin-password demo --mysql-username ecommerce --mysql-password passw0rd --mysql-database pimcore --no-interaction
chown -R www-data:www-data /var/www
chmod -R 777 /var/www/var

echo "Finalizing startup."

exec supervisord -n