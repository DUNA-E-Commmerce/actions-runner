#!/bin/bash

echo "🔍 Docker Setup and Diagnostics"
echo "================================"

# Check if docker socket exists
if [ -S /var/run/docker.sock ]; then
    echo "✅ Docker socket found at /var/run/docker.sock"
    
    # Check socket permissions
    SOCKET_PERMS=$(ls -la /var/run/docker.sock)
    echo "📋 Socket permissions: $SOCKET_PERMS"
    
    # Get socket group ID
    SOCKET_GID=$(stat -c %g /var/run/docker.sock)
    echo "🆔 Socket group ID: $SOCKET_GID"
    
    # Check if runner user is in docker group
    if groups runner | grep -q docker; then
        echo "✅ Runner user is in docker group"
    else
        echo "❌ Runner user is NOT in docker group"
    fi
    
    # Check if socket is accessible
    if [ -r /var/run/docker.sock ] && [ -w /var/run/docker.sock ]; then
        echo "✅ Socket is readable and writable"
    else
        echo "❌ Socket is not accessible"
        echo "🔧 Attempting to fix permissions..."
        
        # Try to add runner to the socket group
        sudo usermod -aG $SOCKET_GID runner
        
        # Alternative: change socket permissions (less secure)
        # sudo chmod 666 /var/run/docker.sock
    fi
    
else
    echo "❌ Docker socket NOT found at /var/run/docker.sock"
    echo "💡 Make sure to run container with: -v /var/run/docker.sock:/var/run/docker.sock"
    exit 1
fi

# Test docker connection
echo ""
echo "🧪 Testing Docker connection..."
if docker version >/dev/null 2>&1; then
    echo "✅ Docker connection successful!"
    docker version --format 'Client: {{.Client.Version}} | Server: {{.Server.Version}}'
else
    echo "❌ Docker connection failed"
    echo "🔍 Debugging information:"
    echo "Current user: $(whoami)"
    echo "User groups: $(groups)"
    echo "Socket owner: $(stat -c %U:%G /var/run/docker.sock 2>/dev/null || echo 'unknown')"
    echo ""
    echo "🔧 Trying to fix by adding current user to socket group..."
    SOCKET_GID=$(stat -c %g /var/run/docker.sock 2>/dev/null)
    if [ ! -z "$SOCKET_GID" ]; then
        sudo usermod -aG $SOCKET_GID $(whoami)
        echo "⚠️  You may need to restart the container for group changes to take effect"
    fi
fi

echo ""
echo "🐳 Full Docker info:"
docker info 2>&1 | head -20