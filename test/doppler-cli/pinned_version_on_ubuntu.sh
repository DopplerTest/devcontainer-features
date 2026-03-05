#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

# Verify the specific pinned version is installed
check "pinned version 3.69.0 installed" bash -c "doppler -v | grep 'v3.69.0'"

reportResults
