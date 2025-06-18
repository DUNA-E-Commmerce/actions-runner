#!/bin/bash

echo "🔧 GitHub Actions Runner Configuration Helper"
echo "=============================================="

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <repo-url> <token>"
    echo ""
    echo "Example:"
    echo "  $0 https://github.com/owner/repo ghs_xxxxxxxxxxxxxxxxxxxx"
    echo ""
    echo "📋 To get a token:"
    echo "  1. Go to your GitHub repository"
    echo "  2. Settings > Actions > Runners"
    echo "  3. Click 'New self-hosted runner'"
    echo "  4. Copy the token from the configuration command"
    echo ""
    echo "🔧 Or configure manually:"
    echo "  docker-compose exec actions-runner bash"
    echo "  su - runner"
    echo "  cd /home/runner"
    echo "  ./config.sh --url <repo-url> --token <token> --unattended"
    exit 1
fi

REPO_URL="$1"
TOKEN="$2"

echo "🔗 Repository: $REPO_URL"
echo "🔑 Token: ${TOKEN:0:10}..."

# Check if container is running
if ! docker-compose ps actions-runner | grep -q "Up"; then
    echo "❌ Container is not running. Starting it first..."
    docker-compose up -d actions-runner
    echo "⏳ Waiting for container to be ready..."
    sleep 15
fi

# Wait for Docker to be ready inside container
echo "⏳ Waiting for Docker daemon inside container..."
timeout=60
counter=0
while [ $counter -lt $timeout ]; do
    if docker-compose exec -T actions-runner docker version >/dev/null 2>&1; then
        echo "✅ Docker is ready inside container!"
        break
    fi
    sleep 2
    counter=$((counter + 2))
    echo "⏳ Waiting for Docker... ($counter/$timeout seconds)"
done

if [ $counter -eq $timeout ]; then
    echo "❌ Docker failed to start inside container"
    exit 1
fi

# Enter the container and configure
echo "🚀 Configuring runner in container..."
docker-compose exec -T actions-runner su - runner -c "
    cd /home/runner
    echo '🔧 Configuring GitHub Actions Runner...'
    
    # Remove any existing configuration
    if [ -f '.runner' ]; then
        echo '🧹 Removing existing configuration...'
        ./config.sh remove --token '$TOKEN' || true
    fi
    
    # Configure the runner
    ./config.sh --url '$REPO_URL' --token '$TOKEN' --name 'docker-local-runner' --work '_work' --labels 'self-hosted,docker,local' --unattended
    
    if [ \$? -eq 0 ]; then
        echo '✅ Configuration successful!'
    else
        echo '❌ Configuration failed!'
        exit 1
    fi
"

if [ $? -eq 0 ]; then
    echo "🔄 Restarting container to apply changes..."
    docker-compose restart actions-runner
    echo ""
    echo "✅ Runner configured and restarted!"
    echo "📋 Check status with: docker-compose logs -f actions-runner"
    echo "🐳 Test Docker with: docker-compose exec actions-runner docker version"
else
    echo "❌ Configuration failed!"
    exit 1
fi