#!/bin/bash

echo "🚀 Starting GitHub Actions Runner Container with Docker-in-Docker"
echo "================================================================="

# Función para iniciar Docker en background
start_docker() {
    echo "🐳 Starting Docker daemon as root..."
    
    # Create necessary directories
    mkdir -p /var/lib/docker
    mkdir -p /var/log
    
    # Ensure proper permissions for docker socket
    touch /var/run/docker.sock
    chown root:docker /var/run/docker.sock
    chmod 660 /var/run/docker.sock
    
    # Start Docker daemon in background
    /usr/local/bin/dumb-init dockerd \
        --host=unix:///var/run/docker.sock \
        --host=tcp://127.0.0.1:2376 \
        --storage-driver=vfs \
        --iptables=false \
        --ip-masq=false \
        --bridge=none \
        --insecure-registry=0.0.0.0/0 \
        --log-level=info &
    
    echo "🔧 Docker daemon started in background"
}

# Check if we should start the runner
if [[ "$1" == *"run.sh"* ]] || [[ "$1" == *"runner"* ]]; then
    echo "🏃 Preparing to start GitHub Actions Runner..."
    
    # Start Docker daemon first
    start_docker
    
    # Wait for Docker to be ready
    echo "⏳ Waiting for Docker daemon to be ready..."
    TIMEOUT=30
    COUNTER=0
    
    while [ $COUNTER -lt $TIMEOUT ]; do
        if docker version >/dev/null 2>&1; then
            echo "✅ Docker daemon is ready!"
            break
        fi
        sleep 2
        COUNTER=$((COUNTER + 2))
        echo "⏳ Waiting... ($COUNTER/$TIMEOUT seconds)"
    done
    
    if [ $COUNTER -eq $TIMEOUT ]; then
        echo "❌ Docker daemon failed to start"
        exit 1
    fi
    
    # Switch to runner user and execute the command
    echo "🔄 Switching to runner user..."
    cd /home/runner
    exec su - runner -c "cd /home/runner && $*"
    
elif [ "$1" = "dockerd" ]; then
    echo "🐳 Starting Docker daemon only..."
    
    # Create necessary directories
    mkdir -p /var/lib/docker
    mkdir -p /var/log
    
    # Ensure proper permissions for docker socket
    touch /var/run/docker.sock
    chown root:docker /var/run/docker.sock
    chmod 660 /var/run/docker.sock
    
    # Set Docker daemon arguments
    set -- dockerd \
        --host=unix:///var/run/docker.sock \
        --host=tcp://127.0.0.1:2376 \
        --storage-driver=vfs \
        --iptables=false \
        --ip-masq=false \
        --bridge=none \
        --insecure-registry=0.0.0.0/0 \
        --log-level=info
    
    echo "🔧 Docker will start with: $@"
    # Start with dumb-init for proper signal handling
    exec /usr/local/bin/dumb-init "$@"
else
    echo "🔧 Running custom command: $@"
    exec /usr/local/bin/dumb-init "$@"
fi