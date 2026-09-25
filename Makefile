SHELL := /bin/bash

NAMESPACE := uoa_eresearch
COLLECTION := exorcism
PLAYBOOK := $(NAMESPACE).$(COLLECTION).ubuntu2404
VERSION := $(shell awk '/^version:/ { print $$2; exit }' galaxy.yml)

DIST_DIR := dist
COLLECTIONS_DIR := $(DIST_DIR)/collections
TARBALL := $(DIST_DIR)/$(NAMESPACE)-$(COLLECTION)-$(VERSION).tar.gz
CONTAINER := $(COLLECTION)-test

PYTHON ?= 3.12
ANSIBLE_CORE ?= 2.21.*
UV_ANSIBLE := uv run --isolated --no-project --python $(PYTHON) --with ansible-core==$(ANSIBLE_CORE)

.PHONY: help
help: ## Show this help message
	@awk 'BEGIN {FS = ":.*?## "} /^##@ / {printf "\n%s\n", substr($$0, 5)} \
		/^[a-zA-Z_-]+:.*## / {printf "  %-18s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

##@ BUILD
.PHONY: build
build: ## Build the collection tarball into dist/
	@mkdir -p $(DIST_DIR)
	$(UV_ANSIBLE) ansible-galaxy collection build --output-path $(DIST_DIR) --force

##@ TEST
.PHONY: test
test: build ## Dry run the role in a throwaway Ubuntu 24.04 container
	@rm -rf $(COLLECTIONS_DIR)
	# Name the tarball rather than glob it, because dist/ keeps every version
	# ever built and a glob asks galaxy to resolve all of them at once.
	# Pass --force, because galaxy resolves "already installed" against the configured
	# collections path as well as -p, so a copy in ~/.ansible makes this a no-op
	# and the playbook is then not found.
	$(UV_ANSIBLE) ansible-galaxy collection install $(TARBALL) -p $(COLLECTIONS_DIR) --force
	$(UV_ANSIBLE) ansible-galaxy collection install community.docker -p $(COLLECTIONS_DIR)
	docker build --quiet --tag $(CONTAINER) tests
	-@docker rm --force $(CONTAINER) >/dev/null 2>&1
	docker run --detach --name $(CONTAINER) --privileged --cgroupns=host \
		--volume /sys/fs/cgroup:/sys/fs/cgroup:rw $(CONTAINER) >/dev/null
	@docker exec $(CONTAINER) sh -c \
		'until systemctl is-system-running --wait 2>/dev/null | grep -qE "running|degraded"; \
		do sleep 1; done'
	@docker exec $(CONTAINER) apt-get update --quiet >/dev/null
	ANSIBLE_COLLECTIONS_PATH=$(COLLECTIONS_DIR) $(UV_ANSIBLE) ansible-playbook \
		$(PLAYBOOK) -i '$(CONTAINER),' -c community.docker.docker --check --diff

##@ LINT
.PHONY: lint
lint: ## Run ansible-lint at the production profile
	uv run ansible-lint

.PHONY: check_version
check_version: ## Verify CHANGELOG.md has an entry for the galaxy.yml version
	@grep -q "^## $(VERSION) - " CHANGELOG.md || { \
		echo "[!] CHANGELOG.md has no entry for version $(VERSION)"; exit 1; }
	@echo "[*] Version $(VERSION) is in the changelog"

.PHONY: check_version_tag
check_version_tag: ## Verify TAG matches the collection version, leading v stripped
	@test "$(TAG:v%=%)" = "$(VERSION)" || { \
		echo "[!] Tag '$(TAG)' does not match version $(VERSION)"; exit 1; }
	@echo "[*] Tag $(TAG) matches version $(VERSION)"

##@ GET
.PHONY: get_version
get_version: ## Print the collection version from galaxy.yml
	@echo $(VERSION)

.PHONY: get_changelog
get_changelog: ## Print the changelog section for the current version
	@awk -v v="$(VERSION)" '$$0 ~ "^## "v" " {f=1; next} f && /^## / {exit} f' CHANGELOG.md

##@ CI
.PHONY: ci
ci: lint check_version test ## Run everything CI runs

.PHONY: clean
clean: ## Remove build output, the lint cache and the test container
	rm -rf $(DIST_DIR) .ansible
	-docker rm --force $(CONTAINER) 2>/dev/null
