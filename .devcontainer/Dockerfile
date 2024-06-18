# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.195.0/containers/java/.devcontainer/base.Dockerfile
# [Choice] Java version (use -bullseye variants on local arm64/Apple Silicon): 8, 11, 16, 8-bullseye, 11-bullseye, 16-bullseye, 8-buster, 11-buster, 16-buster
ARG VARIANT=bullseye
FROM mcr.microsoft.com/devcontainers/base:1-${VARIANT}

# Brute force around certificate-inspection
ARG SKIP_APT_PEER_VERIFY="false"
RUN if [ "${SKIP_APT_PEER_VERIFY}" = "true" ]; then \
    touch /etc/apt/apt.conf.d/99verify-peer.conf && echo >>/etc/apt/apt.conf.d/99verify-peer.conf "Acquire { https::Verify-Peer false }"; \
    fi

# Custom CA integration for Java
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive
    
# Add custom CAs
COPY ./ca-trust/*.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

ARG INSTALL_NGROK="false"
RUN if [ "${INSTALL_NGROK}" = "true" ]; then su vscode -c "umask 0002 && mkdir -p /home/vscode/.local/bin && wget -qO- https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.tgz | tar xvz -C /home/vscode/.local/bin && chmod +x /home/vscode/.local/bin/ngrok"; fi

ARG INSTALL_COCOGITTO="true"
ARG COCOGITTO_VERSION="6.1.0"

RUN if [ "${INSTALL_COCOGITTO}" = "true" ]; then \
    su vscode -c "umask 0002 && mkdir -p /home/vscode/.local/bin && wget -qO- https://github.com/cocogitto/cocogitto/releases/download/${COCOGITTO_VERSION}/cocogitto-${COCOGITTO_VERSION}-x86_64-unknown-linux-musl.tar.gz | tar xvz --strip-components=1 -C /home/vscode/.local/bin && chmod +x /home/vscode/.local/bin/cog"; \
    fi

ARG INSTALL_HELMDOCS="true"
ARG HELMDOCS_VERSION="1.13.1"

RUN if [ "${INSTALL_HELMDOCS}" = "true" ]; then \
    su vscode -c "umask 0002 && mkdir -p /home/vscode/.local/bin && wget -qO- https://github.com/norwoodj/helm-docs/releases/download/v${HELMDOCS_VERSION}/helm-docs_${HELMDOCS_VERSION}_Linux_x86_64.tar.gz | tar xz -C /home/vscode/.local/bin && chmod +x /home/vscode/.local/bin/helm-docs"; \
    fi
