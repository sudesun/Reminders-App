//
//  ContentView.swift
//  Reminders App
//
//

import SwiftUI
import CoreData

// ReminderListView struct'ı, hatırlatıcı listesini görüntüler
struct ReminderListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dateHolder: DateHolder
    
     // CoreData'den hatırlatıcı öğelerini almak için kullanılan fetched results
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ReminderItem.dueDate, ascending: true)],
        animation: .default)
    private var items: FetchedResults<ReminderItem>
    
     // Seçilen filtreleme türünü tutan değişken
    @State private var selectedFilter: ReminderFilter = .All

     // Görünüm yapısı
    var body: some View {
        NavigationView {
            
            VStack{
                
                ZStack {
                    
                     // Hatırlatıcı öğelerini listeler
                    List {
                        
                        ForEach(selectedFilter.filteredReminderItems(items: items)) { reminderItem in
                            NavigationLink(destination: ReminderEditView( passedReminderItem: reminderItem, initialDate: Date())
                                .environmentObject(dateHolder)){
                                    
                                ReminderCell(passedReminderItem: reminderItem)
                                    .environmentObject(dateHolder)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .toolbar {
                        
                         // Filtreleme seçeneklerini gösteren toolbar
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Picker("Filter", selection: $selectedFilter){
                                
                                ForEach (ReminderFilter.allFilters, id: \.self){
                                    filter in
                                    Text(filter.rawValue)
                                }
                            }
                        }
                        
                    }
                    .navigationBarTitle("Reminders")
                    
                     // Yeni hatırlatıcı ekranına yönlendiren kayan düğme
                    FloatingButton()
                        .environmentObject(dateHolder)
                }
            }
            .navigationTitle("Reminders")
        }
    }

     // CoreData context'ine değişiklikleri kaydeden işlem
    func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
     
     // Hatırlatıcı öğelerini silen işlem
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { selectedFilter.filteredReminderItems(items: items)[$0] }.forEach(viewContext.delete)

            dateHolder.saveContext(viewContext)
        }
    }
}

// DateFormatter nesnesi
private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

// Önizleme bölümü
struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ReminderListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
    
}
