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

update: ## Fetch changes for this repo
	@sh $(DOT_DIRECTORY)/bin/install.sh --update

install:
	@sh $(DOT_DIRECTORY)/bin/install.sh --install

help: ## Self-documented Makefile
	@sh $(DOT_DIRECTORY)/bin/install.sh --help
