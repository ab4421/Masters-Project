import Foundation
import RoomPlan

// MARK: - Data Models

struct CustomHabitData: Codable {
    var habits: [Habit]
}

// MARK: - Manager Class

class CustomHabitManager: ObservableObject {
    static let shared = CustomHabitManager()
    
    @Published var customHabits: [Habit] = []
    
    private let fileName = "custom_habits.json"
    
    private init() {
        loadCustomHabits()
    }
    
    // MARK: - File Management
    
    private static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private static func getFileURL() -> URL {
        getDocumentsDirectory().appendingPathComponent("custom_habits.json")
    }
    
    // MARK: - Data Loading/Saving
    
    private func loadCustomHabits() {
        let fileURL = Self.getFileURL()
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("No custom habits found")
            customHabits = []
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let customHabitData = try decoder.decode(CustomHabitData.self, from: data)
            
            customHabits = customHabitData.habits
            print("Successfully loaded \(customHabits.count) custom habits")
        } catch {
            print("Error loading custom habits: \(error)")
            customHabits = []
        }
    }
    
    private func saveCustomHabits() {
        let fileURL = Self.getFileURL()
        
        do {
            let customHabitData = CustomHabitData(habits: customHabits)
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            let data = try encoder.encode(customHabitData)
            try data.write(to: fileURL)
            
            print("Successfully saved \(customHabits.count) custom habits")
        } catch {
            print("Error saving custom habits: \(error)")
        }
    }
    
    // MARK: - CRUD Operations
    
    func addHabit(_ habit: Habit) {
        customHabits.append(habit)
        saveCustomHabits()
        print("Added custom habit: \(habit.name)")
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = customHabits.firstIndex(where: { $0.id == habit.id }) {
            customHabits[index] = habit
            saveCustomHabits()
            print("Updated custom habit: \(habit.name)")
        }
    }
    
    func deleteHabit(withId id: UUID) {
        if let index = customHabits.firstIndex(where: { $0.id == id }) {
            let habitName = customHabits[index].name
            customHabits.remove(at: index)
            saveCustomHabits()
            print("Deleted custom habit: \(habitName)")
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        deleteHabit(withId: habit.id)
    }
    
    func getHabit(withId id: UUID) -> Habit? {
        return customHabits.first { $0.id == id }
    }
    
    // MARK: - Utility Methods
    
    func getCustomHabitsCount() -> Int {
        return customHabits.count
    }
    
    func clearAllCustomHabits() {
        customHabits.removeAll()
        
        let fileURL = Self.getFileURL()
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
                print("Successfully deleted all custom habits")
            }
        } catch {
            print("Error deleting custom habits: \(error)")
        }
    }
} 