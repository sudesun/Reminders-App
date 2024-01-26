//
//  ReminderFilter.swift
//  Reminders App
//
//

import SwiftUI

enum ReminderFilter: String{
    
    static var allFilters: [ReminderFilter] {
        
        return [.NonCompleted, .Completed, .OverDue, .All]
    }
    
    case All = "All"
    case NonCompleted = "Remind"
    case Completed = "Completed"
    case OverDue = "OverDue"
}

