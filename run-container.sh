#!/bin/bash

echo "🚀 Running GitHub Actions Runner with Docker-in-Docker"
echo "====================================================="

# Build the image
echo "🔨 Building image..."
docker build -t actions-runner-dind .

# Run the container with necessary privileges for Docker-in-Docker
echo "🏃 Starting container..."
docker run -d \
  --name actions-runner-dind \
  --privileged \
  --cap-add=SYS_ADMIN \
  --security-opt seccomp=unconfined \
  --security-opt apparmor=unconfined \
  --cgroupns=host \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  -e DOCKER_TLS_CERTDIR="" \
  actions-runner-dind

echo "✅ Container started!"
echo "📋 Check logs with: docker logs -f actions-runner-dind"
echo "🔧 Debug with: docker exec -it actions-runner-dind bash"