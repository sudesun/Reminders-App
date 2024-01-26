//
//  ReminderItemExtension.swift
//  Reminders App
//

import SwiftUI

// ReminderItem sınıfına eklenen yardımcı işlevler
extension ReminderItem{
    
     // Hatırlatıcı tamamlandı mı kontrolü
    func isCompleted() -> Bool{
        
        return completedDate != nil
        
    }
    
     // Hatırlatıcı süresi geçti mi kontrolü
    func isOverdue() -> Bool{
        
        if let due = dueDate{
            
            return !isCompleted() && scheduleTime && due < Date()
        }
        
        return false
        
    }
    
     // Süresi geçmiş hatırlatıcıların renk kontrolü
    func overDueColor() -> Color{
        
        return isOverdue() ? .red : .black
    }
    
     // Hatırlatıcının sadece saat ve dakikasını döndüren işlev
    func dueDateTimeOnly() -> String{
        
        if let due = dueDate{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm : a"
            
            return dateFormatter.string(from: due)
        }
        
        return ""
    }
    
    
}
