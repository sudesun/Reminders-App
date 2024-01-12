//
//  ReminderEditView.swift
//  Reminders App
//
//

import SwiftUI
import AVFoundation
import MobileCoreServices


struct ReminderEditView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dateHolder: DateHolder
    
    
    @State var selectedReminderItem: ReminderItem?
    @State var name: String
    @State var desc: String
    @State var dueDate: Date
    @State var scheduleTime: Bool
    @State var priority: String
    @State var alert: String
    
    @State private var selectedAudioURL: URL?
    
    @State private var alertMinutes: Int = 5
    @State private var showAlertOptions: Bool = false
    
    
    
    init(passedReminderItem: ReminderItem?, initialDate: Date){
        
        if let reminderItem = passedReminderItem{
            
            _selectedReminderItem = State(initialValue: reminderItem)
            
            _name  = State(initialValue: reminderItem.name ?? "")
            _desc  = State(initialValue: reminderItem.desc ?? "")
            _dueDate  = State(initialValue: reminderItem.dueDate ?? initialDate)
            _scheduleTime  = State(initialValue: reminderItem.scheduleTime)
            _priority = State(initialValue: reminderItem.priority ?? "")
            _alert = State(initialValue: reminderItem.alert ?? "")
        }
        else {
            _name  = State(initialValue: "")
            _desc  = State(initialValue: "")
            _dueDate  = State(initialValue: initialDate)
            _scheduleTime  = State(initialValue: false)
            _priority = State(initialValue: "")
            _alert = State(initialValue: "")
        }
    }
    
    var body: some View {
        
        Form{
            
            Section(header: Text("Reminder ")){
                
                TextField("Reminder Name", text: $name)
                    .foregroundColor(priorityColor())
                TextField("Desc", text: $desc)
            }
            
            Section(header: Text("Due Date")){
                
                Toggle("Schedule Time", isOn: $scheduleTime)
                DatePicker("Due Date", selection: $dueDate, displayedComponents: displayComps())
            }
            
            Section(header: Text("Choose Alert")) {
                Toggle("Enable Alert", isOn: $showAlertOptions)
                
                if showAlertOptions {
                    Picker("Minutes Before", selection: $alertMinutes) {
                        Text("5 minutes").tag(5)
                        Text("10 minutes").tag(10)
                        Text("15 minutes").tag(15)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            
            Section(header: Text ("Alarm Sound")){
                Button("Choose Sound", action: {
                    showAudioPicker()
                })
                       if let selectedAudioURL = selectedAudioURL {
                    Text("Selected Sound: \(selectedAudioURL.lastPathComponent)")
                }
            }
            
            if selectedReminderItem?.isCompleted() ?? false{
                
                Section(header: Text("Completed")){
                    
                    Text(selectedReminderItem?.completedDate?.formatted(date: .abbreviated, time: .shortened) ?? "")
                        .foregroundStyle(.green)
                }
            }
            
            Section(header: Text("Priority")) {
                Picker("Priority", selection: $priority){
                    Text("Low").tag("Low")
                    Text("Medium").tag("Medium")
                    Text("High").tag("High")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(){
                Button("Save", action: saveAction)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

        }
        .onDisappear {
            saveAction()
        
                        playSelectedSound()
                    }
                       
    }
    
    func priorityColor() -> Color {
        switch priority {
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
            selectedReminderItem?.priority = priority
            
            dateHolder.saveContext(viewContext)
            self.presentationMode.wrappedValue.dismiss()
            
            
            let reminderManager = ReminderManager()
            reminderManager.scheduleNotification(for: selectedReminderItem!)
            reminderManager.playAlarmSound {
                
                reminderManager.stopAlarm()
                
            }
        }
        
    }
                       
                       func showAudioPicker() {
                    let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeAudio)], in: .import)
            
                    documentPicker.allowsMultipleSelection = false
                    documentPicker.shouldShowFileExtensions = true
                    UIApplication.shared.windows.first?.rootViewController?.present(documentPicker, animated: true, completion: nil)
                }
                       
                       func playSelectedSound() {
                    guard let selectedAudioURL = selectedAudioURL else  {return}
                    
                    do {
                        let audioPlayer = try AVAudioPlayer(contentsOf: selectedAudioURL)
                        audioPlayer.play()
                    } catch {
                        print("Error playing selected sound: \(error.localizedDescription)")
                    }
                }
}
    
                       

struct ReminderEditView_Previews: PreviewProvider {
    
    static var previews: some View{
        ReminderEditView(passedReminderItem: ReminderItem(), initialDate: Date())
    }
}
