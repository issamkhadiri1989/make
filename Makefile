.PHONY: init up install build clean

# define varibales
APP_ENV ?= dev
SYMFONY_VERSION = 7.0.*
SYSTIME := $(shell date +"%Y-%m-%d__%H-%M-%S")
FORCE_STOP ?= 1
GIT_KEY = $(cat personal_key.txt)

include .env
export

# commands
install: down build init
	@echo "Project installed successfully. Got to http://localhost..."

init: up create-empty-project download-database
	
up: 
	docker compose up -d --remove-orphans

build:
	@echo "Building the containers..."
	docker compose build --force-rm 

stop-all-containers:
ifeq ($(FORCE_STOP), 1)
	docker stop $$(docker ps -aq)
else
	@echo "NO STOP"
endif

create-empty-project: recreate-directory
	docker compose exec server echo $(GIT_KEY) > ~/.git-credentials
	docker compose exec server git clone https://github.com/issamkhadiri1989/symfony-apiplatform.git .
	docker compose exec server composer install

download-database:
	docker compose exec database curl https://raw.githubusercontent.com/raramuridesign/mysql-country-list/refs/heads/master/country-lists/mysql-country-list.sql --output /tmp/${SYSTIME}.sql
	docker compose exec database sh -c "mysql -u${ROOT_USER} -p${ROOT_PASSWORD} database < /tmp/${SYSTIME}.sql"

recreate-directory:
	rm -Rf source
	mkdir source 

down:
	docker compose down

enter:
	docker compose exec server bash

clean:
	@echo ${SYSTIME}

stop: 
	docker compose stop

start:
	docker compose up -d --no-recreate --remove-orphans
	
restart:
ifndef service
	@echo "Restarting all containers..."
	docker compose restart
else
	@echo "Restarting ${service}"
	docker compose restart $(service)
endif