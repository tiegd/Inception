FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends\
    mariadb-server \
    && rm -rf /var/lib/apt/list/*



COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/init-mariadb.sh /usr/local/bin/init-mariadb.sh

RUN chmod +x /usr/local/bin/init-mariadb.sh \
    && mkdir -p /run/mysqld \
    && chown -R mysql:mysql var/run/mysqld \
    && chmod 755 /run/mysqld

ENV MYSQL_ROOT_PASSWORD=root \
    MYSQL_DATABASE=app_db \
    MYSQL_USER=app_user \
    MYSQL_PASSWORD=app_pass

EXPOSE 3306

ENTRYPOINT [ "/usr/local/bin/init-mariadb.sh" ]