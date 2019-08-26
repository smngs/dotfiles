DOT_DIRECTORY="${HOME}/dotfiles"
.DEFAULT_GOAL := help

all:

deploy: ## Create symlink to home directory
	@sh $(DOT_DIRECTORY)/bin/install.sh --deploy

init: ## Setup environment settings
	@sh $(DOT_DIRECTORY)/bin/install.sh --init

test: ## Test dotfiles and init scripts
	@sh $(DOT_DIRECTORY)/bin/test.sh --test

backup: ## Backup dotfiles
	@sh $(DOT_DIRECTORY)/bin/install.sh --backup

clean: ## Cleanup dotfiles
	@sh $(DOT_DIRECTORY)/bin/install.sh --clean

update: ## Fetch changes for this repo
	git pull origin master
	git submodule init
	git submodule update
	git submodule foreach git pull origin master

install: ## Run make backup, update, deploy, init
	@sh $(DOT_DIRECTORY)/bin/install.sh --install

help: ## Self-documented Makefile
	@sh $(DOT_DIRECTORY)/bin/install.sh --help
