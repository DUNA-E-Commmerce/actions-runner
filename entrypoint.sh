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

# Wait for Docker to be ready
wait_for_docker() {
    echo "⏳ Waiting for Docker daemon to be ready..."
    TIMEOUT=30
    COUNTER=0

    while [ $COUNTER -lt $TIMEOUT ]; do
        if docker version >/dev/null 2>&1; then
            echo "✅ Docker daemon is ready!"
            return 0
        fi
        sleep 2
        COUNTER=$((COUNTER + 2))
        echo "⏳ Waiting... ($COUNTER/$TIMEOUT seconds)"
    done

    echo "❌ Docker daemon failed to start"
    return 1
}

# Start Docker daemon
start_docker

# Wait for Docker to be ready
if ! wait_for_docker; then
    echo "❌ Exiting due to Docker startup failure"
    exit 1
fi

# Switch to runner user and execute the command
echo "🔄 Switching to runner user..."
cd /home/runner

#exec su - runner -c "ls -lha /home/runner/"
exec su - runner -c "/home/runner/run.sh"