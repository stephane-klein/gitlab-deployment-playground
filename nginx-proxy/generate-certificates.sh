#!/usr/bin/env bash
mkdir -p certs

if [ ! -f certs/registry.example.com.crt ]; then
  openssl req \
    -newkey rsa:4096 \
    -x509 \
    -sha256 \
    -days 100000 \
    -subj /CN=registry.example.com \
    -nodes \
    -out certs/registry.example.com.crt \
    -keyout certs/registry.example.com.key
fi

if [ ! -f certs/gitlab.example.com.crt ]; then
  openssl req \
    -newkey rsa:4096 \
    -x509 \
    -sha256 \
    -days 100000 \
    -subj /CN=gitlab.example.com \
    -nodes \
    -out certs/gitlab.example.com.crt \
    -keyout certs/gitlab.example.com.key
fi
