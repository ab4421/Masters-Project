import Foundation
import RoomPlan

class RoomDataManager: ObservableObject {
    static let shared = RoomDataManager()
    
    @Published var currentRoom: CapturedRoom?
    @Published var currentPathPoints: [PathPoint] = []
    @Published var hasPersistedRoom: Bool = false
    
    private let fileName = "room_scan_data.json"
    
    private init() {
        self.hasPersistedRoom = Self.roomDataExists()
        // Don't auto-load room data on init to avoid memory issues
        // Room data will be loaded on-demand when needed
    }
    
    // MARK: - File Management
    
    private static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private static func getFileURL() -> URL {
        getDocumentsDirectory().appendingPathComponent("room_scan_data.json")
    }
    
    private static func roomDataExists() -> Bool {
        let fileURL = getFileURL()
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    // MARK: - Data Loading/Saving
    
    func loadRoomData() {
        let fileURL = Self.getFileURL()
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("No persisted room data found")
            currentRoom = nil
            currentPathPoints = []
            hasPersistedRoom = false
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let roomExportData = try decoder.decode(RoomExportData.self, from: data)
            
            currentRoom = roomExportData.room
            currentPathPoints = roomExportData.pathPoints
            hasPersistedRoom = true
            
            print("Successfully loaded persisted room data with \(roomExportData.room.walls.count) walls and \(roomExportData.pathPoints.count) path points")
        } catch {
            print("Error loading room data: \(error)")
            currentRoom = nil
            currentPathPoints = []
            hasPersistedRoom = false
        }
    }
    
    func saveRoomData(room: CapturedRoom, pathPoints: [PathPoint]) {
        let fileURL = Self.getFileURL()
        
        do {
            let exportData = RoomExportData(room: room, pathPoints: pathPoints)
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            let data = try encoder.encode(exportData)
            try data.write(to: fileURL)
            
            // Update published properties
            currentRoom = room
            currentPathPoints = pathPoints
            hasPersistedRoom = true
            
            print("Successfully saved room data with \(room.walls.count) walls and \(pathPoints.count) path points")
        } catch {
            print("Error saving room data: \(error)")
        }
    }
    
    // MARK: - Memory Management
    
    func clearFromMemory() {
        print("Clearing room data from memory (keeping persisted data)")
        currentRoom = nil
        currentPathPoints = []
        // Keep hasPersistedRoom = true so we know data exists on disk
    }
    
    func deletePersistedData() {
        let fileURL = Self.getFileURL()
        
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
                print("Successfully deleted persisted room data")
            }
        } catch {
            print("Error deleting room data: \(error)")
        }
        
        // Clear all state
        currentRoom = nil
        currentPathPoints = []
        hasPersistedRoom = false
    }
    
    // MARK: - Utility Methods
    
    func isRoomDataInMemory() -> Bool {
        return currentRoom != nil
    }
    
    func getRoomInfo() -> (wallCount: Int, objectCount: Int, pathPointCount: Int)? {
        guard let room = currentRoom else { return nil }
        return (
            wallCount: room.walls.count,
            objectCount: room.objects.count,
            pathPointCount: currentPathPoints.count
        )
    }
} 