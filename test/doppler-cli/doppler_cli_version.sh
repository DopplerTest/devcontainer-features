#!/usr/bin/env bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

ensure_jq() {
  if ! type jq >/dev/null 2>&1; then
    apt-get update -y && apt-get -y install --no-install-recommends jq
  fi
}

get_latest_cli_version() {
  curl -s https://api.github.com/repos/dopplerhq/cli/releases/latest | jq -r '.tag_name'
}

ensure_jq
latest_cli_version=$(get_latest_cli_version)

check "execute command" bash -c "doppler -v | grep '${latest_cli_version}'"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults