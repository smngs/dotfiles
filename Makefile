DOT_DIRECTORY="${HOME}/dotfiles"
.DEFAULT_GOAL := help

all:

deploy: ## Create symlink to home directory
	@sh $(DOT_DIRECTORY)/bin/install.sh -d

init: ## Setup environment settings
	@sh $(DOT_DIRECTORY)/bin/install.sh -i

test: ## Test dotfiles and init scripts
	@sh $(DOT_DIRECTORY)/bin/test.sh

backup: ## Backup dotfiles
	@sh $(DOT_DIRECTORY)/bin/install.sh -b

clean: ## Cleanup dotfiles
	@sh $(DOT_DIRECTORY)/bin/install.sh -c

destroy: clean ## Destroy dotfiles
	@sh rm -rf $(DOT_DIRECTORY)

update: ## Fetch changes for this repo
	git pull origin master
	git submodule init
	git submodule update
	git submodule foreach git pull origin master

install: backup update deploy init ## Run make backup, update, deploy, init
	@exec $$SHELL

help: ## Self-documented Makefile
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
