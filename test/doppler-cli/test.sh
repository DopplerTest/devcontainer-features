#!/usr/bin/env bash

# This test can be run with the following command (from the root of this repo)
#    devcontainer features test \
#               --features doppler-cli \
#               --base-image mcr.microsoft.com/devcontainers/base:ubuntu .

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Check CLI is installed and executable
check "doppler is installed" command -v doppler

# Check version outputs valid semver format
check "version format" bash -c "doppler -v | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+'"

# Check CLI responds to help
check "help output" bash -c "doppler -h | grep 'The official Doppler CLI'"

# Report results
reportResults