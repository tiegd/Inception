# Developer documentation

This document explains how to set up the environment from scratch, build and run the project, manage the containers and volumes, and where the data is stored. For day-to-day usage, see [USER_DOC.md](USER_DOC.md).

All commands below are run from the root of the repository.

## 1. Prerequisites

A Linux virtual machine (the project was developed on Debian 13) with:

- Docker Engine and the Docker Compose plugin (`docker compose`, with a space)
- `make` and `git`
- a web browser inside the VM, to test the website

Install Docker from the official repository (Debian), as described in the [Docker documentation](https://docs.docker.com/engine/install/debian/):

```bash
sudo apt update
sudo apt install -y ca-certificates curl make git

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Allow your user to use Docker without `sudo`, then **log out and log in again** (or reboot) so the new group is applied:

```bash
sudo usermod -aG docker $USER
```

Check:

```bash
docker run --rm hello-world
docker compose version
```

## 2. Set up the environment from scratch

### 2.1 Get the sources

```bash
git clone https://github.com/tiegd/Inception.git
cd Inception
```

### 2.2 Resolve the domain name

```bash
echo "127.0.0.1 gaducurt.42.fr" | sudo tee -a /etc/hosts
getent hosts gaducurt.42.fr
```

### 2.3 Create `srcs/.env`

This file is git-ignored. It holds the **non-sensitive** settings, which are injected into the `mariadb` and `wordpress` containers as environment variables.

```env
LOGIN=gaducurt
DOMAIN_NAME=gaducurt.42.fr

MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser

WP_TITLE=Inception
WP_ADMIN_USER=<administrator login, must not contain "admin">
WP_ADMIN_EMAIL=<administrator e-mail>
WP_USER=<second user login>
WP_USER_EMAIL=<second user e-mail>
```

| Variable | Used by | Meaning |
|---|---|---|
| `LOGIN` | Makefile, `docker-compose.yml` | Login of the machine user: the data folders are `/home/$LOGIN/data/...` |
| `DOMAIN_NAME` | WordPress script | Public URL of the site (`https://$DOMAIN_NAME`) |
| `MYSQL_DATABASE`, `MYSQL_USER` | MariaDB and WordPress scripts | Name of the database and of its user |
| `WP_TITLE` | WordPress script | Title of the site |
| `WP_ADMIN_USER`, `WP_ADMIN_EMAIL` | WordPress script | Administrator account (the login must not contain "admin" or "administrator") |
| `WP_USER`, `WP_USER_EMAIL` | WordPress script | Second account, with the `author` role |

The e-mail addresses are never checked: no mail is sent by the stack. Use two different addresses, because WordPress requires one unique address per user.

### 2.4 Create the secrets

These files are git-ignored. The passwords are mounted in the containers as files under `/run/secrets/` and are never part of the environment.

```bash
mkdir -p secrets
printf '%s' '<database user password>' > secrets/db_password.txt
printf '%s' '<database root password>' > secrets/db_root_password.txt
printf 'WP_ADMIN_PASSWORD=%s\nWP_USER_PASSWORD=%s\n' '<administrator password>' '<second user password>' > secrets/credentials.txt
chmod 600 secrets/*.txt
```

| File | Content | Read by |
|---|---|---|
| `secrets/db_password.txt` | one line, the password only | `mariadb` and `wordpress` |
| `secrets/db_root_password.txt` | one line, the password only | `mariadb` |
| `secrets/credentials.txt` | two lines `WP_ADMIN_PASSWORD=...` and `WP_USER_PASSWORD=...` | `wordpress` |

Rules: no spaces or quotes around the values, no apostrophe (`'`) in the database passwords (it would break the SQL of `init-mariadb.sh`), and the files must use Unix line endings (LF). Check with `cat -A secrets/db_password.txt`: a line must end with `$` and not with `^M$`.

`secrets/` and `srcs/.env` are listed in `.gitignore`. Check before each commit with `git status`, and verify the rule with `git check-ignore -v srcs/.env secrets/credentials.txt`.

## 3. Build and launch

### With the Makefile

```bash
make
```

`make` does the following, in order:

1. `make check`: verifies that the three secret files exist;
2. creates `/home/<LOGIN>/data/mariadb` and `/home/<LOGIN>/data/wordpress` (they must exist before Compose starts);
3. runs `docker compose -f srcs/docker-compose.yml up -d --build`.

Start order enforced by Compose: `mariadb`, then `wordpress` (once MariaDB is `healthy`), then `nginx`.

### Makefile targets

| Target | Effect |
|---|---|
| `make` / `make all` / `make up` | Check, prepare folders, build and start |
| `make down` | Remove containers and network (data kept) |
| `make stop` / `make start` | Stop / start the existing containers |
| `make restart` | `down` then `up` |
| `make clean` | `docker compose down --rmi all --volumes`: removes containers, network, images and Docker volumes (data on the host is kept) |
| `make fclean` | `clean`, then `sudo rm -rf` of both data folders: **deletes all data** |
| `make re` | `fclean`, then `make` |
| `make logs` | Follow the logs of all services |
| `make ps` | State of the containers |

### Without the Makefile

```bash
docker compose -f srcs/docker-compose.yml config            # print the resolved configuration
docker compose -f srcs/docker-compose.yml up -d --build
docker compose -f srcs/docker-compose.yml down
```

`config` is the quickest way to spot a wrong variable or a typo in the Compose file.

## 4. Manage the containers and volumes

### Containers

```bash
docker ps -a                                   # all containers and their state
docker logs --tail 20 <container>              # last lines of a container log (mariadb, wordpress, nginx)
docker logs -t -f <container>                  # follow, with timestamps
docker exec -it <container> bash               # open a shell in a running container
docker restart <container>                     # restart one service
docker inspect --format '{{.State.Health.Status}}' mariadb
docker exec nginx nginx -t                     # validate the nginx configuration
docker exec wordpress php-fpm8.2 -t            # validate the PHP-FPM configuration
```

Check the PID 1 of a container (it must be the daemon itself, not a shell):

```bash
docker exec nginx cat /proc/1/cmdline | tr '\0' ' '; echo
```

### Rebuild after a change

Configuration files and scripts are copied into the images at build time, so after editing one:

```bash
make down
make
```

### Display the WordPress tables in the MariaDB container

`wordpress` is the name of the database; it contains several tables (`wp_users`, `wp_posts`, ...).

```bash
docker exec -it mariadb mariadb -u root -p
```

The password is the content of `secrets/db_root_password.txt`. Then, in the SQL client:

```sql
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
SELECT * FROM wp_users;
SELECT user_login FROM wp_users;
```

In one command:

```bash
docker exec -it mariadb mariadb -u root -p wordpress -e "SELECT user_login FROM wp_users;"
```

`-it` is required for the password prompt to work.

### Display the WordPress postes in the MariaDB container

```bash
docker exec -it mariadb mariadb -u root -p wordpress -e "SELECT post_name FROM wp_posts;"
```

### Volumes

```bash
docker volume ls
docker volume inspect srcs_mariadb_data srcs_wordpress_data
sudo ls /home/<LOGIN>/data/mariadb /home/<LOGIN>/data/wordpress
```

### Test the automatic restart

`docker stop` and `docker kill` count as **manual stops**, which the `unless-stopped` restart policy does not undo. To simulate a real crash, kill the process from the host:

```bash
PID=$(docker inspect --format '{{.State.Pid}}' wordpress)
sudo kill -9 "$PID"
sleep 10
docker ps
docker inspect --format '{{.RestartCount}}' wordpress
```

The container must be `Up` again, after a few seconds. The first start of a container must have lasted at least 10 seconds for the policy to apply.
