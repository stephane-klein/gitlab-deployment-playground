#!/usr/bin/env bash
mkdir -p certs

if [ ! -f certs/registry.crt ]; then
  openssl req \
    -newkey rsa:4096 \
    -x509 \
    -sha256 \
    -days 100000 \
    -subj /CN=registry_auth_token \
    -nodes \
    -out certs/registry.crt \
    -keyout certs/registry.key
fi
