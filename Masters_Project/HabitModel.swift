import Foundation
import RoomPlan

enum HabitCategory: String, CaseIterable {
    case activity = "Activity"
    case diet = "Diet"
    case sleep = "Sleep"
}

struct Habit: Identifiable {
    let id = UUID()
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
        Habit(
            name: "Drink More Water",
            description: "Place your water bottle in the red highlighted surface below in your room. Staying hydrated boosts your energy and focus!",
            category: .activity,
            associatedObject: "Water Bottle",
            iconName: "drop.fill",
            associatedFurnitureTypes: [.bed, .chair, .sofa],
            associatedFurnitureIndices: []
        ),
        Habit(
            name: "Take Regular Breaks",
            description: "Set a timer in the red highlighted surface below to remind yourself to take breaks. Regular breaks help you stay productive and reduce stress!",
            category: .activity,
            associatedObject: "Timer",
            iconName: "timer",
            associatedFurnitureTypes: [.chair, .sofa],
            associatedFurnitureIndices: []
        ),
        Habit(
            name: "Healthy Snacks",
            description: "Get a container of healthy fruits and place it in the red highlighted surface below. Nutritious snacks keep your mind sharp and your body fueled!",
            category: .diet,
            associatedObject: "Snack Container",
            iconName: "leaf.fill",
            associatedFurnitureTypes: [.oven],
            associatedFurnitureIndices: []
        ),
        Habit(
            name: "Sleep Schedule",
            description: "Put your phone charger in the red highlighted surface below, away from your bed. This helps you avoid late-night screen time and improves your sleep quality!",
            category: .sleep,
            associatedObject: "Phone Charger",
            iconName: "moon.fill",
            associatedFurnitureTypes: [.bed],
            associatedFurnitureIndices: []
        )
    ]
} 