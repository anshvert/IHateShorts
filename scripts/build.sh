#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"

echo "==> Generating extension icons..."
mkdir -p extension/icons
swift scripts/generate_icons.swift extension/icons

echo "==> Creating app iconset..."
ICONSET_DIR="dist/AppIcon.iconset"
rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

sips -z 16 16     extension/icons/icon-512.png --out "$ICONSET_DIR/icon_16x16.png" > /dev/null
sips -z 32 32     extension/icons/icon-512.png --out "$ICONSET_DIR/icon_16x16@2x.png" > /dev/null
sips -z 32 32     extension/icons/icon-512.png --out "$ICONSET_DIR/icon_32x32.png" > /dev/null
sips -z 64 64     extension/icons/icon-512.png --out "$ICONSET_DIR/icon_32x32@2x.png" > /dev/null
sips -z 128 128   extension/icons/icon-512.png --out "$ICONSET_DIR/icon_128x128.png" > /dev/null
sips -z 256 256   extension/icons/icon-512.png --out "$ICONSET_DIR/icon_128x128@2x.png" > /dev/null
sips -z 256 256   extension/icons/icon-512.png --out "$ICONSET_DIR/icon_256x256.png" > /dev/null
sips -z 512 512   extension/icons/icon-512.png --out "$ICONSET_DIR/icon_256x256@2x.png" > /dev/null
sips -z 512 512   extension/icons/icon-512.png --out "$ICONSET_DIR/icon_512x512.png" > /dev/null

iconutil -c icns "$ICONSET_DIR" -o "dist/AppIcon.icns"
rm -rf "$ICONSET_DIR"

echo "==> Preparing bundle structure..."
APP_DIR="dist/IHateShorts.app"
APPEX_DIR="$APP_DIR/Contents/PlugIns/IHateShortsExtension.appex"

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"
mkdir -p "$APPEX_DIR/Contents/MacOS"
mkdir -p "$APPEX_DIR/Contents/Resources"

cp macos/Info-App.plist "$APP_DIR/Contents/Info.plist"
cp dist/AppIcon.icns "$APP_DIR/Contents/Resources/AppIcon.icns"

cp macos/Info-Extension.plist "$APPEX_DIR/Contents/Info.plist"
cp -r extension/* "$APPEX_DIR/Contents/Resources/"

SDK_PATH="$(xcrun --show-sdk-path)"

echo "==> Compiling extension binary..."
swiftc -sdk "$SDK_PATH" -target arm64-apple-macos14.0 -c macos/Handler.swift -o dist/Handler.o -parse-as-library
clang -isysroot "$SDK_PATH" -target arm64-apple-macos14.0 -framework Foundation -framework SafariServices macos/main.m dist/Handler.o -o "$APPEX_DIR/Contents/MacOS/IHateShortsExtension"
rm -f dist/Handler.o

echo "==> Compiling host application..."
swiftc -sdk "$SDK_PATH" -target arm64-apple-macos14.0 macos/AppMain.swift -framework AppKit -framework SafariServices -o "$APP_DIR/Contents/MacOS/IHateShorts"

echo "==> Ad-hoc signing bundles with entitlements..."
codesign --force --sign - --entitlements macos/Extension.entitlements "$APPEX_DIR"
codesign --force --sign - --entitlements macos/App.entitlements "$APP_DIR"

echo "==> Installing to ~/Applications..."
mkdir -p "$HOME/Applications"
rm -rf "$HOME/Applications/IHateShorts.app"
cp -R "$APP_DIR" "$HOME/Applications/"

echo "==> Registering with LaunchServices & PluginKit..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$HOME/Applications/IHateShorts.app"
pluginkit -a "$HOME/Applications/IHateShorts.app/Contents/PlugIns/IHateShortsExtension.appex"

echo "==> Build and installation complete: $HOME/Applications/IHateShorts.app"
