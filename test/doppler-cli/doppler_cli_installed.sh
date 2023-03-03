#!/usr/bin/env bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

check "execute command" bash -c "doppler -h | grep 'The official Doppler CLI'"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
