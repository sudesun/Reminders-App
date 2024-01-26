//
//  ReminderManager.swift
//  Reminders App
//
//

import UserNotifications
import AVFoundation

// ReminderManager sınıfı, bildirimleri yönetir ve alarm sesini çalar.
class ReminderManager {
    var audioPlayer: AVAudioPlayer?
    var motionManager = MotionManager()
    
     // Alert string'inden önceki dakikayı alır
     func getMinutesBefore(from alertString: String?) -> Int {
          guard let alertString = alertString,
                let minutes = Int(alertString.components(separatedBy: " ").first ?? "") else {
              return 0 // Varsayılan olarak 0 dakika
          }
          return minutes
      }
     
     // Hatırlatıcı için bildirimi planlar
     func scheduleNotification(for reminderItem: ReminderItem) {
             // Hatırlatma tarihine ve önceki dakikalara bağlı olarak tetikleyiciyi ayarla
             if let dueDate = reminderItem.dueDate {
                 let triggerDate = dueDate.addingTimeInterval(-TimeInterval(getMinutesBefore(from: reminderItem.alert) * 60))
                 let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
                 let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

                 // Bildirimi oluşturun ve tetikleyici ile birlikte planlayın
                 let content = UNMutableNotificationContent()
                 content.title = reminderItem.name ?? "Hatırlatıcı"
                 if let desc = reminderItem.desc, !desc.isEmpty {
                     content.body = desc
                 }
                  content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Poco.mp3"))

                 let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                 UNUserNotificationCenter.current().add(request) { error in
                     if let error = error {
                         print("Bildirim hatası: \(error.localizedDescription)")
                     } else {
                         print("Bildirim başarıyla planlandı.")
                     }
                 }
             }
         }
     
            
     // Alert için bildirimi planlar
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
    
     // Alarm sesini durdurur
    func stopAlarm() {
        audioPlayer?.stop()
    }
}
