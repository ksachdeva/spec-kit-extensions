FROM mcr.microsoft.com/devcontainers/python:3.14-trixie

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get upgrade -y  \
    && apt-get -y install --no-install-recommends build-essential iputils-ping novnc websockify x11vnc xvfb \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

COPY --chmod=644 cloudflare_gateway_ca_g2_722d63.crt /usr/local/share/ca-certificates/cloudflare.crt
RUN sudo update-ca-certificates

ENV SHELL=/bin/zsh
