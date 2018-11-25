#!/usr/bin/env bash
set -ev

chmod go+rX /var/lib/gitlab/data/.ssh/
chmod go+r /var/lib/gitlab/data/.ssh/authorized_keys

# Switch sshd_config to "StrictModes no" to fix this error "Authentication refused: bad ownership or modes for file /var/lib/gitlab/data/.ssh/authorized_keys"

if ! grep -q -F "StrictModes no" /etc/ssh/sshd_config; then
  echo "StrictModes no" >> /etc/ssh/sshd_config
  systemctl restart sshd
fi
