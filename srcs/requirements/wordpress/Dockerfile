FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    curl \
    php \
    php-fpm \
    php-mysqli \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

COPY conf/wp-entrypoint.sh /usr/local/bin
RUN  chmod +x /usr/local/bin/wp-entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["wp-entrypoint.sh"]