//
//  Masters_ProjectApp.swift
//  Masters_Project
//
//  Created by Arnav Bhatia on 08/05/2025.
//

import SwiftUI
import UserNotifications

@main
struct Masters_ProjectApp: App {
    
    init() {
        // Initialize notification system on app launch
        setupNotifications()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    NotificationManager.shared.handleAppDidBecomeActive()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    NotificationManager.shared.handleAppWillResignActive()
                }
        }
    }
    
    private func setupNotifications() {
        // Set the notification manager as delegate
        UNUserNotificationCenter.current().delegate = NotificationManager.shared
        
        // Request notification permissions
        NotificationManager.shared.requestNotificationPermission()
    }
}
