FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    phph8.2-fpm php8.2-cli php8.2-mysql \
    php8.2-curl php8.2-gd php8.2-mbstring php8.2-xml php8.2-zip \
    mariadb-client curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
        -o /usr/local/bin/wp \
    && chmod +x wp-cli.phar

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/init-wordpress.sh /usr/local/bin/init-wordpress.sh

RUN  chmod +x /usr/local/bin/init-wordpress.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/init-wordpress.sh"]