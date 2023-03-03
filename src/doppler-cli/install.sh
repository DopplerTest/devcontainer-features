#!/usr/bin/env bash

set -e

ensure_curl() {
  if ! type curl >/dev/null 2>&1; then
    apt-get update -y && apt-get -y install --no-install-recommends curl
  fi
}

ensure_gpg() {
  if ! type gpg >/dev/null 2>&1; then
    apt-get update -y && apt-get -y install --no-install-recommends gnupg2
  fi
}

ensure_curl
ensure_gpg

# download and execute the latest installer.
curl -Ls --tlsv1.2 --proto "=https" --retry 3 https://cli.doppler.com/install.sh | sh

# ensure /doppler is writable to store CLI config data
mkdir -p /doppler && chown -R ${_REMOTE_USER}:${_REMOTE_USER} /doppler
