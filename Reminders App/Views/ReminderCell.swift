//
//  ReminderCell.swift
//  Reminders App
//
//

import SwiftUI
import CoreData

// ReminderCell struct'ı, hatırlatıcı öğesini liste görünümünde temsil eder
struct ReminderCell: View {
    
    @EnvironmentObject var dateHolder: DateHolder
    @ObservedObject var passedReminderItem: ReminderItem

    
    var body: some View {
        
        HStack{
            
             // CheckBoxView ile hatırlatıcı durumu gösterilir
            CheckBoxView(passedReminderItem: passedReminderItem)
                .environmentObject(dateHolder)
            
             // Hatırlatıcı öğesinin adı ve açıklamasını içeren diğer bilgiler
            VStack(alignment: .leading){
                Text(passedReminderItem.name ??  "")
                    .padding(.horizontal)
                    .foregroundColor(priorityColor())
                   
                 // Hatırlatıcı öğesinin açıklaması (varsa)
                if let desc = passedReminderItem.desc, !desc.isEmpty {
                    Text(desc)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
            }
            
             // Eğer hatırlatıcı tamamlanmadıysa ve bir tarih varsa, tarih gösterilir
            if !passedReminderItem.isCompleted() && passedReminderItem.scheduleTime{
                
                Spacer()
                Text(passedReminderItem.dueDateTimeOnly())
                    .font(.footnote)
                    .foregroundColor(passedReminderItem.overDueColor())
                    .padding(.horizontal)
            }
            
        }
        
    }
     // Hatırlatıcı öğesinin öncelik rengini belirler
     func priorityColor() ->  Color {
          switch passedReminderItem.priority {
          case "Low":
               return .yellow
          case "Medium":
               return .blue
          case "High":
               return .red
          default:
               return .black
          }
     }
}
// Önizleme bölümü
struct ReminderCell_Previews: PreviewProvider {
    static var previews: some View{
        
        ReminderCell(passedReminderItem: ReminderItem())
        
    }
    
}
