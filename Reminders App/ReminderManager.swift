//
//  ReminderManager.swift
//  Reminders App
//
//

import UserNotifications
import AVFoundation

class ReminderManager {
    var audioPlayer: AVAudioPlayer?
    var motionManager = MotionManager()
    
    
    func scheduleNotification(for reminderItem: ReminderItem) {
        
        let content = UNMutableNotificationContent()
        content.title = reminderItem.name ?? "Hatırlatıcı "
        
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
    
    func scheduleAlert (for reminderItem: ReminderItem, minutesBefore: Int){
        
        if minutesBefore > 0 {
            let alertTriggerTime = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: reminderItem.dueDate!)!
            let alertTriggerTimeComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: alertTriggerTime)
            let alertTrigger = UNCalendarNotificationTrigger(dateMatching: alertTriggerTimeComponents, repeats: false)
            
            let content = UNMutableNotificationContent()
            content.title = "Reminder: \(reminderItem.name ?? "")"
            content.body = "Your reminder is approaching!"
            
            let alertRequest = UNNotificationRequest(identifier: "(reminderItem.id!)-alert", content: content, trigger: alertTrigger)
            
            UNUserNotificationCenter.current().add(alertRequest) { error in
                if let error = error {
                    print("Error scheduling alert notification: \(error.localizedDescription)")
                }else {
                    print("Alert scheduled succesfully.")
                }
            }
        }
    }
    
    func playAlarmSound(onDeviceMove: @escaping() -> Void) {
        guard let path = Bundle.main.path(forResource: "alarm_sound", ofType: "mp3") else { return }
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            motionManager.onDeviceMove = {
                onDeviceMove()
                self.stopAlarm()
            }
            motionManager.stopMotionUpdates()
        } catch {
            print("Ses dosyası çalma hatası: \(error.localizedDescription)")
        }
    }
    
    func stopAlarm() {
        audioPlayer?.stop()
    }
}
