import SwiftUI
import UIKit
import PDFKit

struct SavedFormDetailView: View {
    var remoteForm: RemoteStrokeForm

    @ObservedObject var viewModel = StrokeScaleFormViewModel()
    @State var selectedOptions: [Int]
    @State private var isPresentingUpdateForm = false
    @State private var showDeleteConfirmation = false
    @Binding var navigationPath: NavigationPath

    var totalScore: Int {
        selectedOptions.enumerated().reduce(0) { acc, item in
            let (index, selectedOption) = item
            return selectedOption != -1 ? acc + viewModel.questions[index].options[selectedOption].score : acc
        }
    }

    init(
        navigationPath: Binding<NavigationPath>,
        remoteForm: RemoteStrokeForm,
        selectedOptions: [Int]
    ) {
        self._navigationPath = navigationPath
        self.remoteForm = remoteForm
        self._selectedOptions = State(initialValue: selectedOptions)
        
        for indice in 0..<min(selectedOptions.count, viewModel.questions.count) {
            viewModel.questions[indice].selectedOption = selectedOptions[indice]
        }
    }

    var body: some View {
        VStack {
            // Header Section
            HStack {
                Text("NIH Stroke Scale Form")
                    .font(.title)
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.top)
                    .padding(.bottom, 5)
                    .bold()
            }

            // Patient Info Section
            VStack {
                Text("Patient Name: \(remoteForm.name)")
                    .font(.headline)
                    .padding(.bottom, 5)
                    .multilineTextAlignment(.center)

                Text("Patient DOB: \(StrokeScaleFormManager.convertDOB(from: remoteForm.dob), style: .date)")
                    .font(.subheadline)
                    .padding(.bottom, 5)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                Text("Date: \(StrokeScaleFormManager.convertDOB(from: remoteForm.formDate), style: .date)")
                    .font(.subheadline)
                    .padding(.bottom, 5)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .center)

            // Questions and Answers Section
            Form {
                ForEach(viewModel.questions.indices, id: \.self) { index in
                    let question = viewModel.questions[index]
                    let selectedOptionIndex = viewModel.questions[index].selectedOption ?? -1

                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(question.questionHeader)
                                .font(.headline)

                            if let subHeader = question.subHeader {
                                Text(subHeader)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            VStack(alignment: .leading) {
                                ForEach(question.options.indices, id: \.self) { optionIndex in
                                    let option = question.options[optionIndex]
                                    HStack {
                                        Text(option.title)
                                            .padding(.vertical, 10)
                                            .padding(.leading)

                                        Spacer()

                                        Text(option.score > 0 ? "+\(option.score)" : "\(option.score)")
                                            .foregroundColor(.gray)
                                            .frame(width: 40, alignment: .trailing)
                                            .padding(.trailing)
                                    }
                                    .background(selectedOptionIndex == optionIndex ? Color.purple.opacity(0.6) : Color.gray.opacity(0.2))
                                    .cornerRadius(6)
                                }
                            }
                        }
                    }
                }
            }

            Spacer()

            // Footer Section
            HStack {
                Button(action: {
                    navigationPath.removeLast(navigationPath.count)
                }, label: {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                })

                Button(action: {
                    isPresentingUpdateForm = true
                }) {
                    Text("Update")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    showDeleteConfirmation = true
                }, label: {
                    Text("Delete")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                })
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.purple.opacity(0.2))
        .fullScreenCover(isPresented: $isPresentingUpdateForm) {
            NewNIHFormView(
                navigationPath: $navigationPath,
                remoteForm: remoteForm,
                initialSelectedOptions: selectedOptions
            )
        }
        .alert("Are you sure you want to delete this form?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                StrokeScaleFormManager.deleteForm(remoteForm: remoteForm)
                navigationPath.removeLast(navigationPath.count)
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}
