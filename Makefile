DOT_DIRECTORY="${HOME}/dotfiles"
.DEFAULT_GOAL := help

all:

deploy: ## Create symlink to home directory
	@echo '==> start to deploy dotfiles to home directory.'
	@echo ''
	@sh $(DOT_DIRECTORY)/bin/deploy.sh

init: ## Setup environment settings
	@sh $(DOT_DIRECTORY)/bin/init.sh

test: ## Test dotfiles and init scripts
	@sh $(DOT_DIRECTORY)/bin/test.sh

update: ## Fetch changes for this repo
	git pull origin master
	git submodule init
	git submodule update
	git submodule foreach git pull origin master

install: update deploy init ## Run make update, deploy, init
	@exec $$SHELL

help: ## Self-documented Makefile
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
