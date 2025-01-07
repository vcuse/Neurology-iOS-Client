import SwiftUI
import CoreData

struct SavedFormsView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: NIHFormEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \NIHFormEntity.date, ascending: false)]
    )
    private var savedForms: FetchedResults<NIHFormEntity>

    @Binding var isNavigatingBack: Bool
    @State private var isShowingNewFormView = false
    @State private var selectedForm: NIHFormEntity?
    @State private var isShowingDetailView = false

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
                        ForEach(savedForms, id: \.self) { form in
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(form.patientName ?? "Unnamed Patient")
                                        .font(.headline)
                                        .foregroundColor(
                                            Color(UIColor { traitCollection in
                                                return traitCollection.userInterfaceStyle == .dark ? .white : .black
                                            })
                                        )
                                    Text(form.date ?? Date(), style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(
                                            Color(UIColor { traitCollection in
                                                return traitCollection.userInterfaceStyle == .dark ? .white : .black
                                            })
                                        )
                                }

                                Spacer()

                                Button(action: {
                                    selectedForm = form
                                    isShowingDetailView = true
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
            .fullScreenCover(isPresented: $isShowingDetailView) {
                if let form = selectedForm {
                    SavedFormDetailView(savedForm: form)
                }
            }
            .onAppear {
                viewContext.refreshAllObjects()
            }
        }
    }
}
