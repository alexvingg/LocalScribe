#!/bin/zsh
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export CLANG_MODULE_CACHE_PATH="$PROJECT_DIR/.build/module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$PROJECT_DIR/.build/module-cache"
mkdir -p "$CLANG_MODULE_CACHE_PATH"
xcrun swift build --package-path "$PROJECT_DIR" --scratch-path "$PROJECT_DIR/.build" --cache-path "$PROJECT_DIR/.build/cache" --disable-sandbox --build-system native -debug-info-format none -c release
APP_DIR="$PROJECT_DIR/dist/LocalScribe.app"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
"$PROJECT_DIR/scripts/build-icon.sh"
cp "$PROJECT_DIR/Support/Assets/LocalScribe.png" "$APP_DIR/Contents/Resources/LocalScribe.png"
cp "$PROJECT_DIR/Support/Assets/LocalScribe.icns" "$APP_DIR/Contents/Resources/LocalScribe.icns"
cp "$PROJECT_DIR/Support/Assets/LocalScribe.pdf" "$APP_DIR/Contents/Resources/LocalScribe.pdf"
cp "$PROJECT_DIR/.build/release/LocalScribe" "$APP_DIR/Contents/MacOS/LocalScribe"
cp "$PROJECT_DIR/Support/Info.plist" "$APP_DIR/Contents/Info.plist"
/usr/bin/codesign --force --sign - --identifier dev.localscribe.mac "$APP_DIR"
echo "$APP_DIR"
