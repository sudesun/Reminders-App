//
//  DateHolder.swift
//  Reminders App
//

import SwiftUI
import CoreData

// DateHolder sınıfı, CoreData context'ini kaydetmek için kullanılır.
class DateHolder: ObservableObject {
    
     // Başlatıcı
    init(_ context: NSManagedObjectContext){
         // İlgili başlatıcı kodları buraya ekleyebilirsiniz.
        
    }
    
     // CoreData context'ini kaydeden işlem
    func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
