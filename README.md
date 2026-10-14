# Inception

*This project has been created as part of the 42 curriculum by gaducurt.*

## Description

### Docker

### Docker File

### Docker Compose

### Nginx

### WordPress

### MariaDB

## Instruction

```bash
git clone git@github.com:tiegd/Inception.git
```

```bash

```


### For display wordpress tables in mariadb container

```bash
docker exec -it mariadb mariadb -u root -p
```
```sql
show databases;
use wordpress
show tables;
select wp_users;
select * from wp_users;
select user_login from wp_users;
```
or just :
```sql
use wordpress select user_login from wp_users;
```

## Resources
#### Docker
- https://blog.stephane-robert.info/docs/conteneurisation/

#### Nginx
- https://fr.wikipedia.org/wiki/Nginx
- https://hub.docker.com/hardened-images/catalog/dhi/nginx
- https://medium.com/@jayprakash01/understanding-cgi-fastcgi-and-php-fpm-in-nginx-with-php-applications-a6a6c0b7b91d

#### WordPress
- https://developer.wordpress.org/advanced-administration/wordpress/wp-config/
- https://github.com/WordPress/WordPress/blob/master/wp-config-sample.php

#### MariaDB
