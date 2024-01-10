//
//  Reminders_AppApp.swift
//  Reminders App
//
//

import SwiftUI
import CoreData
import UserNotifications
import AVFoundation

@main
struct Reminders_AppApp: App {

    let persistenceController = PersistenceController.shared
    var player: AVAudioPlayer?
    
    init() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge] ) { granted, error in
        
            if granted {
                print ("Bildirim izni verildi.")
            } else if let error = error {
                print ("Bildirim izni hatası: \(error.localizedDescription)")
            }
        }
        
      
    }

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
