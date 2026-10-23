#!/bin/zsh
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ASSET_DIR="$PROJECT_DIR/Support/Assets"
ICONSET_DIR="$PROJECT_DIR/.build/LocalScribe.iconset"
mkdir -p "$PROJECT_DIR/.build/module-cache"
xcrun swiftc -module-cache-path "$PROJECT_DIR/.build/module-cache" \
    "$PROJECT_DIR/Sources/LocalScribe/LocalScribeArtwork.swift" \
    "$PROJECT_DIR/scripts/RenderBrandIcon.swift" -o "$PROJECT_DIR/.build/render-brand-icon"
"$PROJECT_DIR/.build/render-brand-icon" "$PROJECT_DIR/.build"
cp "$PROJECT_DIR/.build/LocalScribe.png" "$ASSET_DIR/LocalScribe.png"
cp "$PROJECT_DIR/.build/LocalScribe.pdf" "$ASSET_DIR/LocalScribe.pdf"
/usr/bin/iconutil -c icns "$ICONSET_DIR" -o "$ASSET_DIR/LocalScribe.icns"
test -s "$ASSET_DIR/LocalScribe.icns"
