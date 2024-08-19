//
//  HomeView.swift
//  Neurology-iOS-Client-App
//
//  Created by Lauren Viado on 7/31/24.
//

import SwiftUI
import UserNotifications




struct HomeView: View {
    
    
    
    private let config = Config.default
    
    @StateObject private var signalingClient = SignalingClient(url: URL (string: "wss://videochat-signaling-app.ue.r.appspot.com:443")!)
    
    
    var body: some View {
        VStack {
            Text("Hello, user!")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .bold()
                .padding(10)
        
            Text("Your Peer ID: (\(signalingClient.ourPeerID)")
                .bold()
                .multilineTextAlignment(.center)
                .padding(.bottom, 25)
            Text("Online Now:")
                .font(.headline)
            
            VStack(alignment: .leading) {
                // filter out our own id
                let filteredOnlineUsers = signalingClient.onlineUsers.filter { $0 != signalingClient.ourPeerID }
                
                if filteredOnlineUsers.isEmpty {
                    Text("Hmm, nobody's here right now!")
                        .padding()
                        .background(Color.yellow)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                } else {
                    VStack(alignment: .leading) {
                        ForEach(filteredOnlineUsers, id: \.self) { user in
                            OnlineUserItemView(uuid: user)
                        }
                    }
                    .background(Color.yellow)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
            }
            .padding(10)
            
            Spacer()
        }
        .overlay(
            Group {
                if signalingClient.isRinging {
                    RingingPopopView(signalingClient: signalingClient)
                }
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .onAppear() {
            signalingClient.fetchOnlineUsers()
        }
    }
}

struct OnlineUserItemView: View {
    let uuid: String
    
    var body: some View{
        HStack {
            Text(uuid)
                .padding(10)
            
            Spacer()
            
            Button(action: {
                //action for call button
            }) {
                Text("Call")
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(10)
            }
            .padding(.trailing)
        }
        .padding(5)
        .background(Color.yellow)
        .cornerRadius(10)
    }
}

struct RingingPopopView: View {
    @ObservedObject var signalingClient: SignalingClient
    
    var body: some View {
        VStack {
            Text("Ringing...")
                .font(.title2)
                .padding(.top, 20)
                .foregroundColor(.white)
            Button(action: {
                signalingClient.cancelCall()
            }) {
                Text("Cancel")
                    .foregroundColor(.red)
                    .padding(5)
                    .background(Color.white)
                    .cornerRadius(10)
            }
            .padding(.bottom, 10)
        }
        .frame(width: 200, height: 100)
        .background(Color.gray)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

#Preview {
    HomeView()
}
