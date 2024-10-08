//
//  CallView.swift
//  Neurology-iOS-Client-App
//
//  Created by Lauren Viado on 7/31/24.
//

import SwiftUI
import WebRTC

struct CallView: View {
    @EnvironmentObject var signalingClient: SignalingClient
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    //@ObservedObject private var webRTCClient: WebRTCClient
    
    @State private var callUUID = UUID()
    @State private var localRenderer = RTCVideoWrapper(frame: .zero)
    @State private var remoteRenderer = RTCVideoWrapper(frame: .zero)
    @State private var isMuted: Bool = false
    @State private var showChat: Bool = false
    @State private var messageText: String = ""
    @State private var isEditing: Bool = false
    @State private var messageLog: [String] = []
    
    
    var body: some View {
        ZStack {
            // Temp background for the call view
            Color.black.edgesIgnoringSafeArea(.all)
            
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
                                    // Scroll to the last message when the view appears
                                    if let lastIndex = messageLog.indices.last {
                                        withAnimation {
                                            proxy.scrollTo(lastIndex, anchor: .bottom)
                                        }
                                    }
                                }
                                .onChange(of: messageLog.count) {
                                    // scroll to last message
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
                        }) {
                            Image(systemName: "phone.down.fill")
                                .foregroundColor(.white)
                                .font(.system(size:30))
                                .padding(22)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                        .frame(width: 60, height: 60)
                        
                        Spacer()
                        
                        Button(action: {
                            toggleMute()
                        }) {
                            Image(systemName: self.isMuted ? "mic.slash.fill" : "mic.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 26))
                                .padding(19)
                                .background(self.isMuted ? Color.gray : Color.blue)
                                .clipShape(Circle())
                        }
                        .frame(width: 60, height: 60) // Ensure buttons are the same size
                        
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
                        .frame(width: 60, height: 60) // Ensure buttons are the same size
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                }
            }
        }
        
        
        
    }
    
    private func setupWebRTC() {
        var webRTC = signalingClient.getSignalingClient()
        
        webRTC.startCaptureLocalVideo(renderer: localRenderer)
        webRTC.renderRemoteVideo(to: remoteRenderer)
    }
    
    private func toggleMute() {
        signalingClient.toggleAudioMute(isMuted: isMuted)
        isMuted.toggle()
    }
    
    // Ends call and resets call variables
    private func endCall() {
        // Add this line to ensure this method is triggered
        print("End Call button pressed in CallView")

        // End WebRTC connection
        signalingClient.endCall()

       
        appDelegate.endCall()  // Call the AppDelegate's endCall method
        

        // Clean up UI in CallView
        isMuted = false
        messageLog.removeAll()
    }

    
   
}
