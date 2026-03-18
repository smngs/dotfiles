DOT_DIRECTORY = $(HOME)/dotfiles
INSTALL_SH    = $(DOT_DIRECTORY)/bin/install.sh

.DEFAULT_GOAL := help
.PHONY: deploy init backup update install help

deploy: ## Create symlink to home directory
	@bash $(INSTALL_SH) --deploy

init: ## Setup environment settings
	@bash $(INSTALL_SH) --init

backup: ## Backup dotfiles
	@bash $(INSTALL_SH) --backup

update: ## Fetch changes for this repo
	@bash $(INSTALL_SH) --update

install: ## Install packages for current platform
	@bash $(INSTALL_SH) --install

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*##"}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'
