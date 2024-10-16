import SwiftUI

import SwiftUI

struct StrokeScaleFormView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: StrokeScaleFormViewModel
    let saveForm: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Text("NIH Stroke Scale Form")
                    .font(.title)
                    .padding()

                Spacer()

                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
                .padding()
            }

            Text("Date: \(Date(), style: .date)")
                .padding(.leading)

            Form {
                ForEach(viewModel.questions.indices, id: \.self) { index in
                    let question = viewModel.questions[index]
                    
                    Section {
                        OptionRowView(question: question, selectedOption: $viewModel.questions[index].selectedOption)
                    }
                    .background(Color.clear)
                    .cornerRadius(10)
                }
            }
            .background(Color.clear)

            Spacer()
            
            // Save button only
            HStack {
                Button(action: {
                    saveForm()
                    isPresented = false // Close form after saving
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.purple.opacity(0.2))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}



struct Option {
    let title: String
    let score: Int
}

struct StrokeScaleQuestion {
    let id: Int
    let questionHeader: String
    let subHeader: String?
    let options: [Option]
    var selectedOption: Int?
}

struct OptionRowView: View {
    let question: StrokeScaleQuestion
    @Binding var selectedOption: Int?
    
    var body: some View {
        VStack(alignment: .leading) {
            // question header
            Text(question.questionHeader)
                .font(.headline)
                .padding(.bottom, 5)
            
            // subheader if it exists
            if let subHeader = question.subHeader {
                Text(subHeader)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)
            }

            // Display all options vertically
            ForEach(question.options.indices, id: \.self) { index in
                let option = question.options[index]
                HStack {
                    Text(option.title)
                        .padding(.vertical, 10)
                        .padding(.leading)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(option.score > 0 ? "+\(option.score)" : "\(option.score)")
                        .foregroundColor(.gray)
                        .frame(width: 40, alignment: .trailing)
                        .padding(.trailing)
                }
                .background(selectedOption == index ? Color.purple.opacity(0.6) : Color.purple.opacity(0.2))
                .cornerRadius(6)
                .onTapGesture {
                    selectedOption = index
                }
            }
        }
    }
}



class StrokeScaleFormViewModel: ObservableObject {
    @Published var questions: [StrokeScaleQuestion] = [
        StrokeScaleQuestion(id: 0, questionHeader: "1A: Level of Consciousness", subHeader: "May be assessed casually while taking history", options: [
            Option(title: "Alert; keenly responsive", score: 0),
            Option(title: "Arouses to minor stimulation", score: 1),
            Option(title: "Requires repeated stimulation to arouse", score: 2),
            Option(title: "Movements to pain", score: 2),
            Option(title: "Postures or unresponsive", score: 3)
        ], selectedOption: nil),
        
        StrokeScaleQuestion(id: 1, questionHeader: "1B: Ask month and age", subHeader: nil, options: [
            Option(title: "Both questions right", score: 0),
            Option(title: "1 question right", score: 1),
            Option(title: "0 questions right", score: 2),
            Option(title: "Dysarthric/intubated/trauma/language barrier", score: 1),
            Option(title: "Aphasic", score: 2)
        ], selectedOption: nil),
        
        StrokeScaleQuestion(id: 2, questionHeader: "1C: 'Blink eyes' & 'Squeeze hands'", subHeader: "Pantomime commands if communication barrier", options: [
            Option(title: "Performs both tasks", score: 0),
            Option(title: "Performs 1 task", score: 1),
            Option(title: "Performs 0 tasks", score: 2)
        ], selectedOption: nil),
        
        StrokeScaleQuestion(id: 3, questionHeader: "2: Horizontal extraocular movements", subHeader: "Only assess horizontal gaze", options: [
            Option(title: "Normal", score: 0),
            Option(title: "Partial gaze palsy: can be overcome", score: 1),
            Option(title: "Partial gaze palsy: corrects with oculocephalic reflex", score: 1),
            Option(title: "Forced gaze palsy: cannot be overcome", score: 2)
        ], selectedOption: nil),
        
        StrokeScaleQuestion(id: 4, questionHeader: "3: Visual Fields", subHeader: nil, options: [
            Option(title: "No visual loss", score: 0),
            Option(title: "Partial hemianopia", score: 1),
            Option(title: "Complete hemianopia", score: 2),
            Option(title: "Patient is bilaterally blind", score: 3),
            Option(title: "Bilateral hemianopia", score: 3)
        ], selectedOption: nil),
        
        StrokeScaleQuestion(id: 5, questionHeader: "4: Facial Palsy", subHeader: "Use grimace if obtunded", options: [
            Option(title: "Normal symmetry", score: 0),
            Option(title: "Minor paralysis (flat nasolabial fold, smile asymmetry)", score: 1),
            Option(title: "Partial paralysis (lower face)", score: 2),
            Option(title: "Unilateral complete paralysis (upper/lower face)", score: 3),
            Option(title: "Bilateral complete paralysis (upper/lower face)", score: 3)
        ], selectedOption: nil),
        
        StrokeScaleQuestion(id: 6, questionHeader: "5A: Left arm motor drift", subHeader: "Count out loud and use your fingers to show the patient your count", options: [
            Option(title: "No drift for 10 seconds", score: 0),
            Option(title: "Drift, but doesn't hit bed", score: 1),
            Option(title: "Drift, hits bed", score: 2),
            Option(title: "Some effort against gravity", score: 2),
            Option(title: "No effort against gravity", score: 3),
            Option(title: "No movement", score: 4),
            Option(title: "Amputation/joint fusion", score: 0)
        ], selectedOption: nil),
        
        StrokeScaleQuestion(id: 7, questionHeader: "5B: Right arm motor drift", subHeader: "Count out loud and use your fingers to show the patient your count", options: [
            Option(title: "No drift for 10 seconds", score: 0),
            Option(title: "Drift, but doesn't hit bed", score: 1),
            Option(title: "Drift, hits bed", score: 2),
            Option(title: "Some effort against gravity", score: 2),
            Option(title: "No effort against gravity", score: 3),
            Option(title: "No movement", score: 4),
            Option(title: "Amputation/joint fusion", score: 0)
        ], selectedOption: nil),
        
        StrokeScaleQuestion(id: 8, questionHeader: "6A: Left leg motor drift", subHeader: "Count out loud and use your fingers to show the patient your count", options: [
            Option(title: "No drift for 5 seconds", score: 0),
            Option(title: "Drift, but doesn't hit bed", score: 1),
            Option(title: "Drift, hits bed", score: 2),
            Option(title: "Some effort against gravity", score: 2),
            Option(title: "No effort against gravity", score: 3),
            Option(title: "No movement", score: 4),
            Option(title: "Amputation/joint fusion", score: 0)
        ], selectedOption: nil),
        
        StrokeScaleQuestion(id: 9, questionHeader: "6B: Right leg motor drift", subHeader: "Count out loud and use your fingers to show the patient your count", options: [
            Option(title: "No drift for 5 seconds", score: 0),
            Option(title: "Drift, but doesn't hit bed", score: 1),
            Option(title: "Drift, hits bed", score: 2),
            Option(title: "Some effort against gravity", score: 2),
            Option(title: "No effort against gravity", score: 3),
            Option(title: "No movement", score: 4),
            Option(title: "Amputation/joint fusion", score: 0)
        ], selectedOption: nil),
        
        StrokeScaleQuestion(id: 10, questionHeader: "7: Limb Ataxia", subHeader: "FNF/heel-shin", options: [
            Option(title: "No ataxia", score: 0),
            Option(title: "Ataxia in 1 limb", score: 1),
            Option(title: "Ataxia in 2 limbs", score: 2),
            Option(title: "Does not understand", score: 0),
            Option(title: "Paralyzed", score: 0),
            Option(title: "Amputation/joint fusion", score: 0)
        ], selectedOption: nil),
        
        StrokeScaleQuestion(id: 11, questionHeader: "8: Sensation", subHeader: nil, options: [
            Option(title: "Normal; no sensory loss", score: 0),
            Option(title: "Mild-moderate loss: less sharp/more dull", score: 1),
            Option(title: "Mild/moderate loss: can sense being touched", score: 1),
            Option(title: "Complete loss: cannot sense being touched at all", score: 2),
            Option(title: "No response and quadriplegic", score: 2),
            Option(title: "Coma/unresponsive", score: 2)
        ], selectedOption: nil),
        
        StrokeScaleQuestion(id: 12, questionHeader: "9: Language/Aphasia", subHeader: "Describe the scene; name the items; read the sentences", options: [
            Option(title: "Normal; no aphasia", score: 0),
            Option(title: "Mild-moderate aphasia: some obvious changes, without significant limitation", score: 1),
            Option(title: "Severe aphasia: fragmentary expression, inference needed, cannot identify materials", score: 2),
            Option(title: "Mute/global aphasia: no usable speech/auditory comprehension", score: 3),
            Option(title: "Coma/unresponsive", score: 3)
        ], selectedOption: nil),
        
        StrokeScaleQuestion(id: 13, questionHeader: "10: Dysarthria", subHeader: "Read the words", options: [
            Option(title: "Normal", score: 0),
            Option(title: "Mild-moderate dysarthria: slurring but can be understood", score: 1),
            Option(title: "Severe dysarthria: unintelligible slurring or out of proportion to dysphasia", score: 2),
            Option(title: "Mute/anarthric", score: 2),
            Option(title: "Intubated/unable to test", score: 0)
        ], selectedOption: nil),
        
        StrokeScaleQuestion(id: 14, questionHeader: "11: Extinction/Inattention", subHeader: nil, options: [
            Option(title: "No abnormality", score: 0),
            Option(title: "Visual/tactile/auditory/spatial/personal inattention", score: 1),
            Option(title: "Extinction to bilateral simultaneous stimulation", score: 1),
            Option(title: "Profound hemi-inattention", score: 2),
            Option(title: "Extinction to >1 modality", score: 2)
        ], selectedOption: nil)
    ]
}
