#!/bin/bash

echo "🔍 Docker Health Check"
echo "====================="

# Wait for Docker to be ready
TIMEOUT=60
COUNTER=0

echo "⏳ Waiting for Docker daemon to be ready..."

while [ $COUNTER -lt $TIMEOUT ]; do
    if docker version >/dev/null 2>&1; then
        echo "✅ Docker daemon is ready!"
        echo "📋 Docker Info:"
        docker version --format 'Client: {{.Client.Version}} | Server: {{.Server.Version}}'
        docker info | head -5
        exit 0
    fi

    sleep 2
    COUNTER=$((COUNTER + 2))
    echo "⏳ Waiting... ($COUNTER/$TIMEOUT seconds)"
done

echo "❌ Docker daemon failed to start within $TIMEOUT seconds"
echo "📋 Checking processes:"
ps aux | grep docker
echo "📋 Checking logs:"
journalctl -u docker --no-pager --lines=10 2>/dev/null || echo "No systemd logs available"
exit 1