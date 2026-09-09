FROM debian:bookworm-slim

RUN apt-get update && apt-get install --no-install-recommends -y \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-curl \
    php8.2-fpm \
    php8.2-fpm \
    php8.2-fpm \
    php8.2-fpm \
    php8.2-fpm \
    php8.2-fpm \

WORKDIR /app

# COPY conf/requirement.txt .
COPY . .

CMD ["/usr/sbin/wordpress", "-g", "daemon off;"]
# VOLUME