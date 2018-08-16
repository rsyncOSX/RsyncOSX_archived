#!/bin/bash
set -euo pipefail

# Download and unpack rsyncosx into ${PRODUCT_NAME}.app/Contents/Resources
RSYNCOSX_ARCH="amd64"
RSYNCOSX_VERSION="5.4.0"
RSYNCOSX_DIST_URL="https://github.com/rsyncOSX/RsyncOSX/releases/download"
RSYNCOSX_TARBALL_URL="${RSYNCOSX_DIST_URL}/v${RSYNCOSX_VERSION}/rsyncosx-macos-${RSYNCOSX_ARCH}-v${RSYNCOSX_VERSION}.tar.gz"

CURL_ARGS="--connect-timeout 5 --max-time 10 --retry 5 --retry-delay 3 --retry-max-time 60"
DL_DIR="${BUILT_PRODUCTS_DIR}/dl"
RSYNCOSX_TARBALL="${DL_DIR}/rsyncosx-${RSYNCOSX_VERSION}.tar.gz"
APP_RESOURCES_DIR="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/Contents/Resources"
TAR_DIR="${APP_RESOURCES_DIR}/rsyncosx"

# Download rsyncosx tarball
if [ -f "${RSYNCOSX_TARBALL}" ]; then
    echo "-- rsyncosx already downloaded"
    echo "   > ${RSYNCOSX_TARBALL}"
else
    echo "-- Downloading rsyncosx"
    echo "   From > ${RSYNCOSX_TARBALL_URL}"
    echo "     To > ${RSYNCOSX_TARBALL}"

    mkdir -p "${DL_DIR}"
    curl ${CURL_ARGS} -s -L -o ${RSYNCOSX_TARBALL} ${RSYNCOSX_TARBALL_URL}
fi

# Unpack to .app Resources folder
if [ -d "${TAR_DIR}/rsyncosx" ]; then
    echo "-- rsyncosx already unpacked"
    echo "   > ${TAR_DIR}"
else
    echo "-- Unpacking rsyncosx"
    echo "   > ${TAR_DIR}"
    mkdir -p "${TAR_DIR}"
    tar -xf "${RSYNCOSX_TARBALL}" -C "${TAR_DIR}" --strip-components=1
fi
