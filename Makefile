DOTPATH    := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
CANDIDATES := $(wildcard .??*) bin
EXCLUSIONS := .DS_Store .git .gitmodules pc01 xps01
DOTFILES   := $(filter-out $(EXCLUSIONS), $(CANDIDATES))

.DEFAULT_GOAL := help

all:

list: ## Show dot files in this repo
	@$(foreach val, $(DOTFILES), /bin/ls -dF $(val);)

deploy: ## Create symlink to home directory
	@echo '==> Start to deploy dotfiles to home directory.'
	@echo ''
	@$(foreach val, $(DOTFILES), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)

init: ## Setup environment settings
	@DOTPATH=$(DOTPATH) bash $(DOTPATH)/bin/init.sh

init-pc01: ## Setup environment settings
	@DOTPATH=$(DOTPATH) bash $(DOTPATH)/bin/init-pc01.sh

init-xps01: ## Setup environment settings
	@DOTPATH=$(DOTPATH) bash $(DOTPATH)/bin/init-xps01.sh

update: ## Fetch changes for this repo
	git pull origin master
	git submodule init
	git submodule update
	git submodule foreach git pull origin master

install-xps01: update deploy init-xps01 ## Run make update, deploy, init
	@exec $$SHELL

install-pc01: update deploy init-pc01 ## Run make update, deploy, init
	@exec $$SHELL

clean: ## Remove Dotfiles from home directory
	@echo 'Remove dot files from your home directory.'
	@-$(foreach val, $(DOTFILES), rm -vrf $(HOME)/$(val);)

destroy: clean ## Remove this repository
	@echo 'Romove this repository.'
	-rm -rf $(DOTPATH)

help: ## Self-documented Makefile
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
