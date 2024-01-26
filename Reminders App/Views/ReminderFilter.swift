//
//  ReminderFilter.swift
//  Reminders App
//
//

import SwiftUI

// ReminderFilter enum'ı, hatırlatıcıları filtrelemek için kullanılır.
enum ReminderFilter: String{
    
     // Tüm filtre türlerini içeren statik dizi
    static var allFilters: [ReminderFilter] {
        
        return [.NonCompleted, .Completed, .OverDue, .All]
    }
    
     // Filtreleme türleri
    case All = "All"
    case NonCompleted = "Scheduled"
    case Completed = "Completed"
    case OverDue = "OverDue"
    
     // Belirtilen filtre türüne göre hatırlatıcı öğelerini filtreler
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
