#!/bin/bash
set -euo pipefail

if [ "${CONFIGURATION}" != "Release" ]; then
	echo "[SKIP] Not building an Release configuration, skipping DMG creation"
	exit
fi

RSYNCOSX_DMG_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${PROJECT_DIR}/RsyncOSX/Info.plist")
RSYNCOSX_DMG="${BUILT_PRODUCTS_DIR}/RsyncOSX-${RSYNCOSX_DMG_VERSION}.dmg"
RSYNCOSX_APP="${BUILT_PRODUCTS_DIR}/RsyncOSX.app"
RSYNCOSX_APP_RESOURCES="${RSYNCOSX_APP}/Contents/Resources"

CREATE_DMG="${SOURCE_ROOT}/3thparty/github.com/andreyvit/create-dmg/create-dmg"
STAGING_DIR="${BUILT_PRODUCTS_DIR}/staging/dmg"
STAGING_APP="${STAGING_DIR}/RsyncOSX.app"
DMG_TEMPLATE_DIR="${SOURCE_ROOT}/Scripts/Templates/DMG"
DEFAULT_IDENTITY=$(security find-identity -v -p codesigning | grep "Developer ID" | head -1 | cut -f 4 -d " " || true)

if [ -f "${RSYNCOSX_DMG}" ]; then
	echo "-- RsyncOSX dmg already created"
	echo "   > ${RSYNCOSX_DMG}"
else
	echo "-- Creating RsyncOSX dmg"
        echo "   > ${RSYNCOSX_DMG}"
        rm -rf ${STAGING_DIR}
        mkdir -p ${STAGING_DIR}
        cp -a -p ${RSYNCOSX_APP} ${STAGING_DIR}

	${CREATE_DMG} \
		--volname "RsyncOSX" \
		--volicon "${RSYNCOSX_APP_RESOURCES}/AppIcon.icns" \
		--background "${DMG_TEMPLATE_DIR}/background.png" \
		--window-pos -1 -1 \
		--window-size 480 540 \
		--icon "RsyncOSX.app" 240 130 \
		--hide-extension RsyncOSX.app \
		--app-drop-link 240 380 \
		${RSYNCOSX_DMG} \
		${STAGING_DIR}
fi
