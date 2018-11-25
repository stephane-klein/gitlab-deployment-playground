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

# Switch to aufs storage to speedup « Mapping UID and GID for git:git to 1010:1010 » (see https://github.com/docker/for-linux/issues/388#issuecomment-422205382)
sed -i "s|ExecStart=/usr/bin/dockerd -H fd://|ExecStart=/usr/bin/dockerd -H fd:// --storage-driver=aufs|" /lib/systemd/system/docker.service
systemctl  daemon-reload
systemctl restart docker

echo "Done"
