//
//  Reminders_AppApp.swift
//  Reminders App
//
//

import SwiftUI

@main
struct Reminders_AppApp: App {
    
    let notificationCenter = UNUserNotificationCenter.current()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            
            let context = persistenceController.container.viewContext
            let dateHolder = DateHolder(context)
            
            ReminderListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(dateHolder)
        }
    }
}
