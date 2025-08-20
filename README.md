# GitHub Self-Hosted Runner Docker Image

> 🚀 Imagen Docker personalizada para GitHub Actions Self-Hosted Runners con herramientas de desarrollo pre-instaladas.

## 📦 Herramientas Incluidas

| Herramienta | Versión | Propósito |
|-------------|---------|-----------|
| **AWS CLI** | v2 | Interacción con servicios AWS |
| **SAM CLI** | latest | Desarrollo y testing de aplicaciones serverless |
| **Node.js** | 18 | Runtime JavaScript y npm |
| **Go** | 1.23.2 | Compilador y herramientas Go |
| **Python** | 3.11 | Intérprete Python con pip |
| **GitHub Actions Runner** | 2.323.0 | Ejecutor de workflows |
| **Herramientas básicas** | - | git, make, tree, curl, wget, jq |

## 🛠️ Uso Rápido

### Prerequisitos
- Docker instalado
- Make (opcional)

### Comandos disponibles

```bash
# Ver todos los comandos disponibles
make help

# Construir la imagen Docker
make build

# Probar que todas las herramientas funcionan
make test

# Ejecutar el contenedor interactivamente
make run
```

### Flujo de desarrollo típico

```bash
# 1. Construir la imagen
make build

# 2. Verificar que todo funciona
make test

# 3. Ejecutar el contenedor
make run
```

## 📋 Configuración del Runner

Una vez dentro del contenedor, configura el GitHub Actions Runner:

```bash
# Configurar el runner con tu token y repositorio
./config.sh --url https://github.com/tu-org/tu-repo --token TU_TOKEN

# Ejecutar el runner
./run.sh
```

## ⚡ Uso de SAM Local

SAM Local está incluido para desarrollo serverless. Algunos comandos útiles:

```bash
# Inicializar un nuevo proyecto SAM
sam init

# Construir la aplicación
sam build

# Ejecutar API Gateway localmente
sam local start-api

# Invocar función Lambda localmente
sam local invoke "FunctionName"

# Probar con eventos
sam local generate-event s3 put | sam local invoke "FunctionName"
```

### 🐳 Consideraciones para SAM Local

Para usar SAM Local efectivamente en el contenedor:

```bash
# Ejecutar con acceso a Docker socket
docker run -it --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd):/workspace \
  -p 3000:3000 \
  --platform linux/amd64 \
  github-runner-ubuntu:latest /bin/bash

# Dentro del contenedor
cd /workspace
sam init
sam build
sam local start-api --host 0.0.0.0
```

## 🔧 Configuración Manual

Si prefieres usar Docker directamente:

```bash
# Construir la imagen
docker build --platform linux/amd64 -t github-runner-ubuntu:latest .

# Ejecutar el contenedor
docker run -it --rm --platform linux/amd64 github-runner-ubuntu:latest /bin/bash

# Probar herramientas
docker run --rm github-runner-ubuntu:latest sh -c "aws --version && sam --version && node --version && go version"
```

## 🚀 Deploy Automático

Este proyecto incluye GitHub Actions para deploy automático a GitHub Container Registry:

- **Trigger**: Push a branch `main` o cambios en `Dockerfile`, `Makefile`, o workflows
- **Destino**: GitHub Container Registry (`ghcr.io`)
- **Imagen**: `ghcr.io/tu-org/tu-repo:latest`
- **Plataforma**: `linux/amd64`

### Pull de la imagen

```bash
# Hacer login a GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u tu-usuario --password-stdin

# Pull de la imagen (nota: el nombre debe estar en minúsculas)
docker pull ghcr.io/duna-e-commmerce/actions-runner:latest

# Ejecutar la imagen
docker run -it --rm --platform linux/amd64 ghcr.io/duna-e-commmerce/actions-runner:latest /bin/bash
```

### Permisos requeridos

El workflow usa `GITHUB_TOKEN` automáticamente con permisos de `packages: write` para subir a GHCR.

## 📁 Estructura del Proyecto

```
├── Dockerfile              # Imagen multi-stage optimizada
├── Makefile                # Comandos para desarrollo
├── .github/
│   └── workflows/
│       └── build-deploy.yml # CI/CD pipeline
└── README.md               # Este archivo
```

## 🎯 Características

- ✅ **Multi-stage build** para optimización de tamaño
- ✅ **Cache inteligente** para builds rápidos
- ✅ **Plataforma específica** linux/amd64
- ✅ **Usuario no-root** para seguridad
- ✅ **Herramientas verificadas** con testing automático
- ✅ **Deploy automático** a GitHub Container Registry
- ✅ **SAM Local incluido** para desarrollo serverless
- ✅ **SAM Local incluido** para desarrollo serverless

## 🐛 Troubleshooting

### Problema: Error de permisos
```bash
# Verificar que el usuario runner tiene permisos sudo
docker run --rm github-runner-ubuntu:latest whoami
```

### Problema: Herramienta no encontrada
```bash
# Verificar instalaciones
make test
```

### Problema: Build lento
```bash
# Usar cache de Docker
export DOCKER_BUILDKIT=1
make build
```

### Problema: SAM Local no funciona
```bash
# Verificar instalación de SAM
sam --version

# Verificar que Docker está disponible para SAM
docker --version
```

## 📄 Variables de Configuración

Puedes personalizar las versiones editando el Makefile:

```makefile
GO_VERSION := 1.23.2        # Versión de Go
RUNNER_VERSION := 2.323.0   # Versión del GitHub Runner
IMAGE_NAME := github-runner-ubuntu
```

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-herramienta`)
3. Commit tus cambios (`git commit -am 'Agregar nueva herramienta'`)
4. Push a la rama (`git push origin feature/nueva-herramienta`)
5. Abre un Pull Request

## 📞 Soporte

Para problemas o sugerencias:

- 🐛 **Issues**: Abre un issue en GitHub
- 💬 **Discusiones**: Usa GitHub Discussions
- 📧 **Email**: Contacta al equipo de DevOps

---

> **Nota**: Esta imagen está optimizada para usar como GitHub Self-Hosted Runner en entornos de desarrollo y CI/CD con soporte completo para desarrollo serverless usando AWS SAM.