# Habit Home
**Habit Formation Through Environmental Design**

## Overview

Smart Living Spaces is an iOS research application that uses advanced 3D room scanning and AI analysis to optimize object placement for better habit formation. By combining environmental psychology with cutting-edge AR technology, the app helps users create spaces that naturally encourage healthy behaviors.

## Core Concept

**Visual Cues + Low Friction = Better Habits**

The app leverages the principle that our environment significantly influences our behavior by:
- **Maximizing Visual Cues**: Placing habit-related objects in highly visible locations
- **Minimizing Friction**: Reducing the effort required to perform desired actions
- **Optimizing Placement**: Using AI to find the perfect balance between visibility and accessibility

## Features

### 🏠 3D Room Scanning
- Advanced room mapping using Apple's RoomPlan framework
- Real-time movement tracking and path analysis
- Comprehensive furniture and surface detection

### 🤖 AI-Powered Recommendations
- Intelligent object placement suggestions
- Customizable weighting between path proximity and furniture association
- Multi-criteria scoring algorithm considering:
  - Distance from user movement patterns
  - Proximity to relevant furniture
  - Surface accessibility and visibility

### 📱 Habit Management
- Pre-configured habits with smart defaults
- Custom habit creation and configuration
- Furniture association management
- Habit tracking and progress monitoring

### 📊 Research & Analytics
- Comprehensive data export for research purposes
- Movement pattern analysis
- Habit formation tracking
- Wellbeing impact measurement

### 🎯 Interactive Tutorial
- Comprehensive onboarding experience
- Feature discovery and guidance
- Research participation consent flow

## How It Works

1. **Room Scanning**: Use your device's camera to create a detailed 3D map of your space
2. **AI Analysis**: Advanced algorithms analyze your movement patterns and furniture layout
3. **Smart Placement**: Receive personalized recommendations for optimal object positioning
4. **Habit Tracking**: Monitor your progress and measure the impact on your wellbeing

## Algorithm

The recommendation engine uses a sophisticated scoring system:

```
Score = (Path Distance × W₁) + (Furniture Distance × W₂)
```

Where:
- **Path Distance**: How far the surface is from your typical movement patterns
- **Furniture Distance**: Proximity to relevant furniture for the specific habit
- **W₁, W₂**: User-adjustable weights for personalized recommendations

**Lower scores indicate better placement locations.**

## Technical Requirements

### System Requirements
- iOS 16.0 or later
- ARKit-compatible device
- RoomPlan support (iPhone 12 Pro and later, iPad Pro with LiDAR)

### Key Dependencies
- **RoomPlan**: Apple's 3D room scanning framework
- **SceneKit**: 3D scene rendering and visualization
- **ARKit**: Augmented reality and spatial tracking
- **SwiftUI**: Modern iOS user interface framework

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/smart-living-spaces.git
cd smart-living-spaces
```

2. Open `Masters_Project.xcodeproj` in Xcode 15 or later

3. Build and run on a compatible iOS device (RoomPlan requires physical hardware)

## Project Structure

```
Masters_Project/
├── Views/
│   ├── HabitRecommendationView.swift    # Main recommendation interface
│   ├── RoomScannerView.swift            # 3D room scanning
│   ├── HabitSelectionView.swift         # Habit management
│   ├── AboutView.swift                  # App information and tutorial
│   └── WellbeingView.swift              # Progress tracking
├── Models/
│   ├── HabitModel.swift                 # Habit data structures
│   ├── DataModels.swift                 # Core data models
│   └── RecommendationEngine.swift       # AI recommendation logic
├── Managers/
│   ├── RoomDataManager.swift            # Room data persistence
│   ├── DataManager.swift                # General data management
│   └── HabitConfigurationManager.swift  # Habit settings
└── Services/
    ├── ExportService.swift              # Data export functionality
    └── NotificationManager.swift        # User notifications
```

## Research Foundation

This project builds upon research in:

- **Environmental Psychology**: How physical spaces influence behavior and decision-making
- **Habit Formation**: Cue-based habit loops and friction reduction theory
- **Smart Home Technology**: IoT and AR interventions for behavior change
- **Digital Wellbeing**: Validated measurement techniques for habit impact assessment

## Data Export

The app includes comprehensive data export capabilities for research purposes, including:
- Room geometry and furniture placement data
- Movement pattern analysis
- Habit tracking progress
- Recommendation effectiveness metrics
- User interaction logs

## Privacy & Research Ethics

- All data collection follows ethical research guidelines
- Users provide informed consent for research participation
- Personal data is anonymized for research purposes
- Local data storage with optional research sharing

## Contributing

This is a research project for academic purposes. If you're interested in contributing or have research collaboration inquiries, please contact the author.

## Author

**Arnav Bhatia**  
Imperial College London  
📧 arnav.bhatia21@imperial.ac.uk

## Research Context

This application is part of a Master's thesis investigating how environmental design and smart technology can support healthy habit formation. The project combines insights from behavioral psychology, environmental design, and human-computer interaction to create practical tools for improving daily living spaces.

## License

This project is part of academic research. Please contact the author for licensing information and research collaboration opportunities.

## Acknowledgments

- Apple for RoomPlan and ARKit frameworks
- Imperial College London for research support
- Research participants who contributed to app development and validation

---

*For questions, research collaboration, or technical support, please contact arnav.bhatia21@imperial.ac.uk* 
