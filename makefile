IMAGE_NAME := github-runner-ubuntu
IMAGE_TAG := latest
GO_VERSION := 1.23.2
RUNNER_VERSION := 2.323.0

.PHONY: build
build:
	@echo "Construyendo imagen..."
	@DOCKER_BUILDKIT=1 docker build \
		--platform linux/amd64 \
		--build-arg GO_VERSION=$(GO_VERSION) \
		--build-arg RUNNER_VERSION=$(RUNNER_VERSION) \
		--tag $(IMAGE_NAME):$(IMAGE_TAG) \
		.
	@echo "✅ Imagen construida: $(IMAGE_NAME):$(IMAGE_TAG)"

.PHONY: test
test:
	@echo "🧪 Probando herramientas..."
	@docker run --platform linux/amd64 --rm $(IMAGE_NAME):$(IMAGE_TAG) sh -c " \
		aws --version && \
		node --version && \
		go version && \
		python3.11 --version && \
		sam --version && \
		[ -f /home/runner/run.sh ] && echo '✅ run.sh OK' || exit 1"
	@echo "✅ Tests pasaron"

.PHONY: test-dind
test-dind:
	@echo "🐳 Simulando Docker-in-Docker..."
	@docker-compose -f docker-compose.test.yml up --abort-on-container-exit

.PHONY: shell
shell:
	@docker-compose -f docker-compose.test.yml up -d
	@docker-compose -f docker-compose.test.yml exec runner /bin/bash
	@docker-compose -f docker-compose.test.yml down -v

.PHONY: clean
clean:
	@echo "Limpiando..."
	@docker-compose -f docker-compose.test.yml down -v 2>/dev/null || true
	@docker rmi $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null || true
	@echo "✅ Limpieza completa"