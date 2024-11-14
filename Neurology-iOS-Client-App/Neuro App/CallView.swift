import SwiftUI
import WebRTC
import CoreData

struct CallView: View {
    @EnvironmentObject var signalingClient: SignalingClient
    @Environment(\.managedObjectContext) private var viewContext
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var formViewModel = StrokeScaleFormViewModel() // ObservedObject for StrokeScaleFormViewModel

    @State private var callUUID = UUID()
    @State private var localRenderer = RTCVideoWrapper(frame: .zero)
    @State private var remoteRenderer = RTCVideoWrapper(frame: .zero)
    @State private var isMuted: Bool = false
    @State private var showChat: Bool = false
    @State private var messageText: String = ""
    @State private var isEditing: Bool = false
    @State private var messageLog: [String] = []
    @State private var showStrokeScaleForm: Bool = false
    @State private var savedForms: [SavedForm] = [] // List to hold saved forms

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Background

            ZStack {
                RTCVideoView(renderer: localRenderer)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color.black)
                    .overlay(
                        RTCVideoView(renderer: remoteRenderer)
                            .aspectRatio(contentMode: .fill)
                            .edgesIgnoringSafeArea(.all)
                    )
                    .onAppear {
                        setupWebRTC()
                    }

                VStack {
                    Spacer()

                    if showChat {
                        VStack {
                            ScrollViewReader { proxy in
                                ScrollView {
                                    VStack(alignment: .leading) {
                                        ForEach(messageLog.indices, id: \.self) { index in
                                            Text("You: \(messageLog[index])")
                                                .padding(5)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .id(index)
                                                .foregroundStyle(Color.black)
                                        }
                                    }
                                    .padding(10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .onAppear {
                                    if let lastIndex = messageLog.indices.last {
                                        withAnimation {
                                            proxy.scrollTo(lastIndex, anchor: .bottom)
                                        }
                                    }
                                }
                                .onChange(of: messageLog.count) {
                                    if let lastIndex = messageLog.indices.last {
                                        withAnimation {
                                            proxy.scrollTo(lastIndex, anchor: .bottom)
                                        }
                                    }
                                }
                            }

                            HStack {
                                TextField("", text: $messageText, onEditingChanged: { isEditing in
                                    self.isEditing = isEditing
                                })
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(10)
                                .foregroundColor(.black)

                                Button(action: {
                                    if !self.messageText.isEmpty {
                                        self.messageLog.append(self.messageText)
                                        self.messageText = ""
                                        self.isEditing = false
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        // Add functionality for sending a message here
                                    }
                                }) {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 26))
                                }
                                .padding(.trailing)
                            }
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(10)
                        }
                        .frame(height: UIScreen.main.bounds.height * 0.225)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 30)
                    }

                    HStack {
                        Button(action: {
                            endCall()
                        }, label: {
                            Image(systemName: "phone.down.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 30))
                                .padding(22)
                                .background(Color.red)
                                .clipShape(Circle())
                        })
                        .frame(width: 60, height: 60)

                        Spacer()

                        Button(action: {
                            toggleMute()
                        }, label: {
                            Image(systemName: self.isMuted ? "mic.slash.fill" : "mic.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 26))
                                .padding(19)
                                .background(self.isMuted ? Color.gray : Color.blue)
                                .clipShape(Circle())
                        })
                        .frame(width: 60, height: 60)

                        Spacer()

                        // NIH Stroke Scale Button
                        Button(action: {
                            showStrokeScaleForm.toggle() // Show the NIH Stroke Scale form
                        }) {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 26))
                                .padding(16)
                                .background(Color.purple)
                                .clipShape(Circle())
                        }
                        .frame(width: 60, height: 60)
                        .sheet(isPresented: $showStrokeScaleForm) {
                            StrokeScaleFormView(
                                isPresented: $showStrokeScaleForm,
                                viewModel: formViewModel,
                                saveForm: saveForm
                            )
                        }

                        Spacer()

                        Button(action: {
                            withAnimation {
                                self.showChat.toggle()
                                if !self.showChat {
                                    self.isEditing = false
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                            }
                        }) {
                            Image(systemName: "message.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 26))
                                .padding(16)
                                .background(Color.green)
                                .clipShape(Circle())
                        }
                        .frame(width: 60, height: 60)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                }
            }
        }
    }

    // Helper functions
    private func setupWebRTC() {
        let webRTC = signalingClient.getSignalingClient()
        webRTC.startCaptureLocalVideo(renderer: localRenderer)
        webRTC.renderRemoteVideo(to: remoteRenderer)
    }

    private func saveForm() {
        // Get the Core Data context from the environment
        let context = viewContext

        // Create a new NIHFormEntity
        let newForm = NIHFormEntity(context: context)
        newForm.date = Date()

        // Collect selected options from each question
        let selectedOptions = formViewModel.questions.map { $0.selectedOption ?? -1 }

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

    private func endCall() {
        signalingClient.endCall()
        appDelegate.endCall()
        isMuted = false
        messageLog.removeAll()
        resetStrokeScaleForm()
    }

    private func resetStrokeScaleForm() {
        for index in $formViewModel.questions.indices {
            formViewModel.questions[index].selectedOption = nil
        }
    }

    private func toggleMute() {
        signalingClient.toggleAudioMute(isMuted: isMuted)
        isMuted.toggle()
    }
}

// The SavedForm struct
struct SavedForm: Identifiable {
    let id = UUID()
    let date: Date
    let formData: [StrokeScaleQuestion]
}
