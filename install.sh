#!/usr/bin/env bash

set -ev

# ** Install Ubuntu base packages
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -yq \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg2 \
  python-pip \
  python-minimal

mkdir -p /etc/docker/

# Switch to aufs storage to speedup « Mapping UID and GID for git:git to 1010:1010 » (see https://github.com/docker/for-linux/issues/388#issuecomment-422205382)
tee -a /etc/docker/daemon.json > /dev/null <<EOF
{
  "storage-driver": "aufs"
}
EOF

# ** Install Docker
# shellcheck disable=SC2024
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" > /etc/apt/sources.list.d/docker.list
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-get update -y
apt-get install -y docker-ce
pip install docker-compose

# Wait GitLab is up
while [[ "$(curl -s -o /dev/null -w '%{http_code}' -k https://gitlab.example.com/)" == "502" ]]; do sleep 1; done

echo "Done"
