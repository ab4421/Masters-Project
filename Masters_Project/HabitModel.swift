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
    let associatedFurnitureTypes: [CapturedRoom.Object.Category]
}

// Sample data
extension Habit {
    static let sampleHabits: [Habit] = [
        Habit(
            name: "Drink More Water",
            description: "Place your water bottle in the location highlighted below in your room. Staying hydrated boosts your energy and focus!",
            category: .activity,
            associatedObject: "Water Bottle",
            iconName: "drop.fill",
            associatedFurnitureTypes: [.bed, .chair, .sofa]
        ),
        Habit(
            name: "Take Regular Breaks",
            description: "Set a timer in the spot highlighted below to remind yourself to take breaks. Regular breaks help you stay productive and reduce stress!",
            category: .activity,
            associatedObject: "Timer",
            iconName: "timer",
            associatedFurnitureTypes: [.chair, .sofa]
        ),
        Habit(
            name: "Healthy Snacks",
            description: "Get a container of healthy fruits and place it in the highlighted location below. Nutritious snacks keep your mind sharp and your body fueled!",
            category: .diet,
            associatedObject: "Snack Container",
            iconName: "leaf.fill",
            associatedFurnitureTypes: [.oven]
        ),
        Habit(
            name: "Sleep Schedule",
            description: "Put your phone charger in the highlighted spot below, away from your bed. This helps you avoid late-night screen time and improves your sleep quality!",
            category: .sleep,
            associatedObject: "Phone Charger",
            iconName: "moon.fill",
            associatedFurnitureTypes: [.bed]
        )
    ]
} 