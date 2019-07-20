DOTPATH    := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
DOTCONFIGPATH := .config
HOME       := ~
CANDIDATES := $(wildcard .??*) bin
EXCLUSIONS := .DS_Store .git .gitmodules .config
DOTFILES   := $(filter-out $(EXCLUSIONS), $(CANDIDATES))

.DEFAULT_GOAL := help

all:

list: ## Show dot files in this repo
	@$(foreach val, $(DOTFILES), /bin/ls -dF $(val);)

deploy: ## Create symlink to home directory
	@echo '==> Start to deploy dotfiles to home directory.'
	@echo ''
	@$(foreach val, $(DOTFILES), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)
	@echo '==> Start to deploy .config to home directory.'
	@echo ''
	@cd ${DOT_DIRECTORY}/${DOT_CONFIG_DIRECTORY}
	@for file in `\find . -maxdepth 8 -type f`; do \ 
		ln -snfv $${DOTPATH}/$${DOTCONFIGPATH}/$${file:2} $${HOME}/$${DOT_CONFIG_DIRECTORY}/$${file:2} \
	done
	

init: ## Setup environment settings
	@DOTPATH=$(DOTPATH) bash $(DOTPATH)/bin/init.sh

update: ## Fetch changes for this repo
	git pull origin master
	git submodule init
	git submodule update
	git submodule foreach git pull origin master

install: update deploy init ## Run make update, deploy, init
	@exec $$SHELL

clean: ## Remove Dotfiles from home directory
	@echo 'Remove dot files from your home directory.'
	@-$(foreach val, $(DOTFILES), rm -vrf $(HOME)/$(val);)

destroy: clean ## Remove this repository
	@echo 'Remove this repository.'
	-rm -rf $(DOTPATH)

help: ## Self-documented Makefile
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
