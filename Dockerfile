FROM ubuntu:24.04 AS build

# GitHub runner arguments
ARG RUNNER_VERSION=2.324.0
ARG RUNNER_CONTAINER_HOOKS_VERSION=0.7.0

# Dumb-init version
ARG DUMB_INIT_VERSION=1.2.5

# Other arguments, expose TARGETPLATFORM for multi-arch builds
ARG DEBUG=false
ARG TARGETPLATFORM=linux/amd64

# Set environment variables needed at build or run
ENV DEBIAN_FRONTEND=noninteractive
ENV RUNNER_MANUALLY_TRAP_SIG=1
ENV ACTIONS_RUNNER_PRINT_LOG_TO_STDOUT=1

# Shell setup
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install base software
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  apt-transport-https \
  apt-utils \
  ca-certificates \
  curl \
  gcc \
  git \
  iproute2 \
  iptables \
  jq \
  libyaml-dev \
  locales \
  lsb-release \
  make \
  openssl \
  pigz \
  pkg-config \
  software-properties-common \
  sudo \
  tar \
  time \
  tree \
  tzdata \
  uidmap \
  unzip \
  wget \
  xz-utils \
  zip \
  dbus \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Runner user
RUN adduser --disabled-password --gecos "" --uid 1001 runner \
  && usermod -aG sudo runner \
  && echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Make and set the working directory
RUN mkdir -p /home/runner \
  && chown -R runner:runner /home/runner

WORKDIR /home/runner

# Install Node.js 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - \
  && apt-get install -y nodejs

# Install Python 3.11 and pip
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  python3.11 \
  python3.11-dev \
  python3.11-venv \
  python3-pip \
  && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
  && update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 \
  && python3 -m pip install --upgrade pip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install Go 1.23.2
RUN export ARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) \
  && echo "ARCH: $ARCH" \
  && if [ "$ARCH" = "arm64" ]; then export GO_ARCH=arm64 ; fi \
  && if [ "$ARCH" = "amd64" ]; then export GO_ARCH=amd64 ; fi \
  && curl -fLo go.tar.gz "https://go.dev/dl/go1.23.2.linux-${GO_ARCH}.tar.gz" \
  && tar -C /usr/local -xzf go.tar.gz \
  && rm go.tar.gz

# Install AWS CLI v2
RUN export ARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) \
  && echo "ARCH: $ARCH" \
  && if [ "$ARCH" = "arm64" ]; then export AWS_ARCH=aarch64 ; fi \
  && if [ "$ARCH" = "amd64" ]; then export AWS_ARCH=x86_64 ; fi \
  && curl -fLo awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" \
  && unzip awscliv2.zip \
  && ./aws/install \
  && rm -rf awscliv2.zip aws

# Runner download supports amd64 as x64
RUN export ARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) \
  && echo "ARCH: $ARCH" \
  && if [ "$ARCH" = "amd64" ]; then export ARCH=x64 ; fi \
  && curl -L -o runner.tar.gz https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz \
  && tar xzf ./runner.tar.gz \
  && rm runner.tar.gz \
  && ./bin/installdependencies.sh \
  && apt-get autoclean \
  && rm -rf /var/lib/apt/lists/*

# Install container hooks
RUN curl -f -L -o runner-container-hooks.zip https://github.com/actions/runner-container-hooks/releases/download/v${RUNNER_CONTAINER_HOOKS_VERSION}/actions-runner-hooks-k8s-${RUNNER_CONTAINER_HOOKS_VERSION}.zip \
  && unzip ./runner-container-hooks.zip -d ./k8s \
  && rm runner-container-hooks.zip

# Install dumb-init, arch command on OS X reports "i386" for Intel CPUs regardless of bitness
RUN ARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) \
  && export ARCH \
  && if [ "$ARCH" = "arm64" ]; then export ARCH=aarch64 ; fi \
  && if [ "$ARCH" = "amd64" ] || [ "$ARCH" = "i386" ]; then export ARCH=x86_64 ; fi \
  && curl -f -L -o /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_${ARCH} \
  && chmod +x /usr/local/bin/dumb-init

# Make the rootless runner directory and externals directory executable
RUN mkdir -p /run/user/1001 \
  && chown runner:runner /run/user/1001 \
  && chmod a+x /run/user/1001 \
  && mkdir -p /home/runner/externals \
  && chown runner:runner /home/runner/externals \
  && chmod a+x /home/runner/externals

# Add Go, Python and Node.js to PATH
ENV HOME=/home/runner
ENV PATH="${PATH}:${HOME}/.local/bin:/home/runner/bin:/usr/local/go/bin"
ENV ImageOS=ubuntu24

# Start as runner user
USER runner

CMD ["/home/runner/run.sh"]