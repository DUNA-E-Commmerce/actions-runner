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
    exit 1
fi

REPO_URL="$1"
TOKEN="$2"

echo "🔗 Repository: $REPO_URL"
echo "🔑 Token: ${TOKEN:0:10}..."

# Enter the container and configure
echo "🚀 Configuring runner in container..."
docker-compose exec actions-runner su - runner -c "
    cd /home/runner
    echo '🔧 Configuring GitHub Actions Runner...'
    ./config.sh --url '$REPO_URL' --token '$TOKEN' --name 'docker-local-runner' --work '_work' --labels 'self-hosted,docker,local'
    
    if [ \$? -eq 0 ]; then
        echo '✅ Configuration successful!'
        echo '🔄 Restarting container to apply changes...'
    else
        echo '❌ Configuration failed!'
        exit 1
    fi
"

if [ $? -eq 0 ]; then
    echo "🔄 Restarting container..."
    docker-compose restart actions-runner
    echo "✅ Runner configured and restarted!"
    echo "📋 Check status with: docker-compose logs -f actions-runner"
else
    echo "❌ Configuration failed!"
    exit 1
fi