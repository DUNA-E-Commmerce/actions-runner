#!/bin/bash

echo "🚀 Starting GitHub Actions Runner Container with Docker-in-Docker"
echo "================================================================="

# Start Docker daemon
echo "� Starting Docker daemon..."
/home/runner/bin/start-docker.sh

# Verify Docker is working
if docker version >/dev/null 2>&1; then
    echo "✅ Docker is ready!"
    docker info | head -10
else
    echo "❌ Docker failed to start"
    echo "� Attempting manual setup..."
    /home/runner/bin/docker-setup.sh
fi

echo ""
echo "🏃 Starting runner with command: $@"

# Execute the original command
exec "$@"