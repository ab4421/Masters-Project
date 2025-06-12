import SwiftUI
import RoomPlan

@main
struct HabitAppClip: App {
    var body: some Scene {
        WindowGroup {
            AppClipRootView()
                .onAppear {
                    print("Habit Home App Clip launched")
                }
        }
    }
}

struct AppClipRootView: View {
    @State private var showOnboarding = true
    @State private var roomData: CapturedRoom?
    @State private var pathPoints: [PathPoint] = []
    @State private var isLoadingRoom = true
    @State private var loadError: String?
    
    var body: some View {
        Group {
            if showOnboarding {
                AppClipOnboardingView(
                    showOnboarding: $showOnboarding,
                    roomData: roomData,
                    pathPoints: pathPoints
                )
            } else {
                NavigationView {
                    AppClipHabitSelectionView(
                        roomData: roomData,
                        pathPoints: pathPoints
                    )
                }
            }
        }
        .onAppear {
            loadRoomData()
        }
    }
    
    private func loadRoomData() {
        guard let path = Bundle.main.path(forResource: "Room", ofType: "json") else {
            loadError = "Room.json file not found in bundle"
            isLoadingRoom = false
            return
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            
            // Try to decode the room data and path points
            let roomScanData = try decoder.decode(RoomExportData.self, from: data)
            self.roomData = roomScanData.room
            self.pathPoints = roomScanData.pathPoints
            
            print("Successfully loaded room data with \(roomScanData.pathPoints.count) path points")
            isLoadingRoom = false
        } catch {
            print("Error loading room data: \(error)")
            loadError = "Failed to load room data: \(error.localizedDescription)"
            isLoadingRoom = false
        }
    }
}
