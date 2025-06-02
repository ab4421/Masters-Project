import SwiftUI
import RoomPlan

// Separate view for habit row
struct HabitRow: View {
    let habit: Habit
    let isCustomHabit: Bool
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?
    
    @StateObject private var configurationManager = HabitConfigurationManager.shared
    
    // Computed property for star state
    private var isStarred: Bool {
        configurationManager.isHabitStarred(habit.id)
    }
    
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
            
            Spacer()
            
            // Star indicator (only show if starred)
            if isStarred {
                Image(systemName: "star.fill")
                    .font(.title3)
                    .foregroundColor(.yellow)
            }
            
            if isCustomHabit {
                Menu {
                    Button(action: { onEdit?() }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: { onDelete?() }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
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
    let onEditHabit: ((Habit) -> Void)?
    let onDeleteHabit: ((Habit) -> Void)?
    
    var body: some View {
        Section(header: Text(category.rawValue)) {
            ForEach(habits) { habit in
                NavigationLink(destination: HabitRecommendationView(
                    habit: habit,
                    roomData: roomData,
                    pathPoints: pathPoints
                )) {
                    HabitRow(
                        habit: habit,
                        isCustomHabit: category == .custom,
                        onEdit: { onEditHabit?(habit) },
                        onDelete: { onDeleteHabit?(habit) }
                    )
                }
            }
        }
    }
}

struct HabitSelectionView: View {
    let roomData: CapturedRoom?
    let pathPoints: [PathPoint]
    
    @ObservedObject private var customHabitManager = CustomHabitManager.shared
    @State private var showingCreateHabit = false
    @State private var editingHabit: Habit?
    @State private var showingDeleteAlert = false
    @State private var habitToDelete: Habit?
    
    // Pre-filter habits by category using all habits (sample + custom)
    private var habitsByCategory: [HabitCategory: [Habit]] {
        Dictionary(grouping: Habit.getAllHabits()) { $0.category }
    }
    
    var body: some View {
        List {
            ForEach(HabitCategory.allCases, id: \.self) { category in
                if let habits = habitsByCategory[category], !habits.isEmpty {
                    HabitCategorySection(
                        category: category,
                        habits: habits,
                        roomData: roomData,
                        pathPoints: pathPoints,
                        onEditHabit: { habit in
                            editingHabit = habit
                        },
                        onDeleteHabit: { habit in
                            habitToDelete = habit
                            showingDeleteAlert = true
                        }
                    )
                }
            }
        }
        .navigationTitle("Habit Recommendations")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingCreateHabit = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateHabit) {
            CreateHabitView(roomData: roomData, editingHabit: nil)
        }
        .sheet(item: $editingHabit) { habit in
            CreateHabitView(roomData: roomData, editingHabit: habit)
        }
        .alert("Delete Habit", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { 
                habitToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let habit = habitToDelete {
                    customHabitManager.deleteHabit(habit)
                    // Also remove any saved configurations
                    HabitConfigurationManager.shared.deleteConfiguration(for: habit.id)
                }
                habitToDelete = nil
            }
        } message: {
            if let habit = habitToDelete {
                Text("Are you sure you want to delete '\(habit.name)'? This action cannot be undone.")
            }
        }
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