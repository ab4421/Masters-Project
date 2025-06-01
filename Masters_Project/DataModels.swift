import Foundation

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