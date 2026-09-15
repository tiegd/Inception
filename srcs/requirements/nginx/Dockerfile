FROM debian:bookworm-slim
WORKDIR /app
# COPY conf/requirement.txt .
# COPY . .

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN usermod -u 33 www-data && groupmod -g 33 www-data

RUN mkdir -p /etc/nginx/ssl

COPY conf/nginx.conf etc/nginx/nginx.conf

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]

# VOLUME