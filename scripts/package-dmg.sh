#!/bin/zsh
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$PROJECT_DIR/dist/LocalScribe.app"
VERSION="$(/usr/bin/plutil -extract CFBundleShortVersionString raw "$APP_DIR/Contents/Info.plist")"
DMG_PATH="$PROJECT_DIR/dist/LocalScribe-$VERSION-arm64.dmg"
DMG_WORK="$(mktemp -d "${TMPDIR:-/tmp}/localscribe-dmg.XXXXXX")"
DMG_STAGE="$DMG_WORK/contents"
MOUNT_POINT="$DMG_WORK/volume"
MOUNTED=0
cleanup() {
    if (( MOUNTED )); then
        /usr/bin/hdiutil detach "$MOUNT_POINT" -quiet || return
    fi
    rm -rf -- "$DMG_WORK"
}
trap cleanup EXIT
mkdir -p "$DMG_STAGE" "$MOUNT_POINT"
/usr/bin/codesign --verify --deep --strict "$APP_DIR"
/usr/bin/ditto "$APP_DIR" "$DMG_STAGE/LocalScribe.app"
/bin/ln -s /Applications "$DMG_STAGE/Applications"
/bin/cp "$PROJECT_DIR/Support/LEIA-ME.txt" "$DMG_STAGE/LEIA-ME.txt"
/bin/cp "$APP_DIR/Contents/Resources/LocalScribe.icns" "$DMG_STAGE/.VolumeIcon.icns"
# The mounted volume and the .dmg file have separate Finder icon metadata.
/usr/bin/hdiutil create -volname LocalScribe -srcfolder "$DMG_STAGE" -fs HFS+ -format UDRW "$DMG_WORK/writable.dmg"
/usr/bin/hdiutil attach -nobrowse -noautoopen -mountpoint "$MOUNT_POINT" "$DMG_WORK/writable.dmg"
MOUNTED=1
xcrun SetFile -a C "$MOUNT_POINT"
/usr/bin/hdiutil detach "$MOUNT_POINT"
MOUNTED=0
/usr/bin/hdiutil convert "$DMG_WORK/writable.dmg" -format UDZO -ov -o "$DMG_PATH"
ICON_TOOL="$PROJECT_DIR/.build/render-brand-icon"
if [[ ! -x "$ICON_TOOL" ]]; then
    mkdir -p "$PROJECT_DIR/.build/module-cache"
    xcrun swiftc -module-cache-path "$PROJECT_DIR/.build/module-cache" \
        "$PROJECT_DIR/Sources/LocalScribe/LocalScribeArtwork.swift" \
        "$PROJECT_DIR/scripts/RenderBrandIcon.swift" -o "$ICON_TOOL"
fi
"$ICON_TOOL" set-icon "$APP_DIR/Contents/Resources/LocalScribe.icns" "$DMG_PATH"
/usr/bin/hdiutil verify "$DMG_PATH"
/usr/bin/hdiutil attach -readonly -nobrowse -noautoopen -mountpoint "$MOUNT_POINT" "$DMG_PATH"
MOUNTED=1
/usr/bin/cmp "$APP_DIR/Contents/Resources/LocalScribe.icns" "$MOUNT_POINT/.VolumeIcon.icns"
/usr/bin/cmp "$APP_DIR/Contents/Resources/LocalScribe.icns" "$MOUNT_POINT/LocalScribe.app/Contents/Resources/LocalScribe.icns"
/usr/bin/cmp "$APP_DIR/Contents/Resources/LocalScribe.pdf" "$MOUNT_POINT/LocalScribe.app/Contents/Resources/LocalScribe.pdf"
[[ "$(xcrun GetFileInfo -aC "$MOUNT_POINT")" == "1" ]]
[[ "$(xcrun GetFileInfo -aC "$DMG_PATH")" == "1" ]]
/usr/bin/xattr -p com.apple.ResourceFork "$DMG_PATH" >/dev/null
/usr/bin/codesign --verify --deep --strict "$MOUNT_POINT/LocalScribe.app"
/usr/bin/hdiutil detach "$MOUNT_POINT"
MOUNTED=0
echo "installer-icons=verified file=green volume=green app=green settings=vector"
/usr/bin/ditto -c -k --sequesterRsrc "$DMG_PATH" "$DMG_PATH.zip"
echo "$DMG_PATH"
echo "$DMG_PATH.zip"
