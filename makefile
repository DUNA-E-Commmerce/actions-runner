# Variables
IMAGE_NAME ?= github-actions-runner
TAG ?= latest
RUNNER_VERSION ?= 2.321.0
CONTAINER_NAME ?= runner-container

# Colores para output
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
NC=\033[0m # No Color

.PHONY: help build run tests clean

# Comando por defecto
help: ## Muestra esta ayuda
	@echo "Comandos disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-10s$(NC) %s\n", $$1, $$2}'

build: ## Construye la imagen Docker
	@echo "$(YELLOW)🔨 Construyendo imagen Docker...$(NC)"
	docker buildx build \
		--platform linux/amd64 \
		--build-arg RUNNER_VERSION=$(RUNNER_VERSION) \
		--build-arg TARGETOS=linux \
		--build-arg TARGETARCH=amd64 \
		-t $(IMAGE_NAME):$(TAG) .
	@echo "$(GREEN)✅ Imagen construida exitosamente: $(IMAGE_NAME):$(TAG)$(NC)"

run: ## Ejecuta el contenedor
	@echo "$(YELLOW)🚀 Iniciando contenedor...$(NC)"
	docker run -d \
		--name $(CONTAINER_NAME) \
		--privileged \
		-v /var/run/docker.sock:/var/run/docker.sock \
		$(IMAGE_NAME):$(TAG)
	@echo "$(GREEN)✅ Contenedor iniciado: $(CONTAINER_NAME)$(NC)"

tests: ## Ejecuta tests básicos del contenedor
	@echo "$(YELLOW)🧪 Ejecutando tests...$(NC)"
	@echo "Verificando que el contenedor esté ejecutándose..."
	@if docker ps | grep -q $(CONTAINER_NAME); then \
		echo "$(GREEN)✅ Contenedor está corriendo$(NC)"; \
	else \
		echo "$(RED)❌ Contenedor no está corriendo$(NC)"; \
		exit 1; \
	fi

	@echo "Verificando herramientas instaladas..."
	@docker exec $(CONTAINER_NAME) python3 --version || echo "$(RED)❌ Python no encontrado$(NC)"
	@docker exec $(CONTAINER_NAME) go version || echo "$(RED)❌ Go no encontrado$(NC)"
	@docker exec $(CONTAINER_NAME) aws --version || echo "$(RED)❌ AWS CLI no encontrado$(NC)"
	@docker exec $(CONTAINER_NAME) sam --version || echo "$(RED)❌ SAM CLI no encontrado$(NC)"
	@docker exec $(CONTAINER_NAME) which tree || echo "$(RED)❌ tree no encontrado$(NC)"
	@docker exec $(CONTAINER_NAME) which make || echo "$(RED)❌ make no encontrado$(NC)"
	@docker exec $(CONTAINER_NAME) which jq || echo "$(RED)❌ jq no encontrado$(NC)"
	@docker exec $(CONTAINER_NAME) which curl || echo "$(RED)❌ curl no encontrado$(NC)"
	@docker exec $(CONTAINER_NAME) which wget || echo "$(RED)❌ wget no encontrado$(NC)"
	@echo "$(GREEN)✅ Tests completados$(NC)"

clean: ## Limpia contenedores e imágenes
	@echo "$(YELLOW)🧹 Limpiando recursos...$(NC)"
	-docker stop $(CONTAINER_NAME)
	-docker rm $(CONTAINER_NAME)
	-docker rmi $(IMAGE_NAME):$(TAG)
	@echo "$(GREEN)✅ Limpieza completada$(NC)"

# Comandos adicionales útiles
stop: ## Detiene el contenedor
	@echo "$(YELLOW)⏹️  Deteniendo contenedor...$(NC)"
	docker stop $(CONTAINER_NAME)
	@echo "$(GREEN)✅ Contenedor detenido$(NC)"

logs: ## Muestra los logs del contenedor
	@echo "$(YELLOW)📋 Mostrando logs del contenedor...$(NC)"
	docker logs -f $(CONTAINER_NAME)