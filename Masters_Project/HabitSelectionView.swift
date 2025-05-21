import SwiftUI
import RoomPlan

struct HabitSelectionView: View {
    let roomData: CapturedRoom?
    @State private var selectedHabit: Habit?
    
    var body: some View {
        List {
            ForEach(HabitCategory.allCases, id: \.self) { category in
                Section(header: Text(category.rawValue)) {
                    ForEach(Habit.sampleHabits.filter { $0.category == category }) { habit in
                        NavigationLink(destination: HabitRecommendationView(habit: habit, roomData: roomData)) {
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
                }
            }
        }
        .navigationTitle("Habit Recommendations")
    }
}

#Preview {
    NavigationView {
        HabitSelectionView(roomData: nil as CapturedRoom?)
    }
} 