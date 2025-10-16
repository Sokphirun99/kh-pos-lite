#!/bin/bash

echo "🏗️ Building KH POS Lite - Offline Production Version"
echo "================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Navigate to apps directory
cd "$(dirname "$0")"

echo -e "${BLUE}📁 Working directory: $(pwd)${NC}"

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
flutter clean
flutter pub get

# Check if build was successful
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to get dependencies${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Dependencies updated${NC}"

# Create releases directory
mkdir -p releases

echo -e "${BLUE}📱 Building Android APK (Release)...${NC}"
echo "Target: lib/main_offline.dart"
echo "Build mode: OFFLINE PRODUCTION"

# Build for Android (Release) with offline target
flutter build apk \
  --release \
  --target=lib/main_offline.dart \
  --dart-define=BUILD_MODE=offline \
  --dart-define=OFFLINE_MODE=true \
  --build-name=1.0.0 \
  --build-number=1

# Check if build was successful
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Android build failed${NC}"
    exit 1
fi

# Copy APK to releases folder with descriptive name
APK_SOURCE="build/app/outputs/flutter-apk/app-release.apk"
APK_DEST="releases/khpos-offline-v1.0.0-$(date +%Y%m%d).apk"

if [ -f "$APK_SOURCE" ]; then
    cp "$APK_SOURCE" "$APK_DEST"
    
    # Get APK size
    APK_SIZE=$(du -h "$APK_SOURCE" | cut -f1)
    
    echo -e "${GREEN}✅ Build completed successfully!${NC}"
    echo "================================================="
    echo -e "${BLUE}📦 APK Details:${NC}"
    echo "   📍 Location: $APK_DEST"
    echo "   📏 Size: $APK_SIZE"
    echo "   📱 App Name: KH POS Lite (Offline)"
    echo "   🔒 Mode: Offline Only"
    echo "   💾 Database: Local Isar Database"
    echo "   🎨 Theme: Light Blue"
    echo "   📊 Sample Products: 10 items included"
    echo ""
    echo -e "${YELLOW}🚀 Installation Instructions:${NC}"
    echo "   1. Enable 'Unknown Sources' on your Android device"
    echo "   2. Transfer the APK to your device"
    echo "   3. Install and enjoy your offline POS system!"
    echo ""
    echo -e "${GREEN}🎉 Ready for production use!${NC}"
else
    echo -e "${RED}❌ APK file not found at expected location${NC}"
    exit 1
fi

# Optional: Build for other platforms
read -p "$(printf '%b' "${YELLOW}🍎 Do you want to build for iOS as well? (y/N): ${NC}")" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}🍎 Building iOS app...${NC}"
    flutter build ios \
      --release \
      --target=lib/main_offline.dart \
      --dart-define=BUILD_MODE=offline \
      --dart-define=OFFLINE_MODE=true
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ iOS build completed! Check Xcode for the .ipa file.${NC}"
    else
        echo -e "${RED}❌ iOS build failed${NC}"
    fi
fi

echo -e "${GREEN}🏁 Build process completed!${NC}"