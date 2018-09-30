#!/usr/bin/env bash
set -ev

if ! id -u git >> /dev/null 2>&1; then
  groupadd -g 1010 git
  useradd -m -u 1010 -g git -s /bin/sh -d /home/git git
fi
su git -c "mkdir -p /home/git/.ssh/"

su git -c "if [ ! -f /home/git/.ssh/id_rsa ]; then ssh-keygen -t rsa -N \"\" -f /home/git/.ssh/id_rsa; fi"
su git -c "if [ -f /home/git/.ssh/id_rsa.pub ]; then mv /home/git/.ssh/id_rsa.pub /home/git/.ssh/authorized_keys_proxy; fi"

mkdir -p /home/git/gitlab-shell/bin/
rm -f /home/git/gitlab-shell/bin/gitlab-shell
tee -a /home/git/gitlab-shell/bin/gitlab-shell > /dev/null <<'EOF'
#!/bin/sh

ssh -i /home/git/.ssh/id_rsa -p 9922 -o StrictHostKeyChecking=no git@127.0.0.1 "SSH_ORIGINAL_COMMAND=\"$SSH_ORIGINAL_COMMAND\" $0 $@"
EOF
chown git:git /home/git/gitlab-shell/bin/gitlab-shell
chmod u+x /home/git/gitlab-shell/bin/gitlab-shell

mkdir -p /var/lib/gitlab/data/.ssh/
chown git:git -R /var/lib/gitlab/data/.ssh/
chown git:git -R /home/git/.ssh
su git -c "touch /var/lib/gitlab/data/.ssh/authorized_keys"
rm -f /home/git/.ssh/authorized_keys
su git -c "ln -s /var/lib/gitlab/data/.ssh/authorized_keys /home/git/.ssh/authorized_keys"
