#!/bin/bash

set -ev

# ** Install Ubuntu base packages
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
sudo apt-get install -yq \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg2 \
  python3-pip \
  python-minimal

# ** Install Docker
# shellcheck disable=SC2024
sudo echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" > /etc/apt/sources.list.d/docker.list
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-get update -y
sudo apt-get install -y docker-ce
sudo pip3 install --upgrade pip
sudo pip3 install docker-compose

# Switch to aufs storage to speedup « Mapping UID and GID for git:git to 1010:1010 » (see https://github.com/docker/for-linux/issues/388#issuecomment-422205382)
sudo sed -i "s|ExecStart=/usr/bin/dockerd -H fd://|ExecStart=/usr/bin/dockerd -H fd:// --storage-driver=aufs|" /lib/systemd/system/docker.service
sudo systemctl  daemon-reload
sudo systemctl restart docker

# Expose ssh port in dockerized gitlab-ce
sudo groupadd -g 1010 git
sudo useradd -m -u 1010 -g git -s /bin/sh -d /home/git git
sudo su git -c "mkdir -p /home/git/.ssh/"
sudo su git -c "ssh-keygen -t rsa -N \"\" -f /home/git/.ssh/id_rsa"
sudo su git -c "mv /home/git/.ssh/id_rsa.pub /home/git/.ssh/authorized_keys_proxy"

sudo mkdir -p /home/git/gitlab-shell/bin/
sudo rm -f /home/git/gitlab-shell/bin/gitlab-shell
sudo tee -a /home/git/gitlab-shell/bin/gitlab-shell > /dev/null <<'EOF'
#!/bin/sh

ssh -i /home/git/.ssh/id_rsa -p 9922 -o StrictHostKeyChecking=no git@127.0.0.1 "SSH_ORIGINAL_COMMAND=\"$SSH_ORIGINAL_COMMAND\" $0 $@"
EOF
sudo chown git:git /home/git/gitlab-shell/bin/gitlab-shell
sudo chmod u+x /home/git/gitlab-shell/bin/gitlab-shell

cd /vagrant
sudo docker-compose up -d

until [ -d /var/lib/gitlab/data/.ssh/ ]; do sleep 5; done

sudo chown git:git -R /home/git/.ssh
sudo su git -c "touch /var/lib/gitlab/data/.ssh/authorized_keys"
sudo su git -c "ln -s /var/lib/gitlab/data/.ssh/authorized_keys /home/git/.ssh/authorized_keys"


echo "Done"
