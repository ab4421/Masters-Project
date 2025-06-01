import Foundation

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var userData: UserData
    
    private let fileName = "habit_wellbeing_data.json"
    
    private init() {
        self.userData = DataManager.loadUserData()
    }
    
    // MARK: - File Management
    
    private static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private static func getFileURL() -> URL {
        getDocumentsDirectory().appendingPathComponent("habit_wellbeing_data.json")
    }
    
    // MARK: - Data Loading/Saving
    
    private static func loadUserData() -> UserData {
        let fileURL = getFileURL()
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return UserData() // Create new user data if file doesn't exist
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let userData = try JSONDecoder.decoder.decode(UserData.self, from: data)
            return userData
        } catch {
            print("Error loading user data: \(error)")
            return UserData() // Return new data if loading fails
        }
    }
    
    private func saveUserData() {
        let fileURL = DataManager.getFileURL()
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            
            let data = try encoder.encode(userData)
            try data.write(to: fileURL)
        } catch {
            print("Error saving user data: \(error)")
        }
    }
    
    // MARK: - Data Entry Methods
    
    func saveHabitEntry(habitCompleted: Bool, objectsInPlace: Bool) {
        let today = getTodayDateString()
        let habitEntry = HabitEntry(
            habitCompleted: habitCompleted,
            objectsInPlace: objectsInPlace,
            timestamp: Date()
        )
        
        if var existingEntry = userData.dailyEntries[today] {
            existingEntry.habitEntry = habitEntry
            userData.dailyEntries[today] = existingEntry
        } else {
            let newEntry = DailyEntry(date: today, habitEntry: habitEntry, wellbeingEntry: nil)
            userData.dailyEntries[today] = newEntry
        }
        
        saveUserData()
        
        // Check if notifications should be cancelled
        NotificationManager.shared.checkAndCancelNotificationsIfNeeded()
    }
    
    func saveWellbeingEntry(answers: [Int]) {
        guard answers.count == 12 && !answers.contains(0) else {
            print("Invalid wellbeing answers")
            return
        }
        
        let today = getTodayDateString()
        let wellbeingEntry = WellbeingEntry(
            answers: answers,
            timestamp: Date()
        )
        
        if var existingEntry = userData.dailyEntries[today] {
            existingEntry.wellbeingEntry = wellbeingEntry
            userData.dailyEntries[today] = existingEntry
        } else {
            let newEntry = DailyEntry(date: today, habitEntry: nil, wellbeingEntry: wellbeingEntry)
            userData.dailyEntries[today] = newEntry
        }
        
        saveUserData()
        
        // Check if notifications should be cancelled
        NotificationManager.shared.checkAndCancelNotificationsIfNeeded()
    }
    
    // MARK: - Helper Methods
    
    private func getTodayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    func getTodayEntry() -> DailyEntry? {
        let today = getTodayDateString()
        return userData.dailyEntries[today]
    }
    
    // MARK: - CSV Export
    
    func generateCSV() -> String {
        var csvContent = "user_id,date,habit_time,habit_completed,objects_in_place,wellbeing_time,renss_1,renss_2,renss_3,renss_4,renss_5,renss_6,renss_7,renss_8,renss_9,renss_10,renss_11,renss_12\n"
        
        let sortedEntries = userData.dailyEntries.values.sorted { $0.date < $1.date }
        
        for entry in sortedEntries {
            let userID = userData.userID
            let date = entry.date
            
            let habitTime = entry.habitEntry?.timestamp.timeString ?? ""
            let habitCompleted = entry.habitEntry?.habitCompleted ?? false
            let objectsInPlace = entry.habitEntry?.objectsInPlace ?? false
            
            let wellbeingTime = entry.wellbeingEntry?.timestamp.timeString ?? ""
            let renssAnswers = entry.wellbeingEntry?.answers ?? Array(repeating: 0, count: 12)
            
            let renssString = renssAnswers.map { String($0) }.joined(separator: ",")
            
            csvContent += "\(userID),\(date),\(habitTime),\(habitCompleted),\(objectsInPlace),\(wellbeingTime),\(renssString)\n"
        }
        
        return csvContent
    }
}

// MARK: - Extensions

extension JSONDecoder {
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

extension Date {
    var timeString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm"
        formatter.amSymbol = ""
        formatter.pmSymbol = ""
        return formatter.string(from: self)
    }
}