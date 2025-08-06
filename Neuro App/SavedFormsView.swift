import SwiftUI
import CoreData

struct SavedFormsView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @Binding var navigationPath: NavigationPath
    @StateObject var formStore = RemoteFormStore()

    enum FormRoute: Hashable {
        case new
        case detail(form: RemoteStrokeForm, options: [Int])
    }

    class RemoteFormStore: ObservableObject {
        @Published var forms: [RemoteStrokeForm] = []
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [.gray, .white, .gray], startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack {
                        HStack {
                            Button(action: {
                                navigationPath.removeLast()
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
                                navigationPath.append(FormRoute.new)
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

                    // Form List
                    VStack(spacing: 15) {
                        ForEach(formStore.forms) { form in
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(form.name)
                                        .font(.headline)
                                        .foregroundColor(Color(UIColor { $0.userInterfaceStyle == .dark ? .white : .black }))

                                    Text("Date: \(StrokeScaleFormManager.convertDOB(from: form.formDate), style: .date)")
                                        .font(.subheadline)
                                        .foregroundColor(Color(UIColor { $0.userInterfaceStyle == .dark ? .white : .black }))
                                }

                                Spacer()

                                Button(action: {
                                    let options = form.results.prefix(15).map { Int(String($0)) ?? 9 }
                                    navigationPath.append(FormRoute.detail(form: form, options: options))
                                }) {
                                    Text("View")
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
                            .background(Color(UIColor { $0.userInterfaceStyle == .dark ? .black : .white }))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                StrokeScaleFormManager.fetchFormsFromServer { fetchedForms in
                    DispatchQueue.main.async {
                        formStore.forms = fetchedForms
                    }
                }
            }
        }
        .navigationDestination(for: FormRoute.self) { route in
            switch route {
            case .new:
                NewNIHFormView(navigationPath: $navigationPath)

            case .detail(let form, let options):
                SavedFormDetailView(
                    navigationPath: $navigationPath,
                    remoteForm: form,
                    selectedOptions: options
                )
            }
        }
    }
}
