FROM summerwind/actions-runner:latest

USER root

RUN apt-get update && \
    apt-get install -y unzip curl && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws/ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER runner