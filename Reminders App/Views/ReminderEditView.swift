//
//  ReminderEditView.swift
//  Reminders App
//
//

import SwiftUI
import AVFoundation
import MobileCoreServices
import UIKit
import UserNotifications


// Bu struct, kullanıcıya hatırlatıcı düzenleme ekranını gösterir.
struct ReminderEditView: View {
    
     // Görünümünde yönetilen bağlamı ortamlarını alır
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dateHolder: DateHolder
    
     // Hatırlatıcı öğesini ve diğer durumları tutan değişkenler
    @State var selectedReminderItem: ReminderItem?
    @State var name: String
    @State var desc: String
    @State var dueDate: Date
    @State var scheduleTime: Bool
    @State var priority: String
    @State var alert: String
    @State var alarmSound: String
     
     // Diğer durum değişkenleri
     @State private var alertMinutes: Int = 5
     @State private var showAlertOptions: Bool = false
     @State private var selectedAudioURL: URL?
     @State private var selectedAudioFileName: String?
    
    
    private let audioFileURLs = [
            Bundle.main.url(forResource: "Astronaut", withExtension: "mp3"),
            Bundle.main.url(forResource: "Huawei", withExtension: "mp3"),
            Bundle.main.url(forResource: "Poco", withExtension: "mp3")
        ].compactMap { $0 }
    
     // İnit metodu - Yeni bir hatırlatıcı düzenleme görünümü oluşturur
    init(passedReminderItem: ReminderItem?, initialDate: Date){
        
        if let reminderItem = passedReminderItem{
            
            _selectedReminderItem = State(initialValue: reminderItem)
            
            _name  = State(initialValue: reminderItem.name ?? "")
            _desc  = State(initialValue: reminderItem.desc ?? "")
            _dueDate  = State(initialValue: reminderItem.dueDate ?? initialDate)
            _scheduleTime  = State(initialValue: reminderItem.scheduleTime)
            _priority = State(initialValue: reminderItem.priority ?? "")
            _alarmSound = State(initialValue: reminderItem.alarmSound ?? "")
            _alert = State(initialValue: reminderItem.alert ?? "")
             _showAlertOptions=State(initialValue: reminderItem.alert != nil)
             _alertMinutes = State(initialValue: Int(reminderItem.alert?.components(separatedBy: " ").first ?? "") ?? 5)
           
        }
        else {
            _name  = State(initialValue: "")
            _desc  = State(initialValue: "")
            _dueDate  = State(initialValue: initialDate)
            _scheduleTime  = State(initialValue: false)
            _priority = State(initialValue: "")
            _alert = State(initialValue: "")
            _alarmSound = State(initialValue: "")
             _showAlertOptions = State(initialValue: false)
             _alertMinutes = State(initialValue: 5) // Set a default value or initial value
        }
    }
    
     // Görünümün gövdesi.
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
            
            Section(header: Text ("Alarm Sound")){
                Picker("Select Alarm Sound", selection: $alarmSound){
                                    ForEach(audioFileURLs, id: \.self) { audioURL in
                                         Text(audioURL.lastPathComponent )
                                            .tag(audioURL.absoluteString)
                                    }
                                }
                                .onChange(of: alarmSound) { newAlarmSound in
                                    if let selectedAudioURL = audioFileURLs.first(where: { $0.absoluteString == newAlarmSound }) {
                                        playSelectedSound(audioURL: selectedAudioURL)
                                    }
                                }
                     
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
                    }
                       
    }
     func truncateTextToFit(_ text: String, maxLength: Int) -> String {
                 guard text.count > maxLength else {
                     return text
                 }
                 
                 let truncatedText = text.prefix(maxLength - 3) + "..."
                 return String(truncatedText)
             }
     
     // Öncelik rengine göre bir renk döndürür.
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
    
     // DatePicker bileşeninin görüntülenecek bileşenlerini belirler.
    func displayComps() -> DatePickerComponents{
        
        return scheduleTime ? [.hourAndMinute, .date] : [.date]
    }
    
     // Değişiklikleri kaydeden işlem.
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
            selectedReminderItem?.alarmSound = alarmSound
            
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
             //selectedReminderItem?.audioURL=selectedAudioURL

                            
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
                       
     // Seçilen sesi çalmak için bir fonksiyon.
     func playSelectedSound(audioURL: URL) {  // playSelectedSound fonksiyonunu audioURL parametresi ile güncelledik
         do {
             let audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
             audioPlayer.play()

             selectedAudioFileName = truncateTextToFit(audioURL.lastPathComponent, maxLength: 20)
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
      /*
class ScheduledTaskManager {
    func scheduleNotificationWithSound(selectedReminderItem: ReminderItem, selectedAudioURL: URL) {
        let content = UNMutableNotificationContent()
        content.title = selectedReminderItem.name ?? "Hatırlatıcı"
        if let desc = selectedReminderItem.desc, !desc.isEmpty {
            content.body = desc
        }

        // Seçilen sesi bildirim içeriğine ekleyin
        do {
             let soundAttachment = try UNNotificationSound(named: UNNotificationSoundName(rawValue: selectedAudioURL.path) )
            content.sound = soundAttachment
        } catch {
            print("Error adding sound to notification content: \(error.localizedDescription)")
        }

        // Bildirim tetikleyiciyi ayarlayın (örneğin, birkaç saniye sonra)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // Bildirimi oluşturun ve tetikleyici ile birlikte planlayın
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Bildirim hatası: \(error.localizedDescription)")
            } else {
                print("Bildirim başarıyla planlandı.")
            }
        }
    }
}*/
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
                 
                 //if let selectedURL = urls.first {
                   //      selectedAudioURL = selectedURL
                     //    selectedAudioFileName = //selectedURL.lastPathComponent
                 //}
             }
         }
                       

struct ReminderEditView_Previews: PreviewProvider {
    
    static var previews: some View{
        ReminderEditView(passedReminderItem: ReminderItem(), initialDate: Date())
    }
}
