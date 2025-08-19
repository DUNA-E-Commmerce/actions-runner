# =============================================================================
# GitHub Self-Hosted Runner Docker Image - Makefile
# =============================================================================

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

# =============================================================================
# Comandos principales
# =============================================================================

.PHONY: help
help: ## 📚 Mostrar esta ayuda
	@echo "$(CYAN)GitHub Self-Hosted Runner Docker - Comandos disponibles:$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-10s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""

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
		echo '=== AWS CLI ===' && aws --version && \
		echo '=== Node.js ===' && node --version && npm --version && \
		echo '=== Go ===' && go version && \
		echo '=== Python ===' && python3.11 --version && \
		echo '=== Make ===' && make --version && \
		echo '=== Tree ===' && tree --version"
	@echo "$(GREEN)✅ Todas las herramientas funcionan correctamente$(NC)"

# Comando por defecto
.DEFAULT_GOAL := help