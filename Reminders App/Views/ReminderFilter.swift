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
    case NonCompleted = "Scheduled"
    case Completed = "Completed"
    case OverDue = "OverDue"
    
    func filteredReminderItems(items: FetchedResults < ReminderItem>) -> [ReminderItem] {
        switch self {
        case .All:
            return Array(items)
        case .NonCompleted:
            return items.filter { !$0.isCompleted() && !$0.isOverdue() }
        case .Completed:
            return items.filter { $0.isCompleted() }
        case .OverDue:
            return items.filter { $0.isOverdue() }
        }
    }
}


