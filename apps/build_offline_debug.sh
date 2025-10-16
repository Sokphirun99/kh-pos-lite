#!/bin/bash

echo "🏗️ Building KH POS Lite - Offline Production Version (Debug Build)"
echo "================================================================="

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

echo -e "${BLUE}📱 Building Android APK (Debug)...${NC}"
echo "Target: lib/main_offline.dart"
echo "Build mode: OFFLINE PRODUCTION (Debug)"

# Build for Android (Debug) with offline target
flutter build apk \
  --debug \
  --target=lib/main_offline.dart \
  --dart-define=BUILD_MODE=offline \
  --dart-define=OFFLINE_MODE=true \
  --build-name=1.0.0 \
  --build-number=1

# Check if build was successful
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Android debug build failed${NC}"
    exit 1
fi

# Copy APK to releases folder with descriptive name
APK_SOURCE="build/app/outputs/flutter-apk/app-debug.apk"
APK_DEST="releases/khpos-offline-debug-v1.0.0-$(date +%Y%m%d).apk"

if [ -f "$APK_SOURCE" ]; then
    cp "$APK_SOURCE" "$APK_DEST"
    
    # Get APK size
    APK_SIZE=$(du -h "$APK_SOURCE" | cut -f1)
    
    echo -e "${GREEN}✅ Debug build completed successfully!${NC}"
    echo "================================================="
    echo -e "${BLUE}📦 APK Details:${NC}"
    echo "   📍 Location: $APK_DEST"
    echo "   📏 Size: $APK_SIZE"
    echo "   📱 App Name: KH POS Lite (Offline Debug)"
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
    
    # Now try release build
    echo -e "${BLUE}📱 Attempting Release Build...${NC}"
    flutter build apk \
      --release \
      --target=lib/main_offline.dart \
      --dart-define=BUILD_MODE=offline \
      --dart-define=OFFLINE_MODE=true \
      --build-name=1.0.0 \
      --build-number=1
    
    if [ $? -eq 0 ]; then
        APK_RELEASE_SOURCE="build/app/outputs/flutter-apk/app-release.apk"
        APK_RELEASE_DEST="releases/khpos-offline-release-v1.0.0-$(date +%Y%m%d).apk"
        
        if [ -f "$APK_RELEASE_SOURCE" ]; then
            cp "$APK_RELEASE_SOURCE" "$APK_RELEASE_DEST"
            RELEASE_SIZE=$(du -h "$APK_RELEASE_SOURCE" | cut -f1)
            echo -e "${GREEN}✅ Release build also completed! ($RELEASE_SIZE)${NC}"
            echo "   📍 Release APK: $APK_RELEASE_DEST"
        fi
    else
        echo -e "${YELLOW}⚠️ Release build failed, but debug build is available${NC}"
    fi
    
    echo -e "${GREEN}🎉 Ready for testing!${NC}"
else
    echo -e "${RED}❌ APK file not found at expected location${NC}"
    exit 1
fi

echo -e "${GREEN}🏁 Build process completed!${NC}"