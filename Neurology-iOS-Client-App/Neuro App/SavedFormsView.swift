import SwiftUI
import CoreData

struct SavedFormsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: NIHFormEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \NIHFormEntity.date, ascending: false)]
    ) private var savedForms: FetchedResults<NIHFormEntity>

    var body: some View {
        NavigationView {
            List {
                ForEach(savedForms, id: \.self) { form in
                    HStack {
                        // Show the date as the title
                        Text(form.date ?? Date(), style: .date)
                        Spacer()
                        // View button
                        NavigationLink(destination: SavedFormDetailView(savedForm: form)) {
                            Text("View")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Saved Forms")
        }
    }
}
