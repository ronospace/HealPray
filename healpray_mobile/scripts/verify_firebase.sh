#!/bin/bash

# Firebase Configuration Verification Script
# Developed and Maintained by ZyraFlow Inc.™
# © 2025 ZyraFlow Inc. All rights reserved.

set -e

echo "🔥 Firebase Configuration Verification"
echo "========================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Android configuration
echo "📱 Checking Android Configuration..."
if [ -f "android/app/google-services.json" ]; then
    echo -e "${GREEN}✓${NC} google-services.json found"
    
    # Verify it contains the correct package name
    if grep -q "com.healpray.healpray" android/app/google-services.json; then
        echo -e "${GREEN}✓${NC} Package name verified: com.healpray.healpray"
    else
        echo -e "${RED}✗${NC} Package name mismatch in google-services.json"
        exit 1
    fi
    
    # Verify project ID
    if grep -q "flowsense-cycle-app" android/app/google-services.json; then
        echo -e "${GREEN}✓${NC} Firebase project verified: flowsense-cycle-app"
    else
        echo -e "${YELLOW}⚠${NC} Warning: Firebase project ID not found or different"
    fi
else
    echo -e "${RED}✗${NC} google-services.json NOT found!"
    echo ""
    echo "Please download from:"
    echo "https://console.firebase.google.com/project/flowsense-cycle-app/settings/general"
    echo "And place it in: android/app/google-services.json"
    exit 1
fi

echo ""

# Check iOS configuration
echo "🍎 Checking iOS Configuration..."
if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo -e "${GREEN}✓${NC} GoogleService-Info.plist found"
    
    # Verify it contains the correct bundle ID
    if grep -q "com.healpray.healpray" ios/Runner/GoogleService-Info.plist; then
        echo -e "${GREEN}✓${NC} Bundle ID verified: com.healpray.healpray"
    else
        echo -e "${RED}✗${NC} Bundle ID mismatch in GoogleService-Info.plist"
        exit 1
    fi
    
    # Verify project ID
    if grep -q "flowsense-cycle-app" ios/Runner/GoogleService-Info.plist; then
        echo -e "${GREEN}✓${NC} Firebase project verified: flowsense-cycle-app"
    else
        echo -e "${YELLOW}⚠${NC} Warning: Firebase project ID not found or different"
    fi
else
    echo -e "${RED}✗${NC} GoogleService-Info.plist NOT found!"
    echo ""
    echo "Please download from:"
    echo "https://console.firebase.google.com/project/flowsense-cycle-app/settings/general"
    echo "And place it in: ios/Runner/GoogleService-Info.plist"
    exit 1
fi

echo ""

# Check environment variables
echo "🔐 Checking Environment Variables..."
if [ -f ".env" ]; then
    echo -e "${GREEN}✓${NC} .env file found"
    
    if grep -q "GEMINI_API_KEY" .env; then
        echo -e "${GREEN}✓${NC} GEMINI_API_KEY configured"
    else
        echo -e "${YELLOW}⚠${NC} Warning: GEMINI_API_KEY not found in .env"
    fi
else
    echo -e "${YELLOW}⚠${NC} .env file not found (optional for Firebase)"
fi

echo ""
echo "========================================"
echo -e "${GREEN}✓${NC} Firebase configuration verified!"
echo ""
echo "Next steps:"
echo "1. Run: flutter clean"
echo "2. Run: flutter pub get"
echo "3. Run: cd ios && pod install && cd .."
echo "4. Run: flutter run"
echo ""
echo "Developed and Maintained by ZyraFlow Inc.™"
