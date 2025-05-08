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

    var body: some View {
        // Check for RoomPlan support before showing the TabView
        // This adapts the logic from AppDelegate in the sample
        if RoomCaptureSession.isSupported {
            TabView(selection: $selectedTab) { // Add selection binding
                // Embed RoomScannerView in a NavigationView if you want a title bar for it
                NavigationView {
                    RoomScannerView(capturedRoom: $capturedRoom, scanAttempted: $scanAttempted)
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
            .onChange(of: capturedRoom == nil) { _ in // Compare the optional state instead of the value
                print("ContentView: capturedRoom changed.")
                if capturedRoom != nil {
                    print("ContentView: New CapturedRoom data received!")
                    self.selectedTab = 1 // Switch to the recommendations tab
                } else {
                    print("ContentView: CapturedRoom data cleared (e.g., scan cancelled or failed).")
                }
            }
        } else {
            // Fallback for unsupported devices
            UnsupportedDeviceView()
        }
    }
}

struct UnsupportedDeviceView: View {
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80) // Slightly smaller
                .foregroundColor(.orange)
            Text("RoomPlan Not Supported")
                .font(.title2) // Slightly smaller title
                .padding(.top)
            Text("This app requires a device with LiDAR and RoomPlan capabilities (e.g., iPhone 12 Pro or newer).")
                .font(.callout)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, 5)
        }
        .padding()
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
                    InfoRow(label: "Objects Identified", value: "\(room.objects.count)")

                    // TODO: Implement simulated object detection and recommendation logic here

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
