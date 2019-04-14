#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/"

vagrant destroy -f
rm -rf certs
rm -rf dkim
