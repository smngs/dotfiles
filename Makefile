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
	@sh $(DOT_DIRECTORY)/bin/install.sh --update

install: backup update deploy init ## Run make backup, update, deploy, init

help: ## Self-documented Makefile
	@sh $(DOT_DIRECTORY)/bin/install.sh --help
