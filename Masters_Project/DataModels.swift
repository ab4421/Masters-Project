import Foundation
import RoomPlan
import simd

// MARK: - Data Models

struct HabitEntry: Codable {
    let habitCompleted: Bool
    let objectsInPlace: Bool
    let timestamp: Date
}

struct WellbeingEntry: Codable {
    let answers: [Int] // 12 RENSS scale answers
    let timestamp: Date
}

struct DailyEntry: Codable {
    let date: String // Format: "yyyy-MM-dd"
    var habitEntry: HabitEntry?
    var wellbeingEntry: WellbeingEntry?
}

// MARK: - User Data Container

struct UserData: Codable {
    let userID: String
    var dailyEntries: [String: DailyEntry] // Key: date string
    
    init(userID: String = UUID().uuidString) {
        self.userID = userID
        self.dailyEntries = [:]
    }
}

// MARK: - Room Scan Data Models

// Path tracking structure
public struct PathPoint: Codable {
    let position: SIMD3<Float>
    let timestamp: TimeInterval
    let confidence: Float
    
    // Add coding keys to handle SIMD3<Float> serialization
    enum CodingKeys: String, CodingKey {
        case positionX, positionY, positionZ
        case timestamp
        case confidence
    }
    
    // Custom encoding for SIMD3<Float>
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(position.x, forKey: .positionX)
        try container.encode(position.y, forKey: .positionY)
        try container.encode(position.z, forKey: .positionZ)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(confidence, forKey: .confidence)
    }
    
    // Custom decoding for SIMD3<Float>
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(Float.self, forKey: .positionX)
        let y = try container.decode(Float.self, forKey: .positionY)
        let z = try container.decode(Float.self, forKey: .positionZ)
        position = SIMD3<Float>(x, y, z)
        timestamp = try container.decode(TimeInterval.self, forKey: .timestamp)
        confidence = try container.decode(Float.self, forKey: .confidence)
    }
    
    // Keep the existing initializer
    public init(position: SIMD3<Float>, timestamp: TimeInterval, confidence: Float) {
        self.position = position
        self.timestamp = timestamp
        self.confidence = confidence
    }
}

// MARK: - Room Scan Export Data

// Wrapper structure for room export data
struct RoomExportData: Codable {
    let room: CapturedRoom
    let pathPoints: [PathPoint]
} 