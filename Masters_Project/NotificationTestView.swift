import SwiftUI

struct NotificationTestView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showingPermissionAlert = false
    @State private var notificationStatus = "Unknown"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Notification Status Section
                    GroupBox("Notification Status") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Current Status: \(notificationStatus)")
                                .font(.subheadline)
                            
                            Button("Check Permission Status") {
                                checkNotificationStatus()
                            }
                            .buttonStyle(.bordered)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Completion Status Section
                    GroupBox("Today's Completion") {
                        VStack(alignment: .leading, spacing: 8) {
                            let todayEntry = dataManager.getTodayEntry()
                            let habitCompleted = todayEntry?.habitEntry != nil
                            let renssCompleted = todayEntry?.wellbeingEntry != nil
                            
                            HStack {
                                Image(systemName: habitCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(habitCompleted ? .green : .gray)
                                Text("Habit Checklist")
                            }
                            
                            HStack {
                                Image(systemName: renssCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(renssCompleted ? .green : .gray)
                                Text("RENSS Survey")
                            }
                            
                            if habitCompleted && renssCompleted {
                                Text("✅ Both completed - Notifications should be cancelled")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            } else {
                                Text("⏰ Pending completion - Notifications active")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Debug Actions Section
                    GroupBox("Debug Actions") {
                        VStack(spacing: 12) {
                            Button("Print Pending Notifications") {
                                NotificationManager.shared.getPendingNotifications()
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Print Completion Status") {
                                NotificationManager.shared.getCompletionStatus()
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Cancel All Notifications") {
                                NotificationManager.shared.cancelAllNotifications()
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Reschedule All Notifications") {
                                NotificationManager.shared.scheduleAllNotifications()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    
                    // Test Data Section
                    GroupBox("Test Data (Development Only)") {
                        VStack(spacing: 12) {
                            Button("Add Test Habit Entry") {
                                dataManager.saveHabitEntry(habitCompleted: true, objectsInPlace: true)
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Add Test RENSS Entry") {
                                let testAnswers = Array(repeating: 3, count: 12) // All neutral responses
                                dataManager.saveWellbeingEntry(answers: testAnswers)
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Clear Today's Data") {
                                clearTodaysData()
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(.red)
                        }
                    }
                    
                    // Info Section
                    GroupBox("Notification Schedule") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("📅 Daily Reminders:")
                                .font(.headline)
                            
                            HStack {
                                Image(systemName: "clock")
                                Text("18:00 - First reminder")
                            }
                            
                            HStack {
                                Image(systemName: "clock")
                                Text("20:00 - Second reminder")
                            }
                            
                            HStack {
                                Image(systemName: "clock")
                                Text("22:00 - Final reminder")
                            }
                            
                            Text("\n💡 Notifications will only show if both habit checklist AND RENSS survey are not completed for the day.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            .navigationTitle("Notification Testing")
            .onAppear {
                checkNotificationStatus()
            }
        }
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    notificationStatus = "✅ Authorized"
                case .denied:
                    notificationStatus = "❌ Denied"
                case .notDetermined:
                    notificationStatus = "❓ Not Determined"
                case .provisional:
                    notificationStatus = "⚠️ Provisional"
                case .ephemeral:
                    notificationStatus = "⏱️ Ephemeral"
                @unknown default:
                    notificationStatus = "❓ Unknown"
                }
            }
        }
    }
    
    private func clearTodaysData() {
        let today = getTodayDateString()
        dataManager.userData.dailyEntries.removeValue(forKey: today)
        // Trigger a save to persist the change
        dataManager.objectWillChange.send()
    }
    
    private func getTodayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

#Preview {
    NotificationTestView()
} 