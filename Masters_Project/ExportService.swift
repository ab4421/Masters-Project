import Foundation
import RoomPlan

class ExportService {
    static let shared = ExportService()
    
    private init() {}
    
    // MARK: - Export Functions
    
    /// Exports only habit and wellbeing data as CSV
    func exportHabitDataOnly() -> URL? {
        let csvContent = DataManager.shared.generateCSV()
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = "\(DataManager.shared.userData.userID) - habit_wellbeing_data.csv"
        let tempFileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            try csvContent.write(to: tempFileURL, atomically: true, encoding: .utf8)
            return tempFileURL
        } catch {
            print("Error creating habit data CSV file: \(error)")
            return nil
        }
    }
    
    /// Exports only room scan data (USDZ + JSON)
    func exportRoomDataOnly() -> URL? {
        guard let room = RoomDataManager.shared.currentRoom else {
            print("No room data available for export")
            return nil
        }
        
        let pathPoints = RoomDataManager.shared.currentPathPoints
        return exportRoomData(room: room, pathPoints: pathPoints, folderName: "Room_Scan_Export")
    }
    
    /// Exports all data (Room USDZ + JSON + Habit CSV)
    func exportAllData() -> URL? {
        guard let room = RoomDataManager.shared.currentRoom else {
            print("No room data available for combined export")
            return nil
        }
        
        let pathPoints = RoomDataManager.shared.currentPathPoints
        let tempDirectory = FileManager.default.temporaryDirectory
        let userID = DataManager.shared.userData.userID
        let destinationFolderURL = tempDirectory.appendingPathComponent("\(userID)_Complete_Data_Export")
        
        do {
            // Clean up any existing export folder first
            if FileManager.default.fileExists(atPath: destinationFolderURL.path) {
                try FileManager.default.removeItem(at: destinationFolderURL)
            }
            
            // Create main export folder
            try FileManager.default.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true)
            
            // Export USDZ directly to main folder
            let usdzURL = destinationFolderURL.appendingPathComponent("Room.usdz")
            try room.export(to: usdzURL, exportOptions: .parametric)
            
            // Export room JSON directly to main folder
            let roomExportData = RoomExportData(room: room, pathPoints: pathPoints)
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let jsonData = try jsonEncoder.encode(roomExportData)
            let roomJsonURL = destinationFolderURL.appendingPathComponent("Room.json")
            try jsonData.write(to: roomJsonURL)
            
            // Export habit/wellbeing CSV
            let csvContent = DataManager.shared.generateCSV()
            let csvFileName = "\(userID)_habit_wellbeing_data.csv"
            let csvURL = destinationFolderURL.appendingPathComponent(csvFileName)
            try csvContent.write(to: csvURL, atomically: true, encoding: .utf8)
            
            return destinationFolderURL
            
        } catch {
            print("Error creating combined export: \(error)")
            return nil
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func exportRoomData(room: CapturedRoom, pathPoints: [PathPoint], folderName: String) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let destinationFolderURL = tempDirectory.appendingPathComponent(folderName)
        
        do {
            // Create export folder
            try FileManager.default.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true)
            
            // Export USDZ file
            let usdzURL = destinationFolderURL.appendingPathComponent("Room.usdz")
            try room.export(to: usdzURL, exportOptions: .parametric)
            
            // Export JSON data
            let roomExportData = RoomExportData(room: room, pathPoints: pathPoints)
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let jsonData = try jsonEncoder.encode(roomExportData)
            let jsonURL = destinationFolderURL.appendingPathComponent("Room.json")
            try jsonData.write(to: jsonURL)
            
            return destinationFolderURL
            
        } catch {
            print("Error exporting room data: \(error)")
            return nil
        }
    }
} 