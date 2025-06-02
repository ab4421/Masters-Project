import Foundation
import RoomPlan

// MARK: - Data Models

struct HabitConfiguration: Codable {
    let habitID: UUID
    var associatedFurnitureTypes: [CapturedRoom.Object.Category]
    var associatedFurnitureIndices: [Int]
    var biasPosition: Double
    let lastModified: Date
    
    init(habitID: UUID, associatedFurnitureTypes: [CapturedRoom.Object.Category], associatedFurnitureIndices: [Int], biasPosition: Double = 7.0) {
        self.habitID = habitID
        self.associatedFurnitureTypes = associatedFurnitureTypes
        self.associatedFurnitureIndices = associatedFurnitureIndices
        self.biasPosition = biasPosition
        self.lastModified = Date()
    }
}

struct HabitConfigurationData: Codable {
    var configurations: [String: HabitConfiguration] // Key: habitID.uuidString
    var starredHabitID: String? // Key: habitID.uuidString
}

// MARK: - Manager Class

class HabitConfigurationManager: ObservableObject {
    static let shared = HabitConfigurationManager()
    
    @Published var configurations: [String: HabitConfiguration] = [:]
    @Published var hasPersistedConfigurations: Bool = false
    @Published var starredHabitID: UUID? = nil
    
    private let fileName = "habit_configurations.json"
    
    private init() {
        self.hasPersistedConfigurations = Self.configurationsExist()
        loadConfigurations()
    }
    
    // MARK: - File Management
    
    private static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private static func getFileURL() -> URL {
        getDocumentsDirectory().appendingPathComponent("habit_configurations.json")
    }
    
    private static func configurationsExist() -> Bool {
        let fileURL = getFileURL()
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    // MARK: - Data Loading/Saving
    
    private func loadConfigurations() {
        let fileURL = Self.getFileURL()
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("No persisted habit configurations found")
            configurations = [:]
            hasPersistedConfigurations = false
            starredHabitID = nil
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let configurationData = try decoder.decode(HabitConfigurationData.self, from: data)
            
            configurations = configurationData.configurations
            starredHabitID = configurationData.starredHabitID != nil ? UUID(uuidString: configurationData.starredHabitID!) : nil
            hasPersistedConfigurations = true
            
            print("Successfully loaded \(configurations.count) habit configurations")
            if let starredID = starredHabitID {
                print("Loaded starred habit ID: \(starredID)")
            }
        } catch {
            print("Error loading habit configurations: \(error)")
            configurations = [:]
            hasPersistedConfigurations = false
            starredHabitID = nil
        }
    }
    
    private func saveConfigurations() {
        let fileURL = Self.getFileURL()
        
        do {
            let configurationData = HabitConfigurationData(
                configurations: configurations,
                starredHabitID: starredHabitID?.uuidString
            )
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            
            let data = try encoder.encode(configurationData)
            try data.write(to: fileURL)
            
            hasPersistedConfigurations = true
            print("Successfully saved \(configurations.count) habit configurations")
            if let starredID = starredHabitID {
                print("Saved starred habit ID: \(starredID)")
            }
        } catch {
            print("Error saving habit configurations: \(error)")
        }
    }
    
    // MARK: - Public Methods
    
    func saveConfiguration(for habit: Habit, biasPosition: Double = 7.0) {
        let configuration = HabitConfiguration(
            habitID: habit.id,
            associatedFurnitureTypes: habit.associatedFurnitureTypes,
            associatedFurnitureIndices: habit.associatedFurnitureIndices,
            biasPosition: biasPosition
        )
        
        configurations[habit.id.uuidString] = configuration
        saveConfigurations()
        
        print("Saved configuration for habit: \(habit.name)")
    }
    
    func getConfiguration(for habitID: UUID) -> HabitConfiguration? {
        return configurations[habitID.uuidString]
    }
    
    func applyConfiguration(to habit: inout Habit) -> Double? {
        guard let configuration = getConfiguration(for: habit.id) else {
            print("No saved configuration found for habit: \(habit.name)")
            return nil
        }
        
        habit.associatedFurnitureTypes = configuration.associatedFurnitureTypes
        habit.associatedFurnitureIndices = configuration.associatedFurnitureIndices
        
        print("Applied saved configuration to habit: \(habit.name)")
        return configuration.biasPosition
    }
    
    func deleteConfiguration(for habitID: UUID) {
        configurations.removeValue(forKey: habitID.uuidString)
        saveConfigurations()
        
        print("Deleted configuration for habit ID: \(habitID)")
    }
    
    func clearAllConfigurations() {
        configurations.removeAll()
        starredHabitID = nil
        
        let fileURL = Self.getFileURL()
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
                print("Successfully deleted all habit configurations")
            }
        } catch {
            print("Error deleting habit configurations: \(error)")
        }
        
        hasPersistedConfigurations = false
    }
    
    // MARK: - Starred Habit Methods
    
    func starHabit(_ habitID: UUID) {
        starredHabitID = habitID
        saveConfigurations()
        print("Starred habit: \(habitID)")
    }
    
    func unstarHabit() {
        starredHabitID = nil
        saveConfigurations()
        print("Unstarred habit")
    }
    
    func getStarredHabit() -> Habit? {
        guard let starredID = starredHabitID else { return nil }
        
        // Look for the habit in all available habits
        let allHabits = Habit.getAllHabits()
        return allHabits.first { $0.id == starredID }
    }
    
    func isHabitStarred(_ habitID: UUID) -> Bool {
        return starredHabitID == habitID
    }
    
    // MARK: - Utility Methods
    
    func getConfigurationCount() -> Int {
        return configurations.count
    }
    
    func hasConfiguration(for habitID: UUID) -> Bool {
        return configurations[habitID.uuidString] != nil
    }
} 