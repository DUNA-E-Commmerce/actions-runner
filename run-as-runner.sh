#!/bin/bash

echo "🔄 Switching to runner user for GitHub Actions"
echo "============================================="

# Wait for Docker to be ready
echo "⏳ Waiting for Docker daemon..."
/home/runner/bin/docker-health.sh

if [ $? -eq 0 ]; then
    echo "✅ Docker is ready! Switching to runner user..."

    # Switch to runner user and execute the GitHub Actions runner
    exec su - runner -c "cd /home/runner && ./run.sh"
else
    echo "❌ Docker failed to start. Cannot continue."
    exit 1
fi