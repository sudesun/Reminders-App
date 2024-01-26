
//
//  Reminders_AppApp.swift
//  Reminders App
//
//

import SwiftUI
import CoreData
import UserNotifications
import AVFoundation

// Uygulama ana struct'ı
@main
struct Reminders_AppApp: App {

     // CoreData bağlantısını sağlayan persistenceController
    let persistenceController = PersistenceController.shared
    var player: AVAudioPlayer?
    
     // Uygulama başlatılırken yapılan işlemler
     init() {
        
          // Kullanıcıya bildirim izni isteği gönderilir
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge] ) { granted, error in
        
            if granted {
                print ("Bildirim izni verildi")
            } else if let error = error {
                print ("Bildirim izni hatası: \(error.localizedDescription)")
            }
        }
        
      
    }

     // Uygulama ana pencere oluşturulur
    var body: some Scene {
        WindowGroup {
            
             // CoreData bağlamını ve tarih tutucu nesnesini alır
            let context = persistenceController.container.viewContext
            let dateHolder = DateHolder(context)
            
             // Ana hatırlatıcı listesi görünümü
            ReminderListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(dateHolder)
        }
    }
}
