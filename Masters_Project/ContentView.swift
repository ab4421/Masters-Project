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
