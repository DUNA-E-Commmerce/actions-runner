# Variables de configuración
IMAGE_NAME := github-runner-ubuntu
IMAGE_TAG := latest
CONTAINER_NAME := github-runner

# Variables de construcción
GO_VERSION := 1.23.2
RUNNER_VERSION := 2.323.0
DOCKER_BUILDKIT := 1

# Colores para output
GREEN := \033[32m
BLUE := \033[34m
CYAN := \033[36m
NC := \033[0m # No Color

.PHONY: build
build: ## 🔨 Construir la imagen Docker
	@echo "$(BLUE)🔨 Construyendo imagen Docker para linux/amd64...$(NC)"
	@DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) docker build \
		--platform linux/amd64 \
		--build-arg GO_VERSION=$(GO_VERSION) \
		--build-arg RUNNER_VERSION=$(RUNNER_VERSION) \
		--tag $(IMAGE_NAME):$(IMAGE_TAG) \
		.
	@echo "$(GREEN)✅ Imagen construida: $(IMAGE_NAME):$(IMAGE_TAG) (linux/amd64)$(NC)"

.PHONY: run
run: ## 🚀 Ejecutar el contenedor
	@echo "$(BLUE)🚀 Ejecutando contenedor...$(NC)"
	@docker run -it --rm \
		--name $(CONTAINER_NAME) \
		--platform linux/amd64 \
		$(IMAGE_NAME):$(IMAGE_TAG) \
		/bin/bash

.PHONY: test
test: ## 🧪 Probar que todas las herramientas funcionan
	@echo "$(BLUE)🧪 Probando herramientas instaladas...$(NC)"
	@docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) sh -c "\
		echo '$(CYAN)=== AWS CLI ===$(NC)' && aws --version && \
		echo '$(CYAN)=== Node.js ===$(NC)' && node --version && npm --version && \
		echo '$(CYAN)=== Go ===$(NC)' && go version && \
		echo '$(CYAN)=== Python ===$(NC)' && python3.11 --version && \
		echo '$(CYAN)=== Make ===$(NC)' && make --version && \
		echo '$(CYAN)=== Tree ===$(NC)' && tree --version" && \
		echo '$(CYAN)=== Sam Local ===$(NC)' && sam --version
	@echo "$(GREEN)✅ Todas las herramientas funcionan correctamente$(NC)"