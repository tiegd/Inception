#! /bin/sh

while ! mysqladmin ping -h"$WORDPRESS_DB_HOST" --silent; do
    sleep 1
done

cd /var/www/html

if [ ! -f wp-config.php ]; then
    wp config create \
        --dbname="$WORDPRESS_DB_NAME"\
        --dbuser="$WORDPRESS_DB_USER"\
        --dbpass="$WORDPRESS_DB_PASSWORD"\
        --dbhost="$WORDPRESS_DB_HOST"\
        --path="/var/www/html"\
        --allow-root

    wp core install \
        --url="$DOMAIN_NAME"\
        --title="$WORDPRESS_TITLE"\
        --admin_user="$WORDPRESS_ADMIN_USER"\
        --admin_password="$WORDPRESS_ADMIN_PASSWORD"\
        --admin_email="$WORDPRESS_ADMIN_EMAIL"\
        --path="/var/www/html"\
        --allow-root

fi

exec php-fpm82 -F