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
    @StateObject private var roomDataManager = RoomDataManager.shared
    @State private var selectedTab: Int = 0 // To programmatically change tabs
    @State private var scanAttempted: Bool = false // To know if we should even try to show recommendations
    let isRoomPlanSupported = RoomCaptureSession.isSupported

    var body: some View {
        TabView(selection: $selectedTab) { // Add selection binding
            // Embed RoomScannerView in a NavigationView if you want a title bar for it
            NavigationView {
                RoomScannerView(
                    capturedRoom: $roomDataManager.currentRoom,
                    scanAttempted: $scanAttempted,
                    isRoomPlanSupported: isRoomPlanSupported,
                    onPathPointsUpdated: { points in
                        // This is handled by RoomDataManager now
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
                if (scanAttempted && roomDataManager.currentRoom != nil) || roomDataManager.hasPersistedRoom {
                    HabitSelectionView(
                        roomData: roomDataManager.currentRoom,
                        pathPoints: roomDataManager.currentPathPoints
                    )
                    .onAppear {
                        // Load room data if we have persisted data but it's not in memory
                        if roomDataManager.hasPersistedRoom && !roomDataManager.isRoomDataInMemory() {
                            roomDataManager.loadRoomData()
                        }
                    }
                } else {
                    VStack {
                        Text("Scan a room to see recommendations.")
                            .font(.headline)
                            .padding(.bottom)
                        if scanAttempted && roomDataManager.currentRoom == nil && !roomDataManager.hasPersistedRoom {
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
                Label("Recommendations", systemImage: (roomDataManager.currentRoom != nil || roomDataManager.hasPersistedRoom) && (scanAttempted || roomDataManager.hasPersistedRoom) ? "lightbulb.fill" : "lightbulb")
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
                DataExportView()
            }
            .tabItem {
                Label("Data Export", systemImage: "square.and.arrow.up")
            }
            .tag(4)
        }
        // MARK: - App Lifecycle Management for Memory Optimization
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            print("App entering background - clearing room data from memory")
            clearHeavyResources()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            print("App entering foreground")
            // No alerts needed - the UI will show the saved data status naturally
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
            print("Received memory warning - clearing heavy resources immediately")
            clearHeavyResources()
        }
        .onAppear {
            // Check for persisted room data on app launch
            if roomDataManager.hasPersistedRoom {
                scanAttempted = true // Show recommendations tab as active
                print("Found persisted room data - ready to load when needed")
            }
        }
    }
    
    // MARK: - Memory Management
    private func clearHeavyResources() {
        // Only clear if we actually have heavy objects in memory
        if roomDataManager.isRoomDataInMemory() {
            if let roomInfo = roomDataManager.getRoomInfo() {
                print("Clearing room data from memory: \(roomInfo.wallCount) walls, \(roomInfo.objectCount) objects, \(roomInfo.pathPointCount) path points")
            }
            
            // Clear from memory but keep persisted - no user alert needed
            roomDataManager.clearFromMemory()
            
            print("Room data cleared from memory but remains saved to disk")
        }
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
