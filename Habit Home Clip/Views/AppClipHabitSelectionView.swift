import SwiftUI
import RoomPlan

// Separate view for habit row
struct AppClipHabitRow: View {
    let habit: Habit
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?
    
    @StateObject private var configurationManager = AppClipConfigurationManager.shared
    
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
            
            // App Clip: No custom habit management needed
        }
        .padding(.vertical, 4)
    }
}

// Separate view for category section
struct AppClipHabitCategorySection: View {
    let category: HabitCategory
    let habits: [Habit]
    let roomData: CapturedRoom?
    let pathPoints: [PathPoint]
    
    var body: some View {
        Section(header: Text(category.rawValue)) {
            ForEach(habits) { habit in
                NavigationLink(destination: AppClipHabitRecommendationView(
                    habit: habit,
                    roomData: roomData,
                    pathPoints: pathPoints
                )) {
                    AppClipHabitRow(
                        habit: habit,
                        onEdit: nil, // No editing in App Clip
                        onDelete: nil // No deletion in App Clip
                    )
                }
            }
        }
    }
}

struct AppClipHabitSelectionView: View {
    let roomData: CapturedRoom?
    let pathPoints: [PathPoint]
    
    // Pre-filter habits by category using sample habits only
    private var habitsByCategory: [HabitCategory: [Habit]] {
        Dictionary(grouping: Habit.getAllHabits()) { $0.category }
    }
    
    var body: some View {
        List {
            // Add App Clip header section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "app.badge")
                            .foregroundColor(.blue)
                        Text("App Clip Preview")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    
                    Text("Try our habit recommendation system with a sample room. Download the full app to scan your own space and create custom habits.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Button(action: {
                        // Open App Store for full app
                        if let url = URL(string: "https://testflight.apple.com/join/QFxE86b8") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Text("Get Full App")
                            Image(systemName: "arrow.up.right")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 8)
            }
            
            ForEach(HabitCategory.allCases, id: \.self) { category in
                // Skip custom category in App Clip
                if category != .custom {
                    if let habits = habitsByCategory[category], !habits.isEmpty {
                        AppClipHabitCategorySection(
                            category: category,
                            habits: habits,
                            roomData: roomData,
                            pathPoints: pathPoints
                        )
                    }
                }
            }
        }
        .navigationTitle("Select a Habit")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Show info about App Clip
                    showAppClipInfo()
                }) {
                    Image(systemName: "info.circle")
                }
            }
        }
    }
    
    private func showAppClipInfo() {
        // Present info modal about App Clip functionality
        // This could be implemented as a sheet or alert
        print("Show App Clip info")
    }
}

#Preview {
    NavigationView {
        AppClipHabitSelectionView(
            roomData: nil as CapturedRoom?,
            pathPoints: []
        )
    }
} 
