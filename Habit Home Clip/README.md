# Habit Home App Clip Implementation

## Overview
This App Clip provides a preview of the Habit Home app's core functionality using a pre-loaded room scan. Users can experience the habit recommendation system without needing to download the full app.

## User Flow
1. **QR Code** → Launch App Clip
2. **Brief Tutorial** → 3-page onboarding about the concept
3. **Habit Selection** → Choose from sample habits
4. **Recommendation View** → See real-time 3D recommendations
5. **Customization** → Adjust bias slider and furniture selection

## File Structure
```
AppClip/
├── HabitAppClip.swift                    ✅ CREATED - Main entry point
├── Views/
│   ├── AppClipOnboardingView.swift       ✅ CREATED - Simplified onboarding
│   ├── AppClipHabitSelectionView.swift   ✅ CREATED - Habit selection
│   ├── AppClipHabitRecommendationView.swift  ❌ NEEDS CREATION
│   ├── AppClipFurnitureEditView.swift    ❌ NEEDS CREATION
│   └── AppClipRoomPreviewView.swift      ❌ NEEDS CREATION
├── Models/
│   ├── AppClipDataModels.swift           ✅ CREATED - Session-only data
│   └── AppClipHabitModel.swift           ✅ CREATED - Habit definitions
├── Managers/
│   ├── RecommendationEngine.swift        ✅ COPIED - Core algorithm
│   └── RecommendationVisualizer.swift    ✅ COPIED - 3D visualization
└── Resources/
    └── preset_room.json                  ❌ NEEDS YOUR UPLOAD
```

## Setup Instructions

### 1. Upload Your Room JSON
- Upload your room scan JSON file (229KB)
- Save it as `AppClip/Resources/preset_room.json`

### 2. Create App Clip Target in Xcode
1. File → New → Target → App Clip
2. Name it "HabitHomeClip" 
3. Set minimum deployment to iOS 14.0
4. Add App Clip files to the target

### 3. Configure Info.plist
Add App Clip configuration:
```xml
<key>NSAppClip</key>
<dict>
    <key>NSAppClipRequestEphemeralUserNotification</key>
    <false/>
    <key>NSAppClipRequestLocationConfirmation</key>
    <false/>
</dict>
```

### 4. Missing Files to Create

#### AppClipHabitRecommendationView.swift
- Copy from main app's `HabitRecommendationView.swift`
- Replace `HabitConfigurationManager` with `AppClipConfigurationManager`
- Remove persistence features
- Keep all recommendation logic

#### AppClipFurnitureEditView.swift
- Copy from main app's `FurnitureEditView.swift`
- Remove persistence
- Keep session-only furniture selection

#### AppClipRoomPreviewView.swift
- Copy room preview components from `RoomScannerView.swift`
- Keep only the preview functionality

### 5. Bundle Size Optimization
Current estimated size: ~2-3MB
- Your JSON: 229KB
- Core frameworks: ~1.5MB
- UI components: ~500KB
- **Total: Well under 10MB limit** ✅

### 6. Test Plan
1. **Local Testing**: Test in simulator and device
2. **Size Verification**: Ensure bundle stays under 10MB
3. **Functionality Testing**: Verify all core features work
4. **QR Code Testing**: Test App Clip discovery

## Key Differences from Main App

### Removed Features
- Room scanning
- Data persistence
- Custom habit creation
- Data export
- Research participation
- User account management

### Kept Features
- Habit recommendation engine
- 3D room visualization
- Bias adjustment sliders
- Furniture selection editing
- Real-time recommendation updates

## Development Notes

### Configuration Management
- Uses `AppClipConfigurationManager` for session-only storage
- No UserDefaults or file persistence
- All data cleared when App Clip ends

### Habit Data
- Only sample habits included
- No custom habit functionality
- Identical behavior to main app for core features

### 3D Rendering
- Full SceneKit and RoomPlan support
- Identical visualization to main app
- Pre-loaded room data for instant access

## Next Steps
1. Upload your room JSON file
2. Create the missing view files
3. Set up App Clip target in Xcode
4. Test functionality
5. Generate QR code for distribution

## App Store Configuration
- App Clip will automatically link to main app download
- Update App Store URL in `AppClipHabitSelectionView.swift`
- Configure Advanced App Clip Experiences in App Store Connect 