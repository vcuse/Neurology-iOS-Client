import SwiftUI
import CoreData

struct SavedFormsView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isNavigatingBack: Bool
    @State private var selectedFormBundle: SelectedFormBundle?
    @State private var isShowingNewFormView = false
    @State private var isShowingDetailView = false
    @State private var selectedOptions: [Int] = []
    @State private var shouldReloadForms = false
    @StateObject var formStore = RemoteFormStore()
    
    class RemoteFormStore: ObservableObject {
        @Published var forms: [RemoteStrokeForm] = []
    }
    
    struct SelectedFormBundle: Identifiable {
        let id = UUID()
        let form: RemoteStrokeForm
        let options: [Int]
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(colors: [.gray, .white, .gray], startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    // Header Section (now scrollable)
                    VStack {
                        HStack {
                            Button(action: {
                                isNavigatingBack = false
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                                .foregroundColor(.black)
                                .font(.title3)
                            }

                            Spacer()

                            Button(action: {
                                isShowingNewFormView = true
                            }) {
                                Text("New Form")
                                    .foregroundColor(.black)
                                    .font(.title3)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)

                        Text("Saved Forms")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.black)
                            .padding(.leading)
                            .padding(.top, 5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // List of Forms
                    VStack(spacing: 15) {
                        ForEach(formStore.forms) { form in
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(form.name)
                                        .font(.headline)
                                        .foregroundColor(
                                            Color(UIColor { traitCollection in
                                                return traitCollection.userInterfaceStyle == .dark ? .white : .black
                                            })
                                        )
                                    Text("Date: \(StrokeScaleFormManager.convertDOB(from: form.formDate), style: .date)")
                                        .font(.subheadline)
                                        .foregroundColor(
                                            Color(UIColor { traitCollection in
                                                return traitCollection.userInterfaceStyle == .dark ? .white : .black
                                            })
                                        )
                                }

                                Spacer()

                                Button(action: {
                                    let options = form.results.prefix(15).map { Int(String($0)) ?? 9 }
                                    selectedFormBundle = SelectedFormBundle(form: form, options: Array(options))
                                    isShowingDetailView = true

                                    print("🟣 Opening form with ID \(form.id), selectedOptions: \(selectedOptions)")
                                    print("🧪 Setting selectedRemoteForm: \(String(describing: form))")

                                 }) {
                                    HStack {
                                        Text("View")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 10)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                                }
                            }
                            .padding()
                            .background(
                                Color(UIColor { traitCollection in
                                    return traitCollection.userInterfaceStyle == .dark ? .black : .white
                                })
                            )
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarBackButtonHidden(true) // Hide the default back button
            .fullScreenCover(isPresented: $isShowingNewFormView) {
                NewNIHFormView()
            }
            .fullScreenCover(item: $selectedFormBundle) { bundle in
                SavedFormDetailView(
                    remoteForm: bundle.form,
                    selectedOptions: bundle.options
                )
            }
            .onAppear {
                StrokeScaleFormManager.fetchFormsFromServer { fetchedForms in
                    DispatchQueue.main.async {
                        formStore.forms = fetchedForms
                    }
                }
            }
        }
    }
}
