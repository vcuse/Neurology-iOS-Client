import SwiftUI

struct NewNIHFormView: View {
    var remoteForm: RemoteStrokeForm?
    var initialSelectedOptions: [Int]

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = StrokeScaleFormViewModel()
    @State private var patientName: String
    @State private var patientDOB: Date
    @State private var selectedOptions: [Int]
    @State private var showDOBPicker: Bool = false
    
    init(remoteForm: RemoteStrokeForm? = nil, initialSelectedOptions: [Int] = Array(repeating: -1, count: 15)) {
        self.remoteForm = remoteForm
        self.initialSelectedOptions = initialSelectedOptions

        _patientName = State(initialValue: remoteForm?.name ?? "")
        _patientDOB = State(initialValue: StrokeScaleFormManager.convertDOB(from: remoteForm?.dob ?? ""))
        _selectedOptions = State(initialValue: {
            if let resultStr = remoteForm?.results {
                return resultStr.map { Int(String($0)) ?? 9 }
            }
            return Array(repeating: -1, count: 15)
        }())
    }

    var body: some View {
        VStack {
            Text(remoteForm != nil ? "Update Form" : "New Form")
                .font(.title)
                .padding(.leading)
                .padding(.trailing)
                .padding(.top)
                .padding(.bottom, 5)
                .bold()

            TextField("Enter Patient Name", text: $patientName)
                .padding(.horizontal)
                .frame(height: 44)
                .background(
                    Color(UIColor { trait in
                        trait.userInterfaceStyle == .dark ? .black : .white
                    })
                )
                .foregroundColor(
                    Color(UIColor { trait in
                        trait.userInterfaceStyle == .dark ? .white : .black
                    })
                )
                .font(.headline)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                .padding([.leading, .trailing])
                .padding(.bottom, 5)

            // DOB Selector
            Button(action: {
                showDOBPicker.toggle()
            }) {
                HStack {
                    Text("DOB: \(formattedDate(patientDOB))")
                        .foregroundColor(
                            Color(UIColor { trait in
                                trait.userInterfaceStyle == .dark ? .white : .black
                            })
                        )
                        .font(.headline)
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    Color(UIColor { trait in
                        trait.userInterfaceStyle == .dark ? .black : .white
                    })
                )
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
            }
            .padding(.leading)
            .padding(.trailing)
            .padding(.bottom, 5)

            // Date Picker Modal
            .sheet(isPresented: $showDOBPicker) {
                VStack(spacing: 10) {
                    Text("Select Date of Birth")
                        .font(.headline)
                        .foregroundColor(
                            Color(UIColor { $0.userInterfaceStyle == .dark ? .white : .black })
                        )
                        .padding(.top)

                    DatePicker(
                        "",
                        selection: $patientDOB,
                        in: ...Date(),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()

                    Button("Done") {
                        showDOBPicker = false
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(10)
                    .padding([.leading, .trailing])
                }
                .background(
                    Color(UIColor.systemBackground)
                        .edgesIgnoringSafeArea(.all)
                )
            }

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
        .onAppear {
            for option in 0..<min(viewModel.questions.count, selectedOptions.count) {
                viewModel.questions[option].selectedOption = selectedOptions[option]
            }
        }
    }

    private func saveForm() {
        let selected = viewModel.questions.map { $0.selectedOption ?? 9 }

        if let form = remoteForm {
            StrokeScaleFormManager.updateForm(
                remoteForm: form,
                patientName: patientName,
                dob: patientDOB,
                selectedOptions: selected
            )
        } else {
            StrokeScaleFormManager.saveForm(
                context: viewContext,
                patientName: patientName,
                dob: patientDOB,
                selectedOptions: selected
            ) 
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    } 

}
