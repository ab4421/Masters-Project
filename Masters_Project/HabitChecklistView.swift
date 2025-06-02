import SwiftUI

struct HabitChecklistView: View {
    @State private var isHabitCompleted: Bool = false
    @State private var areObjectsInPlace: Bool = false
    @State private var showSaveConfirmation: Bool = false
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var configurationManager = HabitConfigurationManager.shared
    @StateObject private var roomDataManager = RoomDataManager.shared
    
    // Get current date in the format: Tuesday, 20th May 2025
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d'th' MMMM yyyy"
        let calendar = Calendar.current
        let day = calendar.component(.day, from: Date())
        let suffix: String
        switch day {
        case 1, 21, 31: suffix = "st"
        case 2, 22: suffix = "nd"
        case 3, 23: suffix = "rd"
        default: suffix = "th"
        }
        formatter.dateFormat = "EEEE, d'\(suffix)' MMMM yyyy"
        let dateString = formatter.string(from: Date()).replacingOccurrences(of: "\\(suffix)", with: suffix)
        return dateString
    }
    
    private let motivationalMessage = "Keep up the great work and stay consistent with your habit!"
    
    // Check if data exists for today
    private var hasDataForToday: Bool {
        dataManager.getTodayEntry()?.habitEntry != nil
    }
    
    // Get starred habit
    private var starredHabit: Habit? {
        configurationManager.getStarredHabit()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Date and Motivation
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today is \(formattedDate)!")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text(motivationalMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                .padding(.horizontal)
                
                // Starred Habit Section
                if let starred = starredHabit {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.title3)
                            Text("Current Focus Habit")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: starred.iconName)
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .frame(width: 40, height: 40)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(starred.name)
                                        .font(.title3)
                                        .fontWeight(.medium)
                                    Text(starred.associatedObject)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            
                            NavigationLink(destination: destinationView(for: starred)) {
                                HStack {
                                    Image(systemName: "location.circle.fill")
                                    Text("View Placement Guide")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                } else {
                    // No starred habit message
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "star")
                                .foregroundColor(.gray)
                                .font(.title3)
                            Text("No Focus Habit Selected")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        Text("Star a habit from the recommendations to track it here!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Data Status Indicator
                if hasDataForToday {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Habit data submitted for today")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
                
                // Habit Checklist
                VStack(alignment: .leading, spacing: 16) {
                    // Habit Completion Checkbox
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: isHabitCompleted ? "checkmark.square.fill" : "square")
                            .foregroundColor(isHabitCompleted ? .green : .gray)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Habit Completed")
                                .font(.body)
                                .foregroundColor(.primary)
                            Text("Did you complete your habit today?")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .onTapGesture {
                        isHabitCompleted.toggle()
                    }
                    
                    // Objects in Place Checkbox
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: areObjectsInPlace ? "checkmark.square.fill" : "square")
                            .foregroundColor(areObjectsInPlace ? .green : .gray)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Objects in Place")
                                .font(.body)
                                .foregroundColor(.primary)
                            Text("Are the objects for this habit in their recommended place?")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .onTapGesture {
                        areObjectsInPlace.toggle()
                    }
                    
                    // Submit Button
                    Button(action: submitHabitData) {
                        HStack {
                            Image(systemName: hasDataForToday ? "arrow.clockwise" : "checkmark")
                            Text(hasDataForToday ? "Update Today's Data" : "Submit")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .font(.headline)
                    }
                    .padding(.top)
                }
                .padding(.horizontal)
                
                // Navigation to Data Export View
                NavigationLink(destination: DataExportView()) {
                    Text("See Saved Data")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .font(.headline)
                }
                .padding(.horizontal)
                .padding(.top, 8) // Add some space above this button
                
                Spacer(minLength: 0)
            }
            .padding(.bottom)
        }
        .navigationTitle("Habit Checklist")
        .onAppear {
            loadTodayData()
        }
        .alert("Data Saved!", isPresented: $showSaveConfirmation) {
            Button("OK") { }
        } message: {
            Text(hasDataForToday ? "Your habit data has been updated for today." : "Your habit data has been saved for today.")
        }
    }
    
    // MARK: - Functions
    
    private func submitHabitData() {
        dataManager.saveHabitEntry(
            habitCompleted: isHabitCompleted,
            objectsInPlace: areObjectsInPlace
        )
        showSaveConfirmation = true
    }
    
    private func loadTodayData() {
        if let todayEntry = dataManager.getTodayEntry(),
           let habitEntry = todayEntry.habitEntry {
            isHabitCompleted = habitEntry.habitCompleted
            areObjectsInPlace = habitEntry.objectsInPlace
        }
    }
    
    // MARK: - Helper Methods
    
    @ViewBuilder
    private func destinationView(for habit: Habit) -> some View {
        HabitRecommendationView(
            habit: habit,
            roomData: roomDataManager.currentRoom,
            pathPoints: roomDataManager.currentPathPoints
        )
        .onAppear {
            // Same loading logic as ContentView - load room data if we have persisted data but it's not in memory
            if roomDataManager.hasPersistedRoom && !roomDataManager.isRoomDataInMemory() {
                roomDataManager.loadRoomData()
            }
        }
    }
}

#Preview {
    NavigationView {
        HabitChecklistView()
    }
} 