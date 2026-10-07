#! /bin/sh

set -e

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(grep '^WP_ADMIN_PASSWORD=' /run/secrets/credentials | cut -d= -f2-)
WP_USER_PASSWORD=$(grep '^WP_USER_PASSWORD=' /run/secrets/credentials | cut -d= -f2-)

WP-PATH=/var/www/html

until mriadb -h mariadb -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "SELECT 1" > /dev/null 2>&1; do
    echo "Waiting for MariaDB"
    sleep 2
done

if [ ! -f "$WP_PATH/wp-config.php" ]; then
    
    wp core download --path="$WP_PATH" --allow-root
    
    wp config create --path="$WP_PATH" \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost=mariadb \
        --allow-root
    
    wp core install --path="$WP_PATH" \
        --url="https://${DOMAIN_NAME}" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --path="$WP_PATH" \
        --role=author \
        --user_pass="$WP_USER_PASSWORD" \
        --allow-root

fi

chown -R www-data:www-data "$WP_PATH"

exec php-fpm8.2 -F