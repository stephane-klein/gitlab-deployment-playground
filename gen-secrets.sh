#!/usr/bin/env bash

cat <<EOF > gitlab.env
GITLAB_SECRETS_DB_KEY_BASE=$(pwgen -Bsv1 64)
GITLAB_SECRETS_SECRET_KEY_BASE=$(pwgen -Bsv1 64)
GITLAB_SECRETS_OTP_KEY_BASE=$(pwgen -Bsv1 64)
EOF
