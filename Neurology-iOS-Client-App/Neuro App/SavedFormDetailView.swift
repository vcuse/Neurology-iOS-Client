import SwiftUI

struct SavedFormDetailView: View {
    var savedForm: NIHFormEntity
    @ObservedObject var viewModel = StrokeScaleFormViewModel() // Assuming this contains your questions
    @State var selectedOptions: [Int]
    
    var totalScore: Int {
        var score = 0
        for (index, selectedOption) in selectedOptions.enumerated() {
            if selectedOption != -1 {
                score += viewModel.questions[index].options[selectedOption].score
            }
        }
        return score
    }

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
            // Hiding navigation bar to remove empty space and extra back button
            Text("NIH Stroke Scale Form")
                .font(.title)

            Text("Date: \(savedForm.date ?? Date(), style: .date)")
            
            // Display the total score below the date
            Text("Total Score: \(totalScore)")
                .padding(.bottom)
            
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(viewModel.questions.indices, id: \.self) { index in
                        let question = viewModel.questions[index]
                        let selectedOptionIndex = selectedOptions[index]
                        
                        Section {
                            // Question header
                            Text(question.questionHeader)
                                .font(.headline)
                                .padding(.top, 5)
                            
                            // Subheader if it exists
                            if let subHeader = question.subHeader {
                                Text(subHeader)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            // Display the options (without editing capabilities)
                            VStack(alignment: .leading) {
                                ForEach(question.options.indices, id: \.self) { optionIndex in
                                    let option = question.options[optionIndex]
                                    HStack {
                                        Text(option.title)
                                            .padding(.vertical, 10)
                                            .padding(.leading)
                                            .foregroundColor(.white)

                                        Spacer()

                                        // Display the score for the selected option
                                        Text(option.score > 0 ? "+\(option.score)" : "\(option.score)")
                                            .foregroundColor(.gray)
                                            .frame(width: 40, alignment: .trailing)
                                            .padding(.trailing)
                                    }
                                    .background(selectedOptionIndex == optionIndex ? Color.purple.opacity(0.6) : Color.purple.opacity(0.2))
                                    .cornerRadius(6)
                                }
                            }
                        }
                        .padding(.bottom, 10)
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        // Hides the navigation bar to prevent empty space and extra back button
        .navigationBarHidden(true)
    }
}
