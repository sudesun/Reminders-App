//
//  CheckBoxView.swift
//  Reminders App
//
//

import SwiftUI

// CheckBoxView struct'ı, hatırlatıcı durumunu gösteren onay kutusu görünümü
struct CheckBoxView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dateHolder: DateHolder
    @ObservedObject var passedReminderItem: ReminderItem
    
    var body: some View {
        
         // Hatırlatıcı durumuna göre onay kutusu simgesi
        Image(systemName: passedReminderItem.completedDate != nil ? "checkmark.circle.fill" : "circle")
            .foregroundColor(passedReminderItem.isCompleted() ? .green : .secondary)
            .onTapGesture {
                withAnimation{
                    
                    if !passedReminderItem.isCompleted(){
                        
                        passedReminderItem.completedDate = Date()
                        
                    } else {
                        
                        passedReminderItem.completedDate = nil
                    }
                    
                    dateHolder.saveContext(viewContext)
                }
            }
        
    }
}
// Önizleme bölümü
struct CheckBoxView_Previews: PreviewProvider {
    
    static var previews: some View{
        
        CheckBoxView(passedReminderItem: ReminderItem())
    }
    
}
