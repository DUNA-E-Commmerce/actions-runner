#!/bin/bash

echo "Checking Docker connectivity..."

# Check if docker socket exists
if [ -S /var/run/docker.sock ]; then
    echo "✓ Docker socket found at /var/run/docker.sock"
else
    echo "✗ Docker socket not found at /var/run/docker.sock"
    echo "Make sure to mount the socket with: -v /var/run/docker.sock:/var/run/docker.sock"
fi

# Check if docker command works
if docker version >/dev/null 2>&1; then
    echo "✓ Docker command works"
    docker version --format 'Client: {{.Client.Version}} | Server: {{.Server.Version}}'
else
    echo "✗ Docker command failed"
    echo "Error details:"
    docker version
fi

# Check user groups
echo "Current user groups: $(groups)"

# Check docker daemon connection
if docker info >/dev/null 2>&1; then
    echo "✓ Docker daemon connection successful"
else
    echo "✗ Cannot connect to Docker daemon"
    echo "This usually means:"
    echo "1. Docker socket is not mounted"
    echo "2. User doesn't have permission to access Docker"
    echo "3. Docker daemon is not running on host"
fi