//
//  ReminderEditView.swift
//  Reminders App
//
//

import SwiftUI

struct ReminderEditView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dateHolder: DateHolder
    
    @State var selectedReminderItem: ReminderItem?
    @State var name: String
    @State var desc: String
    @State var dueDate: Date
    @State var scheduleTime: Bool
    
    init(passedReminderItem: ReminderItem?, initialDate: Date){
        
        if let reminderItem = passedReminderItem{
            
            _selectedReminderItem = State(initialValue: reminderItem)
            
            _name  = State(initialValue: reminderItem.name ?? "")
            _desc  = State(initialValue: reminderItem.desc ?? "")
            _dueDate  = State(initialValue: reminderItem.dueDate ?? initialDate)
            _scheduleTime  = State(initialValue: reminderItem.scheduleTime)
        }
        else {
            _name  = State(initialValue: "")
            _desc  = State(initialValue: "")
            _dueDate  = State(initialValue: initialDate)
            _scheduleTime  = State(initialValue: false)
        }
    }
    
    var body: some View {
        
        Form{
            
            Section(header: Text("Reminder ")){
                
                TextField("Reminder Name", text: $name)
                TextField("Desc", text: $desc)
            }
            
            Section(header: Text("Due Date")){
                
                Toggle("Schedule Time", isOn: $scheduleTime)
                DatePicker("Due Date", selection: $dueDate, displayedComponents: displayComps())
            }
            
            if selectedReminderItem?.isCompleted() ?? false{
                
                Section(header: Text("Completed")){
                    
                    Text(selectedReminderItem?.completedDate?.formatted(date: .abbreviated, time: .shortened) ?? "")
                        .foregroundStyle(.green)
                }
                
            }
            
            Section(){
                Button("Save", action: saveAction)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

        }
    }
    
    func displayComps() -> DatePickerComponents{
        
        return scheduleTime ? [.hourAndMinute, .date] : [.date]
    }
    
    func saveAction(){
        
        withAnimation{
            if selectedReminderItem == nil {
                
                selectedReminderItem = ReminderItem(context: viewContext)
            }
            
            selectedReminderItem?.created = Date()
            selectedReminderItem?.name = name
            selectedReminderItem?.desc = desc.isEmpty ? nil : desc
            selectedReminderItem?.dueDate = dueDate
            selectedReminderItem?.scheduleTime = scheduleTime
            
            dateHolder.saveContext(viewContext)
            self.presentationMode.wrappedValue.dismiss()
            
            let reminderManager = ReminderManager()
            reminderManager.scheduleNotification(for: selectedReminderItem!)
            reminderManager.playAlarmSound()
        }
        
    }
}

struct ReminderEditView_Previews: PreviewProvider {
    
    static var previews: some View{
        ReminderEditView(passedReminderItem: ReminderItem(), initialDate: Date())
    }
}
