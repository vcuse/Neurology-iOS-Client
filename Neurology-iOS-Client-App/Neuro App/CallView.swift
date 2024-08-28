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
    
    @ObservedObject private var webRTCClient: WebRTCClient
    
    
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
                RTCVideoView(frame: UIScreen.main.bounds)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color.black)
                    .overlay(
                        RTCVideoView(frame: CGRect(origin: .zero, size: UIScreen.main.bounds.size))
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
                                TextField("Type a message...", text: $messageText, onEditingChanged: { isEditing in
                                    self.isEditing = isEditing
                                })
                                .background(Color.white)
                                .cornerRadius(10)
                                
                                
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
                            // Add functionality for the hangup button here
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
                            // Toggle mute functionality
                            self.isMuted.toggle()
                            // Add your functionality for the mute button here
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
    
   
}
