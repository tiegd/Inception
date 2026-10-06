FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends\
        nginx openssl \
    && rm -rf /var/lib/apt/lists/*

RUN usermod -u 33 www-data && groupmod -g 33 www-data

RUN mkdir -p /etc/nginx/ssl /var/www/html \
    && openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/incption.crt \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/CN=gaducurt.fr"

COPY conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]

# VOLUME