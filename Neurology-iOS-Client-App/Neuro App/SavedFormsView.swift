import SwiftUI
import CoreData

struct SavedFormsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: NIHFormEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \NIHFormEntity.date, ascending: false)]
    ) private var savedForms: FetchedResults<NIHFormEntity>

    var body: some View {
        // Ensure the view is inside a single NavigationView at the top level
        NavigationView {
            List {
                ForEach(savedForms, id: \.self) { form in
                    // Make the entire row clickable by using a NavigationLink
                    NavigationLink(destination: SavedFormDetailView(savedForm: form)) {
                        HStack {
                            // Show the date as the title
                            Text(form.date ?? Date(), style: .date)
                            Spacer()
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Saved Forms")
            .onAppear {
                // Refresh Core Data context when the view appears
                do {
                    try viewContext.refreshAllObjects()
                } catch {
                    print("Error refreshing Core Data context: \(error)")
                }
            }
        }
        // Force single-column navigation style
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
