//
//  ContentView.swift
//  Reminders App
//
//

import SwiftUI
import CoreData

struct ReminderListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dateHolder: DateHolder
    

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ReminderItem.dueDate, ascending: true)],
        animation: .default)
    private var items: FetchedResults<ReminderItem>
    
    @State private var selectedFilter: ReminderFilter = .All

    var body: some View {
        NavigationView {
            
            VStack{
                
                ZStack {
                    
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
                    
                    FloatingButton()
                        .environmentObject(dateHolder)
                }
            }
            .navigationTitle("Reminders")
        }
    }

    func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { selectedFilter.filteredReminderItems(items: items)[$0] }.forEach(viewContext.delete)

            dateHolder.saveContext(viewContext)
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ReminderListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
    
}
