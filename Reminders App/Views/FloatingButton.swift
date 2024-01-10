//
//  FloatingButton.swift
//  Reminders App
//
//

import SwiftUI

struct FloatingButton: View {
    
    @EnvironmentObject var dateHolder: DateHolder
    
    var body: some View {
        
        VStack{
            
            Spacer()
            HStack {
                
                Spacer()
                NavigationLink(destination: ReminderEditView(passedReminderItem: nil, initialDate: Date()).environmentObject(dateHolder)){
                   
                    Text("+ New Reminder")
                        .font(.headline)
                }
                .padding(15)
                .foregroundColor(.white)
                .background(Color.accentColor)
                .cornerRadius(30)
                .padding(30)
                .shadow(color: .black.opacity(0.3), radius: 3, x:3, y:3)
            }
            
        }
        
        
    }
}

#Preview {
    FloatingButton()
}
