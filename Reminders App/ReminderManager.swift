//
//  ReminderManager.swift
//  Reminders App
//
//

import SwiftUI
import CoreData
import UserNotifications
import AVFoundation

class ReminderManager{
    
    static let instance = ReminderManager()
    
    func requestAuthorization() {
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
    }
    
    static func scheduleNotification(){
        
    
      
    }
    
    
    
}
