//
//  ReminderItemExtension.swift
//  Reminders App
//

import SwiftUI

extension ReminderItem {
    
    var audioURL: URL? {
            get {
                // audioURL için mevcut get mantığını burada bırakın
                // Örneğin:
                return URL(string: audioURLString ?? "")
            }
            set {
                // Yeni bir set mantığı ekleyin
                audioURLString = newValue?.absoluteString
            }
        }
    
    // Ek olarak, audioURLString özelliğini ekleyin
    var audioURLString: String? {
            get {
                // Mevcut audioURLString get mantığını burada bırakın
                return self.audioURL?.absoluteString
            }
            set {
                // Yeni bir set mantığı ekleyin
                if let newValue = newValue {
                    self.audioURL = URL(string: newValue)
                } else {
                    self.audioURL = nil
                }
            }
        }
    
    func isCompleted() -> Bool {
        return completedDate != nil
    }
    
    func isOverdue() -> Bool {
        if let due = dueDate {
            return !isCompleted() && scheduleTime && due < Date()
        }
        return false
    }
    
    func overDueColor() -> Color {
        return isOverdue() ? .red : .black
    }
    
    func dueDateTimeOnly() -> String {
        if let due = dueDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            return dateFormatter.string(from: due)
        }
        return ""
    }
}
