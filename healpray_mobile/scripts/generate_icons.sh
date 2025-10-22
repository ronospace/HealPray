#!/usr/bin/env bash

# HealPray Icon Generation Script
# This script converts the SVG logo to all required app icon sizes

set -e

echo "🎨 HealPray Icon Generation Script"
echo "=================================="

# Check if ImageMagick is installed
if ! command -v magick &> /dev/null; then
    if ! command -v convert &> /dev/null; then
        echo "❌ ImageMagick not found!"
        echo "📦 Installing ImageMagick via Homebrew..."
        brew install imagemagick
    fi
fi

# Use magick command if available (ImageMagick 7+), otherwise fall back to convert
if command -v magick &> /dev/null; then
    CONVERT_CMD="magick"
else
    CONVERT_CMD="convert"
fi

# Paths
SVG_FILE="assets/logo/healpray_logo.svg"
IOS_PATH="ios/Runner/Assets.xcassets/AppIcon.appiconset"
ANDROID_PATH="android/app/src/main/res"

# Create directories
mkdir -p "$IOS_PATH"
mkdir -p "$ANDROID_PATH"

echo ""
echo "📱 Generating iOS Icons..."
echo "-------------------------"

# Generate iOS icons
$CONVERT_CMD "$SVG_FILE" -resize 1024x1024 "$IOS_PATH/Icon-1024.png"
echo "✅ Icon-1024.png (1024x1024) - App Store"

$CONVERT_CMD "$SVG_FILE" -resize 180x180 "$IOS_PATH/Icon-App-60x60@3x.png"
echo "✅ Icon-App-60x60@3x.png (180x180)"

$CONVERT_CMD "$SVG_FILE" -resize 120x120 "$IOS_PATH/Icon-App-60x60@2x.png"
echo "✅ Icon-App-60x60@2x.png (120x120)"

$CONVERT_CMD "$SVG_FILE" -resize 87x87 "$IOS_PATH/Icon-App-29x29@3x.png"
echo "✅ Icon-App-29x29@3x.png (87x87)"

$CONVERT_CMD "$SVG_FILE" -resize 80x80 "$IOS_PATH/Icon-App-40x40@2x.png"
echo "✅ Icon-App-40x40@2x.png (80x80)"

$CONVERT_CMD "$SVG_FILE" -resize 58x58 "$IOS_PATH/Icon-App-29x29@2x.png"
echo "✅ Icon-App-29x29@2x.png (58x58)"

$CONVERT_CMD "$SVG_FILE" -resize 40x40 "$IOS_PATH/Icon-App-20x20@2x.png"
echo "✅ Icon-App-20x20@2x.png (40x40)"

$CONVERT_CMD "$SVG_FILE" -resize 29x29 "$IOS_PATH/Icon-App-29x29@1x.png"
echo "✅ Icon-App-29x29@1x.png (29x29)"

# iPad icons
$CONVERT_CMD "$SVG_FILE" -resize 152x152 "$IOS_PATH/Icon-App-76x76@2x.png"
echo "✅ Icon-App-76x76@2x.png (152x152) - iPad"

$CONVERT_CMD "$SVG_FILE" -resize 76x76 "$IOS_PATH/Icon-App-76x76@1x.png"
echo "✅ Icon-App-76x76@1x.png (76x76) - iPad"

$CONVERT_CMD "$SVG_FILE" -resize 167x167 "$IOS_PATH/Icon-App-83.5x83.5@2x.png"
echo "✅ Icon-App-83.5x83.5@2x.png (167x167) - iPad Pro"

echo ""
echo "🤖 Generating Android Icons..."
echo "----------------------------"

# Generate Android icons (all sizes)
mkdir -p "$ANDROID_PATH/mipmap-mdpi"
$CONVERT_CMD "$SVG_FILE" -resize 48x48 "$ANDROID_PATH/mipmap-mdpi/ic_launcher.png"
echo "✅ mipmap-mdpi/ic_launcher.png (48x48)"

mkdir -p "$ANDROID_PATH/mipmap-hdpi"
$CONVERT_CMD "$SVG_FILE" -resize 72x72 "$ANDROID_PATH/mipmap-hdpi/ic_launcher.png"
echo "✅ mipmap-hdpi/ic_launcher.png (72x72)"

mkdir -p "$ANDROID_PATH/mipmap-xhdpi"
$CONVERT_CMD "$SVG_FILE" -resize 96x96 "$ANDROID_PATH/mipmap-xhdpi/ic_launcher.png"
echo "✅ mipmap-xhdpi/ic_launcher.png (96x96)"

mkdir -p "$ANDROID_PATH/mipmap-xxhdpi"
$CONVERT_CMD "$SVG_FILE" -resize 144x144 "$ANDROID_PATH/mipmap-xxhdpi/ic_launcher.png"
echo "✅ mipmap-xxhdpi/ic_launcher.png (144x144)"

mkdir -p "$ANDROID_PATH/mipmap-xxxhdpi"
$CONVERT_CMD "$SVG_FILE" -resize 192x192 "$ANDROID_PATH/mipmap-xxxhdpi/ic_launcher.png"
echo "✅ mipmap-xxxhdpi/ic_launcher.png (192x192)"

# Generate Play Store icon (512x512)
$CONVERT_CMD "$SVG_FILE" -resize 512x512 "assets/logo/playstore_icon.png"
echo "✅ playstore_icon.png (512x512) - Play Store"

echo ""
echo "🎉 Icon generation complete!"
echo ""
echo "📋 Generated Files:"
echo "  iOS: $IOS_PATH/*.png"
echo "  Android: $ANDROID_PATH/mipmap-*/ic_launcher.png"
echo "  Play Store: assets/logo/playstore_icon.png"
echo ""
echo "✅ All icons generated successfully!"
echo ""
echo "🔄 Next steps:"
echo "  1. Update ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json"
echo "  2. Test app icon on simulators/devices"
echo "  3. Verify icon looks good at all sizes"
