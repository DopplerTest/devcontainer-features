#!/bin/sh
set -e

echo "=== Doppler CLI Feature Install ==="
echo "VERSION: ${VERSION:-latest}"
echo "_REMOTE_USER: ${_REMOTE_USER:-not set}"

VERSION="${VERSION:-latest}"

# Detect package manager
detect_package_manager() {
    if type apt-get >/dev/null 2>&1; then
        echo "apt"
    elif type apk >/dev/null 2>&1; then
        echo "apk"
    elif type dnf >/dev/null 2>&1; then
        echo "dnf"
    elif type yum >/dev/null 2>&1; then
        echo "yum"
    else
        echo "unknown"
    fi
}

# Install a package using the detected package manager
install_package() {
    local pkg_manager="$1"
    shift
    local packages="$@"

    case "$pkg_manager" in
        apt)
            apt-get update -y && apt-get install -y --no-install-recommends $packages
            rm -rf /var/lib/apt/lists/*
            ;;
        apk)
            apk add --no-cache $packages
            ;;
        dnf)
            dnf install -y $packages && dnf clean all
            rm -rf /var/cache/dnf
            ;;
        yum)
            yum install -y $packages && yum clean all
            rm -rf /var/cache/yum
            ;;
        *)
            echo "ERROR: Unsupported package manager. Please install manually: $packages"
            exit 1
            ;;
    esac
}

PKG_MANAGER=$(detect_package_manager)
echo "Detected package manager: $PKG_MANAGER"

# Install dependencies if missing
echo "Checking for curl..."
if ! type curl >/dev/null 2>&1; then
    echo "Installing curl..."
    case "$PKG_MANAGER" in
        apt) install_package "$PKG_MANAGER" curl ca-certificates ;;
        apk) install_package "$PKG_MANAGER" curl ca-certificates ;;
        dnf|yum) install_package "$PKG_MANAGER" curl ;;
        *) echo "ERROR: Cannot install curl"; exit 1 ;;
    esac
fi

echo "Checking for gpgv..."
if ! type gpgv >/dev/null 2>&1; then
    echo "Installing gpgv..."
    case "$PKG_MANAGER" in
        apt) install_package "$PKG_MANAGER" gpgv ;;
        apk) install_package "$PKG_MANAGER" gpgv ;;
        dnf|yum) install_package "$PKG_MANAGER" gnupg2 ;;
        *) echo "ERROR: Cannot install gpgv"; exit 1 ;;
    esac
fi

# Ensure gpgv is in PATH (may not be after fresh install)
if ! type gpgv >/dev/null 2>&1; then
    echo "gpgv not in PATH, checking common locations..."
    for path in /usr/bin/gpgv /bin/gpgv /usr/local/bin/gpgv; do
        if [ -x "$path" ]; then
            echo "Found gpgv at $path, adding to PATH"
            export PATH="$(dirname "$path"):$PATH"
            break
        fi
    done
fi

# Final check
if ! type gpgv >/dev/null 2>&1; then
    echo "ERROR: gpgv not found after installing gnupg"
    exit 1
fi

# Strip 'v' prefix from version if present (e.g., "v3.69.0" -> "3.69.0")
VERSION="${VERSION#v}"

# Install bash if needed (Alpine doesn't have it, but Doppler's install script requires it)
if [ "$PKG_MANAGER" = "apk" ] && ! type bash >/dev/null 2>&1; then
    echo "Installing bash (required by Doppler install script)..."
    apk add --no-cache bash
fi

# Install Doppler CLI
echo "Installing Doppler CLI (version: $VERSION)..."
if [ "$VERSION" = "latest" ]; then
    # Use official install script for latest (includes signature verification)
    echo "Fetching Doppler install script..."
    curl -Ls --tlsv1.2 --proto "=https" --retry 3 https://cli.doppler.com/install.sh | bash
else
    # Download specific version directly from GitHub releases
    echo "Downloading Doppler CLI v$VERSION from GitHub releases..."

    # Detect OS
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    case "$OS" in
        darwin) OS="macos" ;;
        linux) OS="linux" ;;
        *) echo "ERROR: Unsupported OS: $OS"; exit 1 ;;
    esac

    # Detect architecture
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64|amd64) ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        armv7l) ARCH="armv7" ;;
        armv6l) ARCH="armv6" ;;
        i386|i686) ARCH="i386" ;;
        *) echo "ERROR: Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    TEMP_DIR=$(mktemp -d)
    TARBALL="doppler_${VERSION}_${OS}_${ARCH}.tar.gz"
    DOWNLOAD_URL="https://github.com/DopplerHQ/cli/releases/download/${VERSION}/${TARBALL}"
    SIG_URL="${DOWNLOAD_URL}.sig"

    # Download tarball
    echo "Downloading from: $DOWNLOAD_URL"
    curl -Ls --tlsv1.2 --proto "=https" --retry 3 -o "$TEMP_DIR/$TARBALL" "$DOWNLOAD_URL"

    # Download signature
    echo "Downloading signature from: $SIG_URL"
    curl -Ls --tlsv1.2 --proto "=https" --retry 3 -o "$TEMP_DIR/${TARBALL}.sig" "$SIG_URL"

    # Download public key
    echo "Downloading Doppler public key..."
    curl -Ls --tlsv1.2 --proto "=https" --retry 3 -o "$TEMP_DIR/doppler-public-key.gpg" "https://cli.doppler.com/keys/public"

    # Verify signature
    echo "Verifying signature..."
    if ! gpgv --keyring "$TEMP_DIR/doppler-public-key.gpg" "$TEMP_DIR/${TARBALL}.sig" "$TEMP_DIR/$TARBALL" 2>/dev/null; then
        echo "ERROR: Signature verification failed!"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    echo "Signature verification successful."

    # Extract and install
    tar -xzf "$TEMP_DIR/$TARBALL" -C "$TEMP_DIR"
    mv "$TEMP_DIR/doppler" /usr/local/bin/doppler
    chmod +x /usr/local/bin/doppler

    rm -rf "$TEMP_DIR"
fi

echo "=== Installation complete ==="
echo "Doppler CLI installed: $(doppler --version)"
