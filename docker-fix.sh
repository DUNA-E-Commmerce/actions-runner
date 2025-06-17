#!/bin/bash

echo "🔧 Docker Permission Fixer"
echo "=========================="

# Check if running as root for permission changes
if [ "$EUID" -ne 0 ]; then
    echo "⚠️  Some operations may require sudo privileges"
fi

# Get socket info
if [ -S /var/run/docker.sock ]; then
    SOCKET_GID=$(stat -c %g /var/run/docker.sock)
    SOCKET_GROUP=$(stat -c %G /var/run/docker.sock)
    
    echo "📋 Docker socket info:"
    echo "  - Group ID: $SOCKET_GID"
    echo "  - Group Name: $SOCKET_GROUP"
    echo "  - Permissions: $(ls -la /var/run/docker.sock)"
    
    # Check if docker group exists
    if getent group docker >/dev/null 2>&1; then
        DOCKER_GID=$(getent group docker | cut -d: -f3)
        echo "  - Local docker group ID: $DOCKER_GID"
        
        if [ "$SOCKET_GID" != "$DOCKER_GID" ]; then
            echo "⚠️  Socket group ($SOCKET_GID) differs from local docker group ($DOCKER_GID)"
            echo "🔧 Adding user to socket group $SOCKET_GID..."
            sudo groupmod -g $SOCKET_GID docker 2>/dev/null || sudo groupadd -g $SOCKET_GID docker_host
            sudo usermod -aG $SOCKET_GID runner
        fi
    else
        echo "🔧 Creating docker group with GID $SOCKET_GID..."
        sudo groupadd -g $SOCKET_GID docker
        sudo usermod -aG docker runner
    fi
    
    echo ""
    echo "🧪 Testing Docker access..."
    if su - runner -c "docker version >/dev/null 2>&1"; then
        echo "✅ Docker access successful!"
    else
        echo "❌ Still cannot access Docker"
        echo "💡 Try restarting the container or check host Docker daemon"
    fi
    
else
    echo "❌ Docker socket not found!"
    echo "💡 Run container with: docker run -v /var/run/docker.sock:/var/run/docker.sock ..."
fi