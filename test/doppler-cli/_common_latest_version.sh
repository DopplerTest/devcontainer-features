#!/usr/bin/env bash
# Shared test logic for verifying latest version is installed

set -e

source dev-container-features-test-lib

# Install jq if needed for JSON parsing
if ! type jq >/dev/null 2>&1; then
    if type apt-get >/dev/null 2>&1; then
        apt-get update -y && apt-get -y install --no-install-recommends jq
    elif type apk >/dev/null 2>&1; then
        apk add --no-cache jq
    elif type dnf >/dev/null 2>&1; then
        dnf install -y jq
    elif type yum >/dev/null 2>&1; then
        yum install -y jq
    fi
fi

# Get latest version from GitHub API
latest_version=$(curl -s https://api.github.com/repos/dopplerhq/cli/releases/latest | jq -r '.tag_name')

# Verify installed version matches latest
check "latest version installed" bash -c "doppler -v | grep '${latest_version}'"

reportResults
