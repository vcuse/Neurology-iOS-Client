import SwiftUI
import CoreData

import SwiftUI
import CoreData

struct SavedFormsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: NIHFormEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \NIHFormEntity.date, ascending: false)]
    )
    
    private var savedForms: FetchedResults<NIHFormEntity>
    
    var body: some View {
        // Ensure the view is inside a single NavigationView at the top level
        NavigationView {
            VStack {
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
            }
            .navigationTitle("Saved Forms")
            .toolbar {
                // Add a button in the top-right corner
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Action for creating a new form
                        print("New Form button tapped")
                        // Insert your action to navigate to the new form creation view here
                    }) {
                        Text("New Form")
                    }
                }
            }
            .onAppear {
                viewContext.refreshAllObjects() // Refresh to ensure the latest data
            }
        }
        // Force single-column navigation style
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
