# =============================================================================
# STAGE 1: AWS CLI Builder
# =============================================================================
FROM ubuntu:22.04 AS aws-cli-builder

RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates \
    curl \
    unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

RUN curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
    unzip awscliv2.zip && \
    ./aws/install --install-dir /aws-cli-install --bin-dir /aws-cli-install/bin && \
    rm -rf awscliv2.zip aws

# =============================================================================
# STAGE 2: Go Builder
# =============================================================================
FROM ubuntu:22.04 AS go-builder

RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates \
    curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

ARG GO_VERSION=1.23.2
RUN curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

# =============================================================================
# IMAGEN PRINCIPAL - Ubuntu 22.04 (ULTRA CONSERVADORA)
# =============================================================================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Actualizar sistema base
RUN apt-get update && apt-get upgrade -y

# Instalar herramientas básicas (paso 1)
RUN apt-get install --no-install-recommends -y \
    ca-certificates \
    curl \
    wget \
    gnupg \
    lsb-release && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar sudo (paso 2)
RUN apt-get update && apt-get install --no-install-recommends -y sudo && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Crear usuario runner (paso 3)
RUN useradd -m -s /bin/bash runner

# Agregar usuario al grupo sudo (paso 4)
RUN usermod -aG sudo runner && \
    echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Instalar herramientas de desarrollo (paso 5)
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    git \
    make \
    tree \
    unzip \
    jq \
    iputils-ping && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar software-properties-common (paso 6)
RUN apt-get update && apt-get install --no-install-recommends -y \
    software-properties-common && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Agregar repositorio Python deadsnakes (paso 7)
RUN add-apt-repository ppa:deadsnakes/ppa -y

# Instalar Python 3.11 (paso 8)
RUN apt-get update && apt-get install --no-install-recommends -y \
    python3.11 \
    python3.11-dev \
    python3.11-distutils \
    python3.11-venv && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar Node.js repository (paso 9)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

# Instalar Node.js (paso 10)
RUN apt-get update && apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copiar binarios desde builders
COPY --from=aws-cli-builder /aws-cli-install /aws-cli-install
COPY --from=go-builder /usr/local/go /usr/local/go

# Configurar variables de entorno
ENV PATH="/aws-cli-install/bin:/usr/local/go/bin:${PATH}"
ENV GOPATH="/home/runner/go"
ENV GOROOT="/usr/local/go"

# Configurar Python 3.11
RUN ln -sf /usr/bin/python3.11 /usr/local/bin/python3.11

# Instalar pip para Python 3.11
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11

# Actualizar pip y herramientas básicas
RUN python3.11 -m pip install --upgrade pip setuptools wheel

# Cambiar al directorio del runner
WORKDIR /home/runner

# Instalar GitHub Actions Runner
ARG RUNNER_VERSION=2.323.0
RUN curl -fsSL https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -o runner.tar.gz && \
    tar xzf runner.tar.gz && \
    rm runner.tar.gz

# Instalar dependencias del runner
RUN ./bin/installdependencies.sh

# Crear directorio Go y configurar permisos
RUN mkdir -p /home/runner/go && \
    chown -R runner:runner /home/runner

# Actualizar PATH final
ENV PATH="/home/runner/.local/bin:${PATH}"

# Cambiar a usuario runner
USER runner

# Verificaciones finales
RUN echo "=== Verificando instalaciones ===" && \
    aws --version && \
    node --version && \
    npm --version && \
    go version && \
    python3.11 --version && \
    python3.11 -m pip --version && \
    make --version && \
    tree --version

WORKDIR /home/runner

CMD ["./run.sh"]