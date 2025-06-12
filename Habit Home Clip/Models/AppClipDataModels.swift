import Foundation
import RoomPlan
import simd

// MARK: - Room Scan Data Models (Same as main app, needed for JSON decoding)

public struct PathPoint: Codable {
    let position: SIMD3<Float>
    let timestamp: TimeInterval
    let confidence: Float
    
    enum CodingKeys: String, CodingKey {
        case positionX, positionY, positionZ
        case timestamp
        case confidence
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(position.x, forKey: .positionX)
        try container.encode(position.y, forKey: .positionY)
        try container.encode(position.z, forKey: .positionZ)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(confidence, forKey: .confidence)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(Float.self, forKey: .positionX)
        let y = try container.decode(Float.self, forKey: .positionY)
        let z = try container.decode(Float.self, forKey: .positionZ)
        position = SIMD3<Float>(x, y, z)
        timestamp = try container.decode(TimeInterval.self, forKey: .timestamp)
        confidence = try container.decode(Float.self, forKey: .confidence)
    }
    
    public init(position: SIMD3<Float>, timestamp: TimeInterval, confidence: Float) {
        self.position = position
        self.timestamp = timestamp
        self.confidence = confidence
    }
}

struct RoomExportData: Codable {
    let room: CapturedRoom
    let pathPoints: [PathPoint]
}

// MARK: - App Clip Habit Configuration (In-Memory Only)

class AppClipConfigurationManager: ObservableObject {
    static let shared = AppClipConfigurationManager()
    
    // In-memory storage only - no persistence
    @Published private var sessionConfigurations: [String: AppClipHabitConfiguration] = [:]
    @Published private var starredHabitID: UUID? = nil
    
    private init() {}
    
    // MARK: - Configuration Management
    
    func saveConfiguration(for habit: Habit, biasPosition: Double = 7.0) {
        let configuration = AppClipHabitConfiguration(
            habitID: habit.id,
            associatedFurnitureTypes: habit.associatedFurnitureTypes,
            associatedFurnitureIndices: habit.associatedFurnitureIndices,
            biasPosition: biasPosition
        )
        
        sessionConfigurations[habit.id.uuidString] = configuration
        print("Saved session configuration for habit: \(habit.name)")
    }
    
    func getConfiguration(for habitID: UUID) -> AppClipHabitConfiguration? {
        return sessionConfigurations[habitID.uuidString]
    }
    
    func applyConfiguration(to habit: inout Habit) -> Double? {
        guard let configuration = getConfiguration(for: habit.id) else {
            print("No session configuration found for habit: \(habit.name)")
            return nil
        }
        
        habit.associatedFurnitureTypes = configuration.associatedFurnitureTypes
        habit.associatedFurnitureIndices = configuration.associatedFurnitureIndices
        
        print("Applied session configuration to habit: \(habit.name)")
        return configuration.biasPosition
    }
    
    func deleteConfiguration(for habitID: UUID) {
        sessionConfigurations.removeValue(forKey: habitID.uuidString)
        print("Deleted session configuration for habit ID: \(habitID)")
    }
    
    // MARK: - Starred Habit Management (Session Only)
    
    func starHabit(_ habitID: UUID) {
        starredHabitID = habitID
        print("Starred habit for session: \(habitID)")
    }
    
    func unstarHabit() {
        starredHabitID = nil
        print("Unstarred habit for session")
    }
    
    func getStarredHabit() -> Habit? {
        guard let starredID = starredHabitID else { return nil }
        
        let allHabits = Habit.getAllHabits()
        return allHabits.first { $0.id == starredID }
    }
    
    func isHabitStarred(_ habitID: UUID) -> Bool {
        return starredHabitID == habitID
    }
    
    // MARK: - Session Management
    
    func clearSession() {
        sessionConfigurations.removeAll()
        starredHabitID = nil
        print("Cleared all session data")
    }
    
    func getConfigurationCount() -> Int {
        return sessionConfigurations.count
    }
    
    func hasConfiguration(for habitID: UUID) -> Bool {
        return sessionConfigurations[habitID.uuidString] != nil
    }
}

// MARK: - App Clip Configuration Model

struct AppClipHabitConfiguration {
    let habitID: UUID
    var associatedFurnitureTypes: [CapturedRoom.Object.Category]
    var associatedFurnitureIndices: [Int]
    var biasPosition: Double
    let sessionTimestamp: Date
    
    init(habitID: UUID, associatedFurnitureTypes: [CapturedRoom.Object.Category], associatedFurnitureIndices: [Int], biasPosition: Double = 7.0) {
        self.habitID = habitID
        self.associatedFurnitureTypes = associatedFurnitureTypes
        self.associatedFurnitureIndices = associatedFurnitureIndices
        self.biasPosition = biasPosition
        self.sessionTimestamp = Date()
    }
} 