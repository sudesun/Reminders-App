//
//  ReminderManager.swift
//  Reminders App
//
//

import UserNotifications
import AVFoundation

class ReminderManager {
    var audioPlayer: AVAudioPlayer?
    
    
    func scheduleNotification(for reminderItem: ReminderItem) {
        
        let content = UNMutableNotificationContent()
        content.title = reminderItem.name ?? "Hatırlatıcı"
        
        if let desc = reminderItem.desc, !desc.isEmpty {
            content.body = desc
            
        }
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderItem.dueDate ?? Date())
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) {error in
                    if let error = error {
                        
                        print("Bildirim hatası: \(error.localizedDescription)")
                    }
            }
    }
    
    func playAlarmSound() {
        guard let path = Bundle.main.path(forResource: "alarm_sound", ofType: "mp3") else { return }
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Ses dosyası çalma hatası: \(error.localizedDescription)")
        }
    }
}
