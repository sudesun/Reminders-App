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
    
    @State private var alertMinutes: Int = 5
    @State private var showAlertOptions: Bool = false
    @State private var selectedAudioURL: URL?
    @State private var selectedAudioFileName: String?
    
    
    init(passedReminderItem: ReminderItem?, initialDate: Date) {
        if let reminderItem = passedReminderItem {
            // passedReminderItem değeri nil değilse, bu değerleri kullan
            _selectedReminderItem = State(initialValue: reminderItem)
            _name = State(initialValue: reminderItem.name ?? "")
            _desc = State(initialValue: reminderItem.desc ?? "")
            _dueDate = State(initialValue: reminderItem.dueDate ?? initialDate)
            _scheduleTime = State(initialValue: reminderItem.scheduleTime)
            _priority = State(initialValue: reminderItem.priority ?? "")
            _alert = State(initialValue: reminderItem.alert ?? "")
            _showAlertOptions = State(initialValue: reminderItem.alert != nil)
            _alertMinutes = State(initialValue: Int(reminderItem.alert?.components(separatedBy: " ").first ?? "") ?? 5)
        } else {
            // passedReminderItem değeri nil ise, varsayılan değerleri kullan
            _name = State(initialValue: "")
            _desc = State(initialValue: "")
            _dueDate = State(initialValue: initialDate)
            _scheduleTime = State(initialValue: false)
            _priority = State(initialValue: "")
            _alert = State(initialValue: "")
            _showAlertOptions = State(initialValue: false)
            _alertMinutes = State(initialValue: 5) // Set a default value or initial value
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
                
                Section(header: Text("Alarm Sound")){
                    Button("Choose Sound", action: {
                        let documentPicker = DocumentPicker(selectedAudioURL: $selectedAudioURL, selectedAudioFileName: $selectedAudioFileName)

                        let hostingController = UIHostingController(rootView: documentPicker)
                        UIApplication.shared.windows.first?.rootViewController?.present(hostingController, animated: true, completion: nil)
                    })
                    
                    if let selectedAudioURL = selectedAudioURL {
                        let displayText = truncateTextToFit(selectedAudioURL.lastPathComponent, maxLength: 20)
                        Text("Selected Sound: \(displayText)")
                            .lineLimit(1)  // Sadece bir satır göstermek için
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
        
        func saveAction() {
            withAnimation {
                if selectedReminderItem == nil {
                    selectedReminderItem = ReminderItem(context: viewContext)
                }
                
                selectedReminderItem?.created = Date()
                selectedReminderItem?.name = name
                selectedReminderItem?.desc = desc.isEmpty ? nil : desc
                selectedReminderItem?.dueDate = dueDate
                selectedReminderItem?.scheduleTime = scheduleTime
                selectedReminderItem?.priority = priority
                
                if showAlertOptions {
                    // Enable Alert seçiliyse gerekli işlemleri yap
                    if alertMinutes > 0 {
                        selectedReminderItem?.alert = "\(alertMinutes) minutes before"
                    } else {
                        // Eğer seçilen bir değer yoksa, alert'ı sıfırla
                        selectedReminderItem?.alert = nil
                    }
                } else {
                    // Enable Alert seçili değilse, alert bilgisini sıfırla
                    selectedReminderItem?.alert = nil
                }
                selectedReminderItem?.audioURL = selectedAudioURL // Seçilen ses dosyasının URL'ini ReminderItem'a atıyoruz

                
                print("Alert Value: \(selectedReminderItem?.alert ?? "nil")")
                
                dateHolder.saveContext(viewContext)
                self.presentationMode.wrappedValue.dismiss()
                
                let reminderManager = ReminderManager()
                reminderManager.scheduleNotification(for: selectedReminderItem!)
                reminderManager.playAlarmSound {
                    reminderManager.stopAlarm()
                }
            }
        }
        
        func truncateTextToFit(_ text: String, maxLength: Int) -> String {
            guard text.count > maxLength else {
                return text
            }
            
            let truncatedText = text.prefix(maxLength - 3) + "..."
            return String(truncatedText)
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
        
        
    
    func showAudioPicker() {
        let documentPicker = DocumentPicker(selectedAudioURL: $selectedAudioURL, selectedAudioFileName: $selectedAudioFileName)

            if let selectedAudioURL = selectedAudioURL {
                selectedAudioFileName = selectedAudioURL.lastPathComponent
            }
        
        let hostingController = UIHostingController(rootView: documentPicker)
        UIApplication.shared.windows.first?.rootViewController?.present(hostingController, animated: true, completion: nil)
    }

    func playSelectedSound() {
        guard let selectedAudioURL = selectedAudioURL else { return }

        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: selectedAudioURL)
            audioPlayer.play()

            selectedAudioFileName = truncateTextToFit(selectedAudioURL.lastPathComponent, maxLength: 20)
        } catch {
            print("Error playing selected sound: \(error.localizedDescription)")
        }
    }
    }
    
    
    struct DocumentPicker: UIViewControllerRepresentable {
        @Binding var selectedAudioURL: URL?
        @Binding var selectedAudioFileName: String?
        
        //var selectedAudioURL: URL?
        
        init(selectedAudioURL: Binding<URL?>, selectedAudioFileName: Binding<String?>) {
                self._selectedAudioURL = selectedAudioURL
                self._selectedAudioFileName = selectedAudioFileName
            }
        
        func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
            let documentTypes: [UTType] = [UTType.audio]
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: documentTypes)
            picker.delegate = context.coordinator
            return picker
        }
        
        func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            return Coordinator(parent: self)
        }
        
        class Coordinator: NSObject, UIDocumentPickerDelegate {
            var parent: DocumentPicker
            
            init(parent: DocumentPicker) {
                self.parent = parent
            }
            
            func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
                    parent.selectedAudioURL = urls.first
                    parent.selectedAudioFileName = urls.first?.lastPathComponent
                }
            }
        }
    
    
    class DocumentPickerViewController: UIViewController, UIDocumentPickerDelegate {
        var coordinator: DocumentPicker.Coordinator
        
        init(coordinator: DocumentPicker.Coordinator) {
            self.coordinator = coordinator
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            coordinator.documentPicker(controller, didPickDocumentsAt: urls)
            
            if let selectedURL = urls.first {
                    selectedAudioURL = selectedURL
                    selectedAudioFileName = selectedURL.lastPathComponent
            }
        }
    }
    
    
    
    struct ReminderEditView_Previews: PreviewProvider {
        
        static var previews: some View{
            ReminderEditView(passedReminderItem: ReminderItem(), initialDate: Date())
        }
    }

