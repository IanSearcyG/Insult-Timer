//
//  Insult_TimerApp.swift
//  Insult Timer
//
//  Created by Ian Searcy-Gardner on 3/10/24.
//

import SwiftUI
import UserNotifications

@main
struct Insult_TimerApp: App {
    init() {
        // Request notification permissions when the app launches
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permissions granted.")
            } else if let error = error {
                print("Notification permissions error: \(error.localizedDescription)")
            }
        }
    }
    
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
