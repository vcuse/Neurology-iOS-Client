import SwiftUI

struct NewNIHFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = StrokeScaleFormViewModel()
    @State private var patientName: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("New NIH Stroke Scale Form")
                .font(.title)
                .padding(.leading)
                .padding(.trailing)
                .padding(.top)
                .padding(.bottom, 5)
                .bold()

            TextField("Enter Patient Name", text: $patientName)
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom, 5)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Text("Date: \(Date(), style: .date)")
                .padding(.bottom, 5)

            Form {
                ForEach(viewModel.questions.indices, id: \.self) { index in
                    let question = viewModel.questions[index]
                    Section {
                        OptionRowView(question: question, selectedOption: $viewModel.questions[index].selectedOption)
                    }
                }
            }

            // Save and Cancel buttons
            HStack {
                Button(action: {
                    saveForm()
                    presentationMode.wrappedValue.dismiss() // Dismiss after saving
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }

                Button(action: {
                    presentationMode.wrappedValue.dismiss() // Dismiss without saving
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.purple.opacity(0.2))
    }

    private func saveForm() {
        // Get the Core Data context from the environment
        let context = viewContext

        // Create a new NIHFormEntity
        let newForm = NIHFormEntity(context: context)
        newForm.date = Date()
        newForm.patientName = patientName

        // Collect selected options from each question
        let selectedOptions = viewModel.questions.map { $0.selectedOption ?? -1 }

        // Encode the array of selected options into data and save it in Core Data
        do {
            let optionsData = try JSONEncoder().encode(selectedOptions)
            newForm.selectedOptions = optionsData as Data

            // Ensure the save operation happens on the main thread
            DispatchQueue.main.async {
                do {
                    try context.save()
                    print("Form saved successfully.")
                } catch {
                    print("Failed to save form: \(error)")
                }
            }
        } catch {
            print("Failed to encode selected options: \(error)")
        }
    }
}
