import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // Notification identifiers for each time slot
    private let firstReminderID = "habit_reminder_18_00"
    private let secondReminderID = "habit_reminder_20_00"
    private let thirdReminderID = "habit_reminder_22_00"
    
    private override init() {}
    
    // MARK: - Permission Management
    
    func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
                DispatchQueue.main.async {
                    self.scheduleAllNotifications()
                }
            } else {
                print("Notification permission denied")
            }
            
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    // MARK: - Notification Scheduling
    
    func scheduleAllNotifications() {
        // Cancel any existing notifications first
        cancelAllNotifications()
        
        // Schedule the three daily reminders
        scheduleNotification(at: (18, 0), identifier: firstReminderID, title: "Daily Check-in Reminder", body: "Don't forget to complete your habit checklist and wellbeing survey today!")
        
        scheduleNotification(at: (20, 0), identifier: secondReminderID, title: "Daily Check-in Reminder", body: "Haven't completed your daily entries yet? Take a moment to fill them out now!")
        
        scheduleNotification(at: (22, 0), identifier: thirdReminderID, title: "Last Chance - Daily Check-in", body: "Final reminder: Complete your habit checklist and wellbeing survey before the day ends!")
    }
    
    private func scheduleNotification(at time: (hour: Int, minute: Int), identifier: String, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        // Create date components for the notification time
        var dateComponents = DateComponents()
        dateComponents.hour = time.hour
        dateComponents.minute = time.minute
        
        // Create trigger that repeats daily
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Add to notification center
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification \(identifier): \(error)")
            } else {
                print("Successfully scheduled notification for \(time.hour):\(String(format: "%02d", time.minute))")
            }
        }
    }
    
    // MARK: - Notification Management
    
    func cancelAllNotifications() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [
            firstReminderID,
            secondReminderID,
            thirdReminderID
        ])
    }
    
    func checkAndCancelNotificationsIfNeeded() {
        let today = getTodayDateString()
        let todayEntry = DataManager.shared.userData.dailyEntries[today]
        
        // Check if both habit checklist and RENSS are completed
        let habitCompleted = todayEntry?.habitEntry != nil
        let renssCompleted = todayEntry?.wellbeingEntry != nil
        
        if habitCompleted && renssCompleted {
            // Both completed - cancel today's remaining notifications
            cancelTodaysRemainingNotifications()
        }
    }
    
    private func cancelTodaysRemainingNotifications() {
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        
        var notificationsToCancel: [String] = []
        
        // Cancel notifications that haven't fired yet today
        if currentHour < 18 {
            notificationsToCancel.append(contentsOf: [firstReminderID, secondReminderID, thirdReminderID])
        } else if currentHour < 20 {
            notificationsToCancel.append(contentsOf: [secondReminderID, thirdReminderID])
        } else if currentHour < 22 {
            notificationsToCancel.append(thirdReminderID)
        }
        
        if !notificationsToCancel.isEmpty {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: notificationsToCancel)
            print("Cancelled remaining notifications for today: \(notificationsToCancel)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func getTodayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    // MARK: - Debug/Testing Methods
    
    func getPendingNotifications() {
        notificationCenter.getPendingNotificationRequests { requests in
            print("=== Pending Notifications ===")
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    let components = trigger.dateComponents
                    print("ID: \(request.identifier)")
                    print("Time: \(components.hour ?? 0):\(String(format: "%02d", components.minute ?? 0))")
                    print("Title: \(request.content.title)")
                    print("Body: \(request.content.body)")
                    print("---")
                }
            }
            print("Total: \(requests.count) notifications")
        }
    }
    
    func getCompletionStatus() {
        let today = getTodayDateString()
        let todayEntry = DataManager.shared.userData.dailyEntries[today]
        
        let habitCompleted = todayEntry?.habitEntry != nil
        let renssCompleted = todayEntry?.wellbeingEntry != nil
        
        print("=== Today's Completion Status ===")
        print("Date: \(today)")
        print("Habit Checklist: \(habitCompleted ? "✅ Completed" : "❌ Not completed")")
        print("RENSS Survey: \(renssCompleted ? "✅ Completed" : "❌ Not completed")")
        print("Both Complete: \(habitCompleted && renssCompleted ? "✅ Yes" : "❌ No")")
    }
    
    // MARK: - App Lifecycle Methods
    
    func handleAppDidBecomeActive() {
        // Check completion status when app becomes active
        checkAndCancelNotificationsIfNeeded()
    }
    
    func handleAppWillResignActive() {
        // Update badge count when app goes to background
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().setBadgeCount(0) { error in
                if let error = error {
                    print("Error setting badge count: \(error)")
                }
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Check if both tasks are completed before showing notification
        let today = getTodayDateString()
        let todayEntry = DataManager.shared.userData.dailyEntries[today]
        
        let habitCompleted = todayEntry?.habitEntry != nil
        let renssCompleted = todayEntry?.wellbeingEntry != nil
        
        if habitCompleted && renssCompleted {
            // Both completed - don't show notification
            completionHandler([])
        } else {
            // Show notification with all options
            completionHandler([.banner, .sound, .badge])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification tap - could deep link to specific screens in the future
        print("User tapped notification: \(response.notification.request.identifier)")
        completionHandler()
    }
} 