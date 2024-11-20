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

    @EnvironmentObject var signalingClient: SignalingClient
    @StateObject private var formViewModel = StrokeScaleFormViewModel()
    @State private var isSavedFormsPresented: Bool = false // State to control the modal presentation

    var body: some View {
        if signalingClient.isInCall {
            CallView(formViewModel: formViewModel)
        } else {

            NavigationView {
                VStack {
                    Text("Hello, user!")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .bold()
                        .padding(10)
                        .foregroundColor(Color.black)

                    VStack(spacing: 10) {
                                    Text("Your Peer ID:")
                                        .font(.headline)
                                        .bold()
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(Color.black)

                                    Text(signalingClient.ourPeerID)
                                        .font(.subheadline)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.black)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 2)

                                Text("Online Now:")
                                    .font(.headline)
                                    .padding(.top, 20)
                                    .foregroundColor(Color.black)

                                // Online Users List
                                ScrollView {
                                    let filteredOnlineUsers = signalingClient.onlineUsers.filter { $0 != signalingClient.ourPeerID }

                                    if filteredOnlineUsers.isEmpty {
                                        Text("Hmm, nobody's here right now!")
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .shadow(radius: 2)
                                            .padding(.horizontal)
                                            .foregroundColor(Color.black)
                                    } else {
                                        VStack(spacing: 10) {
                                            ForEach(filteredOnlineUsers, id: \.self) { user in
                                                OnlineUserCardView(uuid: user)
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 10)

                                Spacer()

                    NavigationLink(destination: SavedFormsView()) {
                        Text("NIH Forms")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)

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
                .onAppear {
                    signalingClient.fetchOnlineUsers()
                }
                .background(Color(.lightGray))
            }
        }
    }
}

struct OnlineUserCardView: View {
    let uuid: String

    var body: some View {
        HStack {
            Text(uuid)
                .font(.subheadline)
                .padding(.vertical, 10)
                .padding(.leading, 15)
                .foregroundColor(Color.black)

            Spacer()

            Button(action: {
                // Action for call button
            }, label: {
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.white)
                    Text("Call")
                        .foregroundColor(.white)
                }
                .padding(10)
                .background(Color.black)
                .cornerRadius(8)
            })
            .padding(.trailing, 15)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
        .padding(.horizontal)
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
            }, label: {
                Text("Cancel")
                    .foregroundColor(.red)
                    .padding(5)
                    .background(Color.white)
                    .cornerRadius(10)
            })
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
