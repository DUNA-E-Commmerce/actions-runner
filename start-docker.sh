#!/bin/bash

echo "🐳 Starting Docker daemon inside container"
echo "=========================================="

# Create docker directory if it doesn't exist
sudo mkdir -p /var/lib/docker

# Start Docker daemon in background
echo "🚀 Starting dockerd..."
sudo dockerd \
    --host=unix:///var/run/docker.sock \
    --host=tcp://127.0.0.1:2376 \
    --storage-driver=vfs \
    --iptables=false \
    --ip-masq=false \
    --bridge=none \
    --insecure-registry=0.0.0.0/0 \
    > /var/log/docker.log 2>&1 &

# Wait for Docker to be ready
echo "⏳ Waiting for Docker daemon to be ready..."
TIMEOUT=30
COUNTER=0

while [ $COUNTER -lt $TIMEOUT ]; do
    if docker version >/dev/null 2>&1; then
        echo "✅ Docker daemon is ready!"
        docker version --format 'Client: {{.Client.Version}} | Server: {{.Server.Version}}'
        break
    fi
    
    sleep 1
    COUNTER=$((COUNTER + 1))
    echo "⏳ Waiting... ($COUNTER/$TIMEOUT)"
done

if [ $COUNTER -eq $TIMEOUT ]; then
    echo "❌ Docker daemon failed to start within $TIMEOUT seconds"
    echo "📋 Docker daemon logs:"
    sudo tail -20 /var/log/docker.log
    exit 1
fi

echo "🎉 Docker daemon started successfully!"