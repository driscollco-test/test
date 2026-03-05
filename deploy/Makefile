# deploy/Makefile

CHART_DIR     := ./charts/service
CHART_VALUES  := $(CHART_DIR)/values.yaml
BASE_CHART    := ./charts/base

# Dockerfile path must be relative to repo root because docker build runs after `cd ..`
DOCKERFILE    := deploy/docker/Dockerfile
REPO_ROOT     := ..

# Read values from charts/service/values.yaml
name       := $(shell yq e '.service.name' $(CHART_VALUES))
namespace  := $(shell yq e '.service.namespace' $(CHART_VALUES))
tag        := $(shell yq e '.service.image.tag // "latest"' $(CHART_VALUES))

name      := $(if $(name),$(name),my-service)
namespace := $(if $(namespace),$(namespace),default)
tag       := $(if $(tag),$(tag),latest)

# End-user files live in charts/service/files/
# Copy them into charts/base/files/ so the base chart can access them via .Files.*
USER_FILES_DIR := $(CHART_DIR)/files
BASE_FILES_DIR := $(BASE_CHART)/files

.PHONY: files-sync
files-sync:
	@mkdir -p $(BASE_FILES_DIR)
	@if [ -d "$(USER_FILES_DIR)" ]; then \
		echo "Syncing chart files: $(USER_FILES_DIR) -> $(BASE_FILES_DIR)"; \
		rsync -a --delete "$(USER_FILES_DIR)/" "$(BASE_FILES_DIR)/"; \
	else \
		echo "No files dir found at $(USER_FILES_DIR) (skipping)"; \
	fi

.PHONY: vendor
vendor:
	@cd $(REPO_ROOT) && go mod vendor

.PHONY: docker
docker: vendor
	@echo "Building image $(name):$(tag)"
	@cd $(REPO_ROOT) && docker build --platform=linux/amd64 \
		-f $(DOCKERFILE) \
		-t $(name):$(tag) \
		.
	@rm -rf $(REPO_ROOT)/vendor

.PHONY: helm-deps
helm-deps:
	@echo "Updating chart dependencies in $(CHART_DIR)"
	@cd $(CHART_DIR) && helm dependency update

.PHONY: template
template: helm-deps files-sync
	@helm template $(name) $(CHART_DIR) \
		--namespace $(namespace)

.PHONY: deploy
deploy: helm-deps files-sync
	@helm upgrade --history-max 1 --install $(name) $(CHART_DIR) \
		--namespace $(namespace) --create-namespace

.PHONY: up
up: docker deploy