# App Clip Xcode Error Fixes

## Current Errors and Solutions

### 1. "Cannot find 'Habit' in scope" Error

**Problem**: The App Clip models aren't being compiled with the App Clip target.

**Solution**: In Xcode, ensure these files are added to your App Clip target:
- `AppClip/Models/AppClipHabitModel.swift`
- `AppClip/Models/AppClipDataModels.swift`

**Steps**:
1. Select the file in Xcode
2. In the File Inspector (right panel), check the App Clip target checkbox
3. Ensure it's checked for ALL files in the `AppClip/` folder

### 2. "Invalid redeclaration of 'RecommendationVisualizer'" Error

**Problem**: The same files are being included in both main app and App Clip targets.

**Solution**: 
1. **Remove** `RecommendationEngine.swift` and `RecommendationVisualizer.swift` from the **App Clip** target
2. **Keep** them only in the **Main App** target
3. **Add** them as **shared** files:

**In Xcode**:
1. Select `RecommendationEngine.swift`
2. In File Inspector, **uncheck** the App Clip target
3. **Check** only the Main App target
4. Repeat for `RecommendationVisualizer.swift`

### 3. Alternative Solution (If above doesn't work)

Create App Clip specific copies:

1. **Delete** the copied files:
   ```bash
   rm AppClip/Managers/RecommendationEngine.swift
   rm AppClip/Managers/RecommendationVisualizer.swift
   ```

2. **Link** to the main app files instead:
   - In Xcode, drag the original files from main app into App Clip target
   - Choose "Create groups" (don't copy)
   - This creates references instead of duplicates

### 4. Quick Target Configuration Check

**Main App Target should include**:
- All original source files
- `RecommendationEngine.swift` 
- `RecommendationVisualizer.swift`

**App Clip Target should include**:
- All `AppClip/` folder files
- **Either** shared references to engine files **OR** only the App Clip versions

### 5. Build Settings to Check

In your App Clip target Build Settings:
- **Swift Language Version**: Same as main app
- **iOS Deployment Target**: iOS 16.0+
- **Framework Search Paths**: Include RoomPlan and SceneKit

## Test After Changes

1. Clean build folder (Cmd+Shift+K)
2. Build App Clip target specifically
3. Verify no duplicate symbol errors
4. Test that Habit types are found

## If Issues Persist

Try this build order:
1. Build main app first
2. Then build App Clip
3. Archive both together

The key is ensuring no duplicate symbols while maintaining access to shared types. 