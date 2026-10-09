COMPOSE = srcs/docker-compose.yml

LOGIN := $(shell grep '^LOGIN=' srcs/.env | cut -d= -f2)

DATA_DIR = /home/$(LOGIN)/data

DC = docker compose -f $(COMPOSE)

.PHONY: all up down start stop restart clean fclean re logs ps check

all: up

check:
	@test -f secrets/db_password.txt || (echo "File not found : secrets/db_password.txt" && exit 1)
	@test -f secrets/db_root_password.txt || (echo "File not found : secrets/db_root_password.txt" && exit 1)
	@test -f secrets/credentials.txt || (echo "File not found : secrets/credentials.txt" && exit 1)

up: check
	@mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	$(DC) up -d --build

down:
	$(DC) down

stop:
	$(DC) stop

start:
	$(DC) start

restart: down up

clean:
	$(DC) down --rmi all --volumes

fclean: clean
	-sudo rm -rf $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress

re:
	$(MAKE) fclean
	$(MAKE) all

logs:
	$(DC) logs -f

ps:
	$(DC) ps