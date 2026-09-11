SHELL := /bin/bash

NAMESPACE := uoa_eresearch
COLLECTION := exorcism
PLAYBOOK := $(NAMESPACE).$(COLLECTION).ubuntu2404
DIST_DIR := dist
COLLECTIONS_DIR := $(DIST_DIR)/collections

PYTHON ?= 3.12
ANSIBLE_CORE ?=
TARGET ?=
TAG ?=

# A CI matrix leg sets ANSIBLE_CORE to pin one version. It resolves outside the project
# because the lockfile already holds an ansible-core that would conflict with it. Linting
# deliberately stays on the locked version, since ansible-lint pins its own ansible-core.
ifeq ($(strip $(ANSIBLE_CORE)),)
UV_ANSIBLE := uv run
else
UV_ANSIBLE := uv run --isolated --no-project --python $(PYTHON) \
	--with ansible-core==$(ANSIBLE_CORE)
endif

##@ BUILD
.PHONY: help
help: ## Show this help message
	@awk 'BEGIN {FS = ":.*?## "} /^##@ / {printf "\n%s\n", substr($$0, 5)} \
		/^[a-zA-Z_-]+:.*## / {printf "  %-18s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: build
build: ## Build the collection tarball into dist/
	@mkdir -p $(DIST_DIR)
	$(UV_ANSIBLE) ansible-galaxy collection build --output-path $(DIST_DIR) --force

##@ TEST
# A dry run is the only check that opens the section files at all: tasks/main.yml pulls
# them in with include_tasks, which is dynamic, so ansible-lint reads them but neither
# --syntax-check nor ansible-test sanity ever does. Installing the built tarball first
# means the run exercises the same path a consumer takes.
.PHONY: check_target
check_target:
	@test -n "$(TARGET)" || { \
		echo "[!] TARGET is required, for example: make test TARGET=throwaway.example"; \
		exit 1; }

.PHONY: test
test: check_target build ## Dry run the role against TARGET, which must be a throwaway host
	@rm -rf $(COLLECTIONS_DIR)
	$(UV_ANSIBLE) ansible-galaxy collection install $(DIST_DIR)/*.tar.gz -p $(COLLECTIONS_DIR)
	ANSIBLE_COLLECTIONS_PATH=$(COLLECTIONS_DIR) $(UV_ANSIBLE) ansible-playbook \
		$(PLAYBOOK) -i '$(TARGET),' --check --diff

##@ LINT
.PHONY: lint
lint: ## Run ansible-lint at the production profile
	uv run ansible-lint

.PHONY: check_version
check_version: ## Verify galaxy.yml and CHANGELOG.md agree on the version
	@version="$$($(MAKE) --no-print-directory get_version)"; \
	if ! grep -qE "^## $$version - [0-9]{4}-[0-9]{2}-[0-9]{2}$$" CHANGELOG.md; then \
		echo "[!] CHANGELOG.md has no entry for version $$version"; \
		exit 1; \
	fi; \
	echo "[*] Version $$version is in the changelog"

.PHONY: check_version_tag
check_version_tag: ## Verify TAG matches the collection version, leading v stripped
	@test -n "$(TAG)" || { \
		echo "[!] TAG is required, for example: make check_version_tag TAG=v0.1.0"; \
		exit 1; }
	@version="$$($(MAKE) --no-print-directory get_version)"; \
	tag="$(TAG)"; \
	if [[ "$${tag#v}" != "$$version" ]]; then \
		echo "[!] Tag $$tag does not match collection version $$version"; \
		exit 1; \
	fi; \
	echo "[*] Tag $$tag matches collection version $$version"

##@ GET
.PHONY: get_version
get_version: ## Print the collection version from galaxy.yml
	@awk '/^version:/ { print $$2; exit }' galaxy.yml

.PHONY: get_changelog
get_changelog: ## Print the changelog section for the current version
	@version="$$($(MAKE) --no-print-directory get_version)"; \
	awk -v ver="$$version" ' \
		$$0 ~ "^## " ver " " { found = 1; next } \
		found && /^## / { exit } \
		found { print } \
	' CHANGELOG.md

##@ CI
.PHONY: ci
ci: lint check_version test ## Run everything CI runs; needs TARGET for the dry run

.PHONY: clean
clean: ## Remove build output and the lint cache
	rm -rf $(DIST_DIR) .ansible
