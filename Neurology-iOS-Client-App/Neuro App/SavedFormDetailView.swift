import SwiftUI

struct SavedFormDetailView: View {
    var savedForm: NIHFormEntity
    
    @State var selectedOptions: [Int]

    init(savedForm: NIHFormEntity) {
        self.savedForm = savedForm
        
        // Decode the selectedOptions from Core Data (if they exist)
        if let optionsData = savedForm.selectedOptions as? Data {
            do {
                let decodedOptions = try JSONDecoder().decode([Int].self, from: optionsData)
                self._selectedOptions = State(initialValue: decodedOptions)
            } catch {
                self._selectedOptions = State(initialValue: Array(repeating: -1, count: 15)) // Default for 15 questions
                print("Failed to decode options")
            }
        } else {
            self._selectedOptions = State(initialValue: Array(repeating: -1, count: 15)) // Default for 15 questions
        }
    }

    var body: some View {
        VStack {
            Text("NIH Stroke Scale Form")
                .font(.title)
                .padding()

            Text("Date: \(savedForm.date ?? Date(), style: .date)")
                .padding(.leading)

            Form {
                ForEach(0..<selectedOptions.count, id: \.self) { index in
                    Section(header: Text("Question \(index + 1)")) {
                        Text("Selected option: \(selectedOptions[index] == -1 ? "None" : "\(selectedOptions[index])")")
                            .padding()
                    }
                }
            }
        }
        .navigationBarTitle("Saved Form", displayMode: .inline)
    }
}
