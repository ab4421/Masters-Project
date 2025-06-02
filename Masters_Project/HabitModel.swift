import Foundation
import RoomPlan

enum HabitCategory: String, CaseIterable, Codable {
    case activity = "Activity"
    case diet = "Diet"
    case sleep = "Sleep"
    case custom = "Custom"
}

struct Habit: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let category: HabitCategory
    let associatedObject: String
    let iconName: String
    var associatedFurnitureTypes: [CapturedRoom.Object.Category]
    var associatedFurnitureIndices: [Int] = []
}

// Sample data
extension Habit {
    static let sampleHabits: [Habit] = [
        // Diet & Hydration Habits
        Habit(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
            name: "Consistent Hydration",
            description: "Place your water bottle in the red highlighted surface below within easy reach. Constant visual reminders and easy access make staying hydrated effortless throughout the day!",
            category: .diet,
            associatedObject: "Water Bottle",
            iconName: "drop.fill",
            associatedFurnitureTypes: [.bed, .sofa, .chair],
            associatedFurnitureIndices: []
        ),
        Habit(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
            name: "Healthy Snacking",
            description: "Position your fruit bowl in the red highlighted surface below in your kitchen area. Making healthy options the most visible choice encourages better eating habits!",
            category: .diet,
            associatedObject: "Fruit Bowl",
            iconName: "leaf.fill",
            associatedFurnitureTypes: [.refrigerator, .oven],
            associatedFurnitureIndices: []
        ),
        
        // Physical Activity Habits
        Habit(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
            name: "Daily Movement Cue",
            description: "Keep your yoga block or resistance band set in the red highlighted surface below where you relax. Having them visible reminds you to take movement breaks!",
            category: .activity,
            associatedObject: "Yoga Block Set",
            iconName: "figure.yoga",
            associatedFurnitureTypes: [.television, .sofa],
            associatedFurnitureIndices: []
        ),
        Habit(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440004")!,
            name: "Quick Activity Prep",
            description: "Place your outdoor essentials tray in the red highlighted surface below near your exit. Having keys, sunglasses, and earbuds ready makes leaving for activities effortless!",
            category: .activity,
            associatedObject: "Essentials Tray",
            iconName: "tray.fill",
            associatedFurnitureTypes: [.storage, .fireplace],
            associatedFurnitureIndices: []
        ),
        
        // Sleep Hygiene Habits
        Habit(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440005")!,
            name: "Tech-Free Reading",
            description: "Keep your current book in the red highlighted surface below beside your bed. Having it immediately available makes choosing reading over screen time much easier before sleep!",
            category: .sleep,
            associatedObject: "Physical Book",
            iconName: "book.fill",
            associatedFurnitureTypes: [.bed, .storage],
            associatedFurnitureIndices: []
        ),
        Habit(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440006")!,
            name: "Calming Bedtime Tea",
            description: "Set up your herbal tea canister and favorite mug in the red highlighted surface below near your kitchen water source. Having everything ready makes preparing a calming bedtime routine effortless!",
            category: .sleep,
            associatedObject: "Tea Set",
            iconName: "cup.and.saucer.fill",
            associatedFurnitureTypes: [.sink, .stove],
            associatedFurnitureIndices: []
        )
    ]
    
    /// Returns sample habits with applied user configurations if available
    static func getConfiguredSampleHabits() -> [Habit] {
        let configurationManager = HabitConfigurationManager.shared
        var configuredHabits = sampleHabits
        
        for i in 0..<configuredHabits.count {
            _ = configurationManager.applyConfiguration(to: &configuredHabits[i])
        }
        
        return configuredHabits
    }
    
    /// Returns all habits (sample + custom) with applied configurations
    static func getAllHabits() -> [Habit] {
        let sampleHabits = getConfiguredSampleHabits()
        let customHabits = CustomHabitManager.shared.customHabits
        
        return sampleHabits + customHabits
    }
} 
