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
    let isRoomPlanSupported = RoomCaptureSession.isSupported

    var body: some View {
        TabView(selection: $selectedTab) { // Add selection binding
            // Embed RoomScannerView in a NavigationView if you want a title bar for it
            NavigationView {
                RoomScannerView(capturedRoom: $capturedRoom, scanAttempted: $scanAttempted, isRoomPlanSupported: isRoomPlanSupported)
                    // .navigationTitle("Scan Room") // Title now set in RoomCaptureViewControllerSwiftUI
                    // .navigationBarTitleDisplayMode(.inline)
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
                    RecommendationView(roomData: capturedRoom)
                    // .navigationTitle("Recommendations") // Title can be set in RecommendationView itself
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
                Text("Wellbeing Log (Placeholder)")
                    .navigationTitle("Wellbeing")
            }
            .tabItem {
                Label("Wellbeing", systemImage: "heart.text.square")
            }
            .tag(2)

            NavigationView {
                Text("Settings (Placeholder)")
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(3)
        }
    }
}

// Placeholder Recommendation View
struct RecommendationView: View {
    let roomData: CapturedRoom? // Will receive the captured room data

    var body: some View {
        ScrollView { // Make content scrollable if it gets long
            VStack(alignment: .leading, spacing: 15) { // Add spacing and alignment
                if let room = roomData {
                    Text("Scan Analysis:")
                        .font(.title2)
                        .padding(.bottom, 5)
                    
                    InfoRow(label: "Number of Walls", value: "\(room.walls.count)")
                    InfoRow(label: "Number of Doors", value: "\(room.doors.count)")
                    InfoRow(label: "Number of Windows", value: "\(room.windows.count)")
                    InfoRow(label: "Number of Openings", value: "\(room.openings.count)")
                    
                    // Display detected objects
                    Text("Detected Objects:")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("Total Objects: \(room.objects.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 5)
                    
                    if room.objects.isEmpty {
                        Text("No objects detected")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(Array(room.objects.enumerated()), id: \.offset) { index, object in
                            HStack {
                                Text("• \(String(describing: object.category))")
                                    .font(.body)
                                Spacer()
                            }
                            .padding(.leading)
                        }
                    }

                } else {
                    Text("No room data available yet. Please scan a room first.")
                }
            }
            .padding() // Add padding around the VStack content
        }
        .navigationTitle("Your Recommendations")
        .navigationBarTitleDisplayMode(.inline)
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
