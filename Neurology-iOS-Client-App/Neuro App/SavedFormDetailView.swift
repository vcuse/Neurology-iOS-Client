import SwiftUI
import UIKit
import PDFKit

struct SavedFormDetailView: View {
    var savedForm: NIHFormEntity
    @ObservedObject var viewModel = StrokeScaleFormViewModel()
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
        
        // Decode the selectedOptions from Core Data
        if let optionsData = savedForm.selectedOptions {
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
            
            if let patientName = savedForm.patientName {
                Text("Patient Name: \(patientName)")
                    .font(.headline)
            } else {
                Text("Patient Name: Unknown")
                    .font(.headline)
                    .padding(.top)
            }

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
            // Hides the navigation bar to prevent empty space and extra back button
            .navigationBarBackButtonHidden(true)

            // Export & Delete button
            HStack {
                Button(action: {
                    exportFormAsPDF() // Call the PDF export function
                }) {
                    Text("Export")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                }
                    Button(action: {
                        deleteForm()
                    }) {
                        Text("Delete")
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
    }
    
    private func exportFormAsPDF() {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: 842)) // A4 size PDF
        
        let data = pdfRenderer.pdfData { context in
            context.beginPage()
            let font = UIFont.systemFont(ofSize: 16)
            let headerFont = UIFont.boldSystemFont(ofSize: 18)
            let purpleOutlineAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.black,
                .paragraphStyle: NSMutableParagraphStyle()
            ]

            var yPosition: CGFloat = 20
            let pageHeight: CGFloat = 842
            let margin: CGFloat = 20
            
            // Title
            let title = "NIH Stroke Scale Form"
            title.draw(at: CGPoint(x: 20, y: yPosition), withAttributes: [NSAttributedString.Key.font: headerFont])
            yPosition += 40
            
            // Patient Name
            let patientNameText = "Patient Name: \(savedForm.patientName ?? "Unknown")"
            patientNameText.draw(at: CGPoint(x: 20, y: yPosition), withAttributes: [NSAttributedString.Key.font: font])
            yPosition += 30
            
            // Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let dateText = "Date: \(dateFormatter.string(from: savedForm.date ?? Date()))"
            dateText.draw(at: CGPoint(x: 20, y: yPosition), withAttributes: [NSAttributedString.Key.font: font])
            yPosition += 30
            
            // Total Score
            let totalScoreText = "Total Score: \(totalScore)"
            totalScoreText.draw(at: CGPoint(x: 20, y: yPosition), withAttributes: [NSAttributedString.Key.font: font])
            yPosition += 40
            
            // Questions and Options
            for (index, question) in viewModel.questions.enumerated() {
                // Estimate the height of the question header and subheader (if present)
                let questionHeaderHeight = (question.questionHeader as NSString).size(withAttributes: [.font: headerFont]).height
                let subHeaderHeight = (question.subHeader?.size(withAttributes: [.font: font]) ?? CGSize.zero).height
                let optionsHeight: CGFloat = question.options.reduce(0) { (result, option) in
                    let optionTitle = option.title as NSString
                    let boundingRect = optionTitle.boundingRect(with: CGSize(width: 450, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
                    return result + boundingRect.height + 20
                }
                
                // Check if the question will fit on the current page
                let requiredHeight = questionHeaderHeight + subHeaderHeight + optionsHeight + 50 // Add some padding
                if yPosition + requiredHeight > pageHeight - margin {
                    context.beginPage()
                    yPosition = 20
                }
                
                // Draw the Question Header
                question.questionHeader.draw(at: CGPoint(x: 20, y: yPosition), withAttributes: [NSAttributedString.Key.font: headerFont])
                yPosition += 30
                
                // Draw the Subheader
                if let subHeader = question.subHeader {
                    subHeader.draw(at: CGPoint(x: 20, y: yPosition), withAttributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor.gray])
                    yPosition += 25
                }
                
                // Draw the Options
                for (optionIndex, option) in question.options.enumerated() {
                    let selectedOptionIndex = selectedOptions[index]
                    let optionTitle = option.title as NSString
                    let optionScoreText = option.score > 0 ? "+\(option.score)" : "\(option.score)"
                    
                    // Draw the text in multiline if necessary
                    let textRect = CGRect(x: 40, y: yPosition, width: 450, height: CGFloat.greatestFiniteMagnitude)
                    let textAttributes: [NSAttributedString.Key: Any] = [
                        .font: font,
                        .foregroundColor: UIColor.black
                    ]
                    
                    let boundingRect = optionTitle.boundingRect(with: CGSize(width: 450, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil)
                    optionTitle.draw(with: textRect, options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil)
                    
                    // Draw the score aligned to the right
                    optionScoreText.draw(at: CGPoint(x: 500, y: yPosition), withAttributes: [NSAttributedString.Key.font: font])
                    
                    // Add purple outline for selected options
                    if selectedOptionIndex == optionIndex {
                        let outlineRect = CGRect(x: 35, y: yPosition - 5, width: boundingRect.width + 10, height: boundingRect.height + 10)
                        let outlinePath = UIBezierPath(rect: outlineRect)
                        UIColor.purple.setStroke()
                        outlinePath.lineWidth = 2
                        outlinePath.stroke()
                    }
                    
                    yPosition += boundingRect.height + 20
                }
                yPosition += 20
            }
        }
        
        // Share the PDF
        let activityViewController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    private func deleteForm() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Failed to access AppDelegate") // Log if AppDelegate isn't accessible
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        // Proceed with deletion
        managedContext.delete(savedForm)

        do {
            try managedContext.save()
            print("Form deleted successfully")
        } catch {
            print("Failed to delete the form: \(error.localizedDescription)")
        }

        // Optionally pop the view after deletion
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController as? UINavigationController {
            rootViewController.popViewController(animated: true)
        }
    }



    
    
}
