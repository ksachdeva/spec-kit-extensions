#!/bin/bash

echo "Configuring Trust for  Cloudflare WARP [Java]..."

CA_FILE="/usr/local/share/ca-certificates/cloudflare.crt"

# Java
keytool -import -cacerts -alias cloudflareg2 -file $CA_FILE -noprompt

echo -e "Configuring Trust for Cloudflare WARP [Java]... \033[32;1mdone\033[0m"
