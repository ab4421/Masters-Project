//
//  ContentView.swift
//  Masters_Project
//
//  Created by Arnav Bhatia on 08/05/2025.
//

// ContentView.swift
import SwiftUI
import RoomPlan // Don't forget to import RoomPlan here

struct ContentView: View {
    @State private var capturedRoom: CapturedRoom? = nil // Explicitly initialize as nil
    @State private var selectedTab: Int = 0 // To programmatically change tabs
    @State private var scanAttempted: Bool = false // To know if we should even try to show recommendations
    @State private var pathPoints: [PathPoint] = []
    @State private var showMemoryAlert: Bool = false // Show alert when memory was cleared
    let isRoomPlanSupported = RoomCaptureSession.isSupported

    var body: some View {
        TabView(selection: $selectedTab) { // Add selection binding
            // Embed RoomScannerView in a NavigationView if you want a title bar for it
            NavigationView {
                RoomScannerView(
                    capturedRoom: $capturedRoom,
                    scanAttempted: $scanAttempted,
                    isRoomPlanSupported: isRoomPlanSupported,
                    onPathPointsUpdated: { points in
                        pathPoints = points
                    },
                    onRoomDataLoaded: {
                        // Room data was successfully loaded
                        print("New room data loaded")
                    }
                )
            }
            .tabItem {
                Label("Scan Room", systemImage: "camera.metering.matrix")
            }
            .tag(0) // Tag for programmatic selection

            // Use scanAttempted to decide if we show the recommendation view
            // or a placeholder if no scan has been successfully completed yet.
            // Embed RecommendationView in a NavigationView for its own title
            NavigationView {
                if scanAttempted && capturedRoom != nil {
                    HabitSelectionView(
                        roomData: capturedRoom,
                        pathPoints: pathPoints
                    )
                } else {
                    VStack {
                        Text("Scan a room to see recommendations.")
                            .font(.headline)
                            .padding(.bottom)
                        if scanAttempted && capturedRoom == nil {
                            Text("(Previous scan might have failed or was cancelled)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .navigationTitle("Recommendations") // Title for the placeholder state
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            .tabItem {
                Label("Recommendations", systemImage: capturedRoom != nil && scanAttempted ? "lightbulb.fill" : "lightbulb")
            }
            .tag(1)

            NavigationView {
                HabitChecklistView()
            }
            .tabItem {
                Label("Checklist", systemImage: "checklist")
            }
            .tag(2)

            NavigationView {
                WellbeingView()
            }
            .tabItem {
                Label("Wellbeing", systemImage: "heart.text.square")
            }
            .tag(3)

            NavigationView {
                AboutView()
            }
            .tabItem {
                Label("About", systemImage: "info.circle")
            }
            .tag(4)
        }
        // MARK: - App Lifecycle Management for Memory Optimization
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            print("App entering background - clearing heavy memory objects")
            clearHeavyResources()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            print("App entering foreground")
            // Room data will need to be re-imported/scanned if it was cleared
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
            print("Received memory warning - clearing heavy resources immediately")
            clearHeavyResources()
        }
        .alert("Memory Cleared", isPresented: $showMemoryAlert) {
            Button("OK") {
                resetToFreshState()
            }
        } message: {
            Text("Room data was cleared to save memory while the app was in the background. Please re-scan your room or import a previously saved scan to continue.")
        }
    }
    
    // MARK: - Memory Management
    private func clearHeavyResources() {
        // Only clear if we actually have heavy objects to clear
        if capturedRoom != nil || !pathPoints.isEmpty {
            print("Clearing CapturedRoom (\(capturedRoom?.walls.count ?? 0) walls, \(capturedRoom?.objects.count ?? 0) objects) and \(pathPoints.count) path points")
            
            // Clear the heavy memory objects
            capturedRoom = nil
            pathPoints.removeAll()
            
            // Show alert to user explaining what happened
            showMemoryAlert = true
            
            // Force garbage collection to free memory immediately
            autoreleasepool {
                // This helps ensure objects are deallocated immediately
            }
            
            print("Heavy resources cleared successfully")
        }
    }
    
    private func resetToFreshState() {
        // Reset all state to fresh app launch
        scanAttempted = false
        selectedTab = 0 // Go back to scanner tab
        print("App reset to fresh state")
    }
}

// Placeholder Recommendation View
struct RecommendationView: View {
    let roomData: CapturedRoom?
    let pathPoints: [PathPoint]

    var body: some View {
        HabitSelectionView(
            roomData: roomData,
            pathPoints: pathPoints
        )
    }
}

// Helper view for consistent info display
struct InfoRow: View {
    var label: String
    var value: String

    var body: some View {
        HStack {
            Text(label + ":")
                .fontWeight(.semibold)
            Text(value)
            Spacer() // Pushes content to the left
        }
    }
}


#Preview {
    ContentView()
}
