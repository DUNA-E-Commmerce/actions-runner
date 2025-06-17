#!/bin/bash

echo "🚀 Starting GitHub Actions Runner Container with Docker-in-Docker"
echo "================================================================="

# Check if we should start Docker daemon
if [ "$1" = "dockerd" ] || [ -z "$1" ]; then
    echo "🐳 Configuring Docker daemon startup as root..."
    
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
fi

# Start with dumb-init for proper signal handling
echo "🏃 Starting with dumb-init: $@"
exec /usr/local/bin/dumb-init "$@"