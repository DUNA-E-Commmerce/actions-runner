#!/bin/bash

echo "🚀 Starting GitHub Actions Runner Container"
echo "==========================================="

# Run docker setup
echo "🔧 Setting up Docker connectivity..."
/home/runner/bin/docker-setup.sh

# Check if docker is working
if docker version >/dev/null 2>&1; then
    echo "✅ Docker is ready!"
else
    echo "⚠️  Docker setup needs manual intervention"
    echo "💡 You can run: docker exec -it <container> /home/runner/bin/docker-setup.sh"
fi

echo ""
echo "🏃 Starting runner with command: $@"

# Execute the original command
exec "$@"