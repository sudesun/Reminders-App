//
//  ReminderItemExtension.swift
//  Reminders App
//
//  Created by Ekrem Taha SUNGUR on 10.01.2024.
//

import SwiftUI

extension ReminderItem{
    
    func isCompleted() -> Bool{
        
        return completedDate != nil
        
    }
    
    func isOverdue() -> Bool{
        
        if let due = dueDate{
            
            return !isCompleted() && scheduleTime && due < Date()
        }
        
        return false
        
    }
    
    func overDueColor() -> Color{
        
        return isOverdue() ? .red : .black
    }
    
    func dueDateTimeOnly() -> String{
        
        if let due = dueDate{
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            
            return dateFormatter.string(from: due)
        }
        
        return ""
    }
    
}
