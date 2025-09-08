# Routinier App Deployment Guide

This document outlines the complete process for building, archiving, and uploading the Routinier app to TestFlight and eventually the App Store.

## Prerequisites

- ✅ Xcode installed and configured
- ✅ Valid code signing certificates
- ✅ Apple [Developer account](https://developer.apple.com/account) with Apple Developer Program membership 
- ✅ CloudKit container configured on [Developer portal](https://icloud.developer.apple.com/)

## App Configuration

### Current Settings
- **Bundle Identifier:** `com.aralph.Routinier`
- **Version:** `1.0`
- **Build Number:** `1`
- **CloudKit Container:** `iCloud.com.aralph.Routinier`

### Required Files
- ✅ App icons (all sizes including 1024x1024 App Store icon)
- ✅ `Info.plist` with `CKSharingSupported` = `true`
- ✅ `Routinier.entitlements` with CloudKit capabilities
- ✅ CloudKit container properly configured

## TestFlight Deployment Process

### Step 1: Verify App Configuration

```bash
# Check bundle identifier
grep -r "PRODUCT_BUNDLE_IDENTIFIER" Routinier.xcodeproj/project.pbxproj | head -1

# Check version numbers
grep -E "(MARKETING_VERSION|CURRENT_PROJECT_VERSION)" Routinier.xcodeproj/project.pbxproj | head -2

# Verify app builds successfully (replace DEVICE_ID with your device ID)
xcodebuild -project Routinier.xcodeproj -scheme Routinier -configuration Debug -sdk iphoneos -destination 'platform=iOS,id=DEVICE_ID' -allowProvisioningUpdates -allowProvisioningDeviceRegistration build
```
As an alternative to adding `DEVICE_ID`, you can specify the device by name, e.g. `'platform=iOS,name=Ralph Aeschimann’s iPhone'`.

### Step 2: Create Archive

```bash
# Create release archive for distribution
xcodebuild -project Routinier.xcodeproj -scheme Routinier -configuration Release archive -archivePath "Routinier.xcarchive" -allowProvisioningUpdates -allowProvisioningDeviceRegistration
```

### Step 3: Export and Upload to TestFlight

```bash
# Export archive and upload to App Store Connect/TestFlight
xcodebuild -exportArchive -archivePath "Routinier.xcarchive" -exportPath "RoutinierExport" -exportOptionsPlist export_options.plist -allowProvisioningUpdates
```
The project includes `export_options.plist` with the required configuration for App Store distribution. 
Xcode automatically determines the team ID from the archive's signing information, so no manual configuration is needed.

The command should print that the export succeeded and that Routinier was uploaded.

## App Store Connect Configuration

### First-Time Setup

1. **Go to [App Store Connect](https://appstoreconnect.apple.com)**
2. **Create New App:**
   - Platform: iOS
   - Name: `Routinier App`
   - Primary Language: English
   - Bundle ID: `com.aralph.Routinier`
   - SKU: `routinier`
   - User Access: Full Access

### TestFlight Setup

1. **Navigate to App Store Connect → My Apps → Routinier**
2. **Click "TestFlight" tab**
3. **Wait for build processing** (5-10 minutes after upload)
4. **Add Internal Testers:**
   - Click "Internal Testing"
   - Add test devices
   - Click "Start Testing"

## Testing Process

### Install via TestFlight

1. **Download TestFlight app** on test devices
2. **Sign in with Apple ID**
3. **Install Routinier** from TestFlight builds

### CloudKit Sharing Test

1. **Device 1:** 
   - Create a routine
   - Open routine detail view
   - Tap menu (⋯) → "Share Routine"
   - Share via Messages/Email

2. **Device 2:**
   - Receive and tap CloudKit share link
   - App opens automatically
   - Accept share invitation
   - Verify routine appears in shared state

3. **Collaboration Test:**
   - Mark routines complete on both devices
   - Verify real-time sync between devices

## Version Updates

### Increment Build Number

```bash
# For subsequent uploads, increment build number in Xcode project settings
# Or update via command line (example for build 2):
sed -i '' 's/CURRENT_PROJECT_VERSION = 1;/CURRENT_PROJECT_VERSION = 2;/g' Routinier.xcodeproj/project.pbxproj
```

### Repeat Upload Process

```bash
# Clean previous archives (optional)
rm -rf Routinier.xcarchive RoutinierExport

# Create new archive
xcodebuild -project Routinier.xcodeproj -scheme Routinier -configuration Release archive -archivePath "Routinier.xcarchive" -allowProvisioningUpdates -allowProvisioningDeviceRegistration

# Upload to TestFlight
xcodebuild -exportArchive -archivePath "Routinier.xcarchive" -exportPath "RoutinierExport" -exportOptionsPlist export_options.plist -allowProvisioningUpdates
```

## App Store Submission (Future)

### Required Assets for App Store

1. **Privacy Policy URL** (required for CloudKit apps)
2. **App Screenshots** (iPhone 6.7", iPhone 6.5", iPhone 5.5")
3. **App Description** and keywords
4. **App category selection**
5. **Age rating questionnaire**

### App Store Review Process

1. **Complete TestFlight testing**
2. **Create App Store listing** in App Store Connect
3. **Upload required screenshots and metadata**
4. **Submit for review** (1-3 day review time)
5. **Release after approval**

## Troubleshooting

### Common Issues

**Build Fails:**
```bash
# Clean build folder
rm -rf ~/Library/Developer/Xcode/DerivedData/Routinier-*

# Try building again
xcodebuild clean -project Routinier.xcodeproj -scheme Routinier
```

**Upload Fails:**
- Verify Apple Developer Program status
- Check code signing certificates
- Ensure bundle ID matches App Store Connect

**CloudKit Issues:**
- Verify CloudKit container exists in Apple Developer portal
- Check CloudKit Dashboard for proper schema
- Ensure entitlements include CloudKit capability

### Useful Commands

```bash
# Check current archives
ls -la ~/Library/Developer/Xcode/Archives/

# View project settings
xcodebuild -project Routinier.xcodeproj -showBuildSettings

# List available devices
xcrun xctrace list devices

# View provisioning profiles
security find-identity -v -p codesigning
```

## Quick Reference Commands

```bash
# Full deployment pipeline
xcodebuild -project Routinier.xcodeproj -scheme Routinier -configuration Release archive -archivePath "Routinier.xcarchive" -allowProvisioningUpdates -allowProvisioningDeviceRegistration && xcodebuild -exportArchive -archivePath "Routinier.xcarchive" -exportPath "RoutinierExport" -exportOptionsPlist export_options.plist -allowProvisioningUpdates
```

This deploys Routinier with full CloudKit sharing capabilities to TestFlight for testing and eventual App Store distribution.