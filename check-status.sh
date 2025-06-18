#!/bin/bash

echo "🔍 GitHub Actions Runner Status Check"
echo "====================================="

echo "📋 Container Status:"
docker-compose ps

echo ""
echo "🐳 Docker Status inside container:"
if docker-compose exec -T actions-runner docker version >/dev/null 2>&1; then
    echo "✅ Docker is working!"
    docker-compose exec -T actions-runner docker version --format 'Client: {{.Client.Version}} | Server: {{.Server.Version}}'
else
    echo "❌ Docker is not working"
fi

echo ""
echo "🏃 Runner Configuration:"
if docker-compose exec -T actions-runner test -f /home/runner/.runner >/dev/null 2>&1; then
    echo "✅ Runner is configured"
    docker-compose exec -T actions-runner su - runner -c "cat /home/runner/.runner" | head -3
else
    echo "❌ Runner is NOT configured"
    echo "💡 Use: ./configure-runner.sh <repo-url> <token>"
fi

echo ""
echo "📋 Recent logs:"
docker-compose logs --tail=10 actions-runner