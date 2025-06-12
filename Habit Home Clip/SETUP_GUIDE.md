# Habit Home App Clip Setup Guide

## Overview
This guide will help you set up the Habit Home App Clip in Xcode for TestFlight distribution.

## Prerequisites
- ✅ Room.json file added to `AppClip/Resources/`
- ✅ All App Clip Swift files created
- 🔄 Xcode project configuration needed

## Xcode Project Setup

### 1. Create App Clip Target

1. **Add App Clip Target:**
   - In Xcode, go to File → New → Target
   - Select "App Clip" under iOS
   - Target Name: `HabitHomeClip`
   - Bundle Identifier: `com.yourteam.habithome.Clip`
   - Click "Finish"

2. **Configure App Clip Target:**
   - Minimum iOS Deployment Target: iOS 16.0+
   - App Clip target should be embedded in main app

### 2. Add Source Files to App Clip Target

**Add these files to the App Clip target:**

```
AppClip/
├── HabitAppClip.swift                    ✅ Main entry point
├── Views/
│   ├── AppClipOnboardingView.swift       ✅ Simplified onboarding
│   ├── AppClipHabitSelectionView.swift   ✅ Habit selection
│   ├── AppClipHabitRecommendationView.swift ✅ Main recommendation view
│   ├── AppClipHabitRecommendationView+Extensions.swift ✅ Helper methods
│   ├── AppClipFurnitureEditView.swift    ✅ Furniture editing
│   └── AppClipRoomPreviewView.swift      ✅ 3D room preview
├── Models/
│   ├── AppClipDataModels.swift           ✅ Session-only data models
│   └── AppClipHabitModel.swift           ✅ Habit models
├── Managers/
│   ├── RecommendationEngine.swift        ✅ Copied from main app
│   └── RecommendationVisualizer.swift   ✅ Copied from main app
├── Resources/
│   └── Room.json                         ✅ Your uploaded room data
├── AppClipConfiguration.plist            ✅ App Clip metadata
└── SETUP_GUIDE.md                       ✅ This file
```

### 3. Configure Target Dependencies

**For App Clip Target, add these frameworks:**
- SwiftUI
- RoomPlan
- SceneKit
- Foundation
- UIKit

**Link the shared source files:**
- Add `RecommendationEngine.swift` to both Main App and App Clip targets
- Add `RecommendationVisualizer.swift` to both Main App and App Clip targets

### 4. Update App Clip Info.plist

Add these keys to your App Clip's Info.plist:

```xml
<key>NSAppClip</key>
<dict>
    <key>NSAppClipRequestEphemeralUserNotification</key>
    <false/>
    <key>NSAppClipRequestLocationConfirmation</key>
    <false/>
</dict>

<key>NSRoomPlanUsageDescription</key>
<string>This app clip uses RoomPlan to display a pre-loaded 3D room for demonstration purposes.</string>
```

### 5. Bundle Room.json File

1. **Add Room.json to App Clip Bundle:**
   - Right-click on App Clip target in Xcode
   - Add Files to "HabitHomeClip"
   - Select `AppClip/Resources/Room.json`
   - Ensure it's added to App Clip target (not main app)

2. **Verify Bundle Resource:**
   ```swift
   // This should work in your App Clip:
   if let path = Bundle.main.path(forResource: "Room", ofType: "json") {
       // Room data found
   }
   ```

### 6. App Store Connect Configuration

**Create App Clip Experience:**

1. **In App Store Connect:**
   - Go to your app → App Clips
   - Create new App Clip experience
   - URL: Choose a unique URL for your QR code
   - Title: "Try Habit Home"
   - Subtitle: "Smart object placement for better habits"

2. **Upload App Clip:**
   - Archive your project in Xcode
   - Upload to App Store Connect
   - Submit for TestFlight review

### 7. QR Code Generation

**After App Store approval:**
1. Apple will provide the App Clip QR code
2. Use this QR code for user discovery
3. Test the QR code with TestFlight builds

## Size Optimization

**Current Implementation Status:**
- ✅ Session-only storage (no persistence)
- ✅ Pre-loaded room data (no live scanning)
- ✅ Limited to sample habits only
- ✅ Simplified onboarding flow
- ✅ App Store linking for full app

**Estimated App Clip Size:** ~3-5 MB (well under 10MB limit)

## User Flow

```
QR Code Scan
    ↓
App Clip Launch (HabitAppClip.swift)
    ↓
Brief Onboarding (AppClipOnboardingView.swift)
    ↓
Habit Selection (AppClipHabitSelectionView.swift)
    ↓
Recommendation View (AppClipHabitRecommendationView.swift)
    ↓
Furniture Editing (AppClipFurnitureEditView.swift)
```

## Testing Checklist

- [ ] App Clip builds successfully
- [ ] Room.json loads from bundle
- [ ] 3D room visualization works
- [ ] Habit recommendations generate
- [ ] Bias slider updates recommendations
- [ ] Furniture editing functionality works
- [ ] "Get Full App" links work
- [ ] App Clip size under 10MB
- [ ] TestFlight distribution works

## Troubleshooting

**Common Issues:**

1. **Room.json not found:**
   - Verify file is added to App Clip target
   - Check Bundle.main.path() returns valid path

2. **Build errors:**
   - Ensure all dependencies are linked
   - Check deployment target compatibility

3. **Size too large:**
   - Remove unused assets
   - Optimize image resources
   - Consider removing non-essential features

## Next Steps

1. Follow this setup guide in Xcode
2. Test the App Clip locally
3. Upload to TestFlight
4. Generate QR code after approval
5. Test end-to-end user experience

The App Clip is now ready for implementation! 🎉 