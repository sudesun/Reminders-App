//
//  ReminderCell.swift
//  Reminders App
//
//

import SwiftUI

struct ReminderCell: View {
    
    @EnvironmentObject var dateHolder: DateHolder
    @ObservedObject var passedReminderItem: ReminderItem
    
    var body: some View {
        
        HStack{
            
            CheckBoxView(passedReminderItem: passedReminderItem)
                .environmentObject(dateHolder)
            
            Text(passedReminderItem.name ?? "")
                .padding(.horizontal)
            
            if !passedReminderItem.isCompleted() && passedReminderItem.scheduleTime{
                
                Spacer()
                Text(passedReminderItem.dueDateTimeOnly())
                    .font(.footnote)
                    .foregroundColor(passedReminderItem.overDueColor())
                    .padding(.horizontal)
            }
            
        }
        
    }
}

struct ReminderCell_Previews: PreviewProvider {
    static var previews: some View{
        
        ReminderCell(passedReminderItem: ReminderItem())
        
    }
    
}
