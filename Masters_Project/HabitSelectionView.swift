import SwiftUI
import RoomPlan

// Separate view for habit row
struct HabitRow: View {
    let habit: Habit
    
    var body: some View {
        HStack {
            Image(systemName: habit.iconName)
                .foregroundColor(.blue)
                .frame(width: 30)
            VStack(alignment: .leading) {
                Text(habit.name)
                    .font(.headline)
                Text(habit.associatedObject)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

// Separate view for category section
struct HabitCategorySection: View {
    let category: HabitCategory
    let habits: [Habit]
    let roomData: CapturedRoom?
    let pathPoints: [PathPoint]
    
    var body: some View {
        Section(header: Text(category.rawValue)) {
            ForEach(habits) { habit in
                NavigationLink(destination: HabitRecommendationView(
                    habit: habit,
                    roomData: roomData,
                    pathPoints: pathPoints
                )) {
                    HabitRow(habit: habit)
                }
            }
        }
    }
}

struct HabitSelectionView: View {
    let roomData: CapturedRoom?
    let pathPoints: [PathPoint]
    
    // Pre-filter habits by category
    private var habitsByCategory: [HabitCategory: [Habit]] {
        Dictionary(grouping: Habit.sampleHabits) { $0.category }
    }
    
    var body: some View {
        List {
            ForEach(HabitCategory.allCases, id: \.self) { category in
                if let habits = habitsByCategory[category] {
                    HabitCategorySection(
                        category: category,
                        habits: habits,
                        roomData: roomData,
                        pathPoints: pathPoints
                    )
                }
            }
        }
        .navigationTitle("Habit Recommendations")
    }
}

#Preview {
    NavigationView {
        HabitSelectionView(
            roomData: nil as CapturedRoom?,
            pathPoints: []
        )
    }
} 