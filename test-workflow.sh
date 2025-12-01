#!/bin/bash
#
# Script de prueba que simula un workflow típico de GitHub Actions
# Ejecuta esto dentro del runner para verificar que todas las herramientas funcionan
#

set -e

echo "🧪 Iniciando prueba de workflow simulado..."
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para imprimir con color
print_step() {
    echo -e "${BLUE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# 1. Verificar Docker
print_step "Verificando Docker..."
if docker version >/dev/null 2>&1; then
    print_success "Docker está funcionando"
    docker version | head -5
else
    print_error "Docker no está disponible"
    exit 1
fi
echo ""

# 2. Probar Docker pull
print_step "Probando Docker pull..."
docker pull alpine:latest
print_success "Docker pull funciona"
echo ""

# 3. Probar Docker run
print_step "Probando Docker run..."
docker run --rm alpine:latest echo "Hello from Alpine!"
print_success "Docker run funciona"
echo ""

# 4. Probar Docker build
print_step "Probando Docker build..."
mkdir -p /tmp/test-build
cat > /tmp/test-build/Dockerfile <<'EOF'
FROM alpine:latest
RUN echo "Test build successful"
CMD ["echo", "Container is working!"]
EOF

docker build -t test-image:latest /tmp/test-build
docker run --rm test-image:latest
docker rmi test-image:latest
rm -rf /tmp/test-build
print_success "Docker build funciona"
echo ""

# 5. Probar Go
print_step "Probando Go..."
mkdir -p /tmp/test-go
cd /tmp/test-go
cat > main.go <<'EOF'
package main
import "fmt"
func main() {
    fmt.Println("Go is working!")
}
EOF

go run main.go
rm -rf /tmp/test-go
print_success "Go funciona"
echo ""

# 6. Probar Python
print_step "Probando Python 3.11..."
python3.11 -c "print('Python 3.11 is working!')"
python3.11 -m pip --version
print_success "Python funciona"
echo ""

# 7. Probar Node.js
print_step "Probando Node.js..."
node -e "console.log('Node.js is working!')"
npm --version
print_success "Node.js funciona"
echo ""

# 8. Probar AWS CLI
print_step "Probando AWS CLI..."
aws --version
print_success "AWS CLI funciona"
echo ""

# 9. Probar SAM CLI
print_step "Probando SAM CLI..."
sam --version
print_success "SAM CLI funciona"
echo ""

# 10. Probar Git
print_step "Probando Git..."
git --version
print_success "Git funciona"
echo ""

# 11. Probar Docker Compose (si está disponible)
print_step "Probando Docker Compose..."
if docker compose version >/dev/null 2>&1; then
    docker compose version
    print_success "Docker Compose funciona"
else
    print_info "Docker Compose no está disponible (opcional)"
fi
echo ""

# 12. Verificar espacio en disco
print_step "Verificando espacio en disco..."
df -h /home/runner/_work
print_success "Espacio verificado"
echo ""

# 13. Verificar permisos
print_step "Verificando permisos..."
print_info "Usuario actual: $(whoami)"
print_info "UID/GID: $(id)"
print_info "Grupos: $(groups)"
touch /home/runner/_work/test-file
rm /home/runner/_work/test-file
print_success "Permisos de escritura OK"
echo ""

# 14. Simular un workflow más complejo
print_step "Simulando workflow complejo (checkout + build + test)..."

# Simular checkout
mkdir -p /home/runner/_work/test-project
cd /home/runner/_work/test-project

# Simular un proyecto Go
cat > main.go <<'EOF'
package main

import (
    "fmt"
    "testing"
)

func Add(a, b int) int {
    return a + b
}

func main() {
    result := Add(2, 3)
    fmt.Printf("2 + 3 = %d\n", result)
}
EOF

cat > main_test.go <<'EOF'
package main

import "testing"

func TestAdd(t *testing.T) {
    result := Add(2, 3)
    if result != 5 {
        t.Errorf("Expected 5, got %d", result)
    }
}
EOF

# Inicializar módulo Go
go mod init test-project

# Ejecutar tests
go test -v

# Build
go build -o app

# Ejecutar
./app

# Limpiar
cd /home/runner
rm -rf /home/runner/_work/test-project

print_success "Workflow complejo completado"
echo ""

# Resumen final
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "🎉 Todas las pruebas pasaron exitosamente!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_info "El runner está listo para ejecutar workflows de GitHub Actions"
echo ""

# Mostrar información del sistema
print_step "Información del sistema:"
echo "  - OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "  - Kernel: $(uname -r)"
echo "  - Arquitectura: $(uname -m)"
echo "  - Memoria disponible: $(free -h | grep Mem | awk '{print $7}')"
echo ""

exit 0
