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
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var formViewModel = StrokeScaleFormViewModel()
    @State private var isNavigatingToSavedForms = false // State variable to control navigation

    var body: some View {
        if signalingClient.isInCall {
            CallView(formViewModel: formViewModel)
        } else {

            NavigationView {
                VStack {
                    /* Can use when we implement login and replace 'user' with username
                    Text("Hello, user!")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .bold()
                        .padding(10)
                        .foregroundColor(Color.black)
                     */
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            authViewModel.logout()
                        }) {
                            Text("Sign out →")
                                .font(.headline)
                                .foregroundColor(Color.black)
                                .bold()
                                .padding(10)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                        }
                        .padding(.bottom, 5)
                    }

                    VStack(spacing: 10) {
                                    Text("Your Peer ID:")
                                        .font(.headline)
                                        .bold()
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(
                                            Color(UIColor { traitCollection in
                                                return traitCollection.userInterfaceStyle == .dark ? .white : .black
                                            })
                                        )

                                    Text(signalingClient.ourPeerID)
                                        .font(.subheadline)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(
                                            Color(UIColor { traitCollection in
                                                return traitCollection.userInterfaceStyle == .dark ? .white : .black
                                            })
                                        )
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    Color(UIColor { traitCollection in
                                        return traitCollection.userInterfaceStyle == .dark ? .black : .white
                                    })
                                )
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
                                            .background(
                                                Color(UIColor { traitCollection in
                                                    return traitCollection.userInterfaceStyle == .dark ? .black : .white
                                                })
                                            )
                                            .cornerRadius(10)
                                            .shadow(radius: 2)
                                            .padding(.horizontal)
                                            .foregroundColor(
                                                Color(UIColor { traitCollection in
                                                    return traitCollection.userInterfaceStyle == .dark ? .white : .black
                                                })
                                            )
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

                    VStack {
                            Button(action: {
                                isNavigatingToSavedForms = true // Trigger navigation
                            }) {
                                Text("NIH Forms")
                                    .font(.headline)
                                    .foregroundColor(
                                        Color(UIColor { traitCollection in
                                            return traitCollection.userInterfaceStyle == .dark ? .white : .black
                                        })
                                    )
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        Color(UIColor { traitCollection in
                                            return traitCollection.userInterfaceStyle == .dark ? .black : .white
                                        })
                                    )
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                            .background(
                                NavigationLink(
                                    destination: SavedFormsView(isNavigatingBack: $isNavigatingToSavedForms),
                                    isActive: $isNavigatingToSavedForms,
                                    label: { EmptyView() }
                                )
                            )
                        }

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
                .background {
                    LinearGradient(colors: [.gray, .white, .gray], startPoint: .topLeading, endPoint: .bottomTrailing)
                                .edgesIgnoringSafeArea(.all)
                                .hueRotation(.degrees(45))
                                .onAppear {
                                    withAnimation(
                                        .easeInOut(duration: 2)
                                        .repeatForever(autoreverses: true)) {}
                                }
                        }
            }
            .navigationBarBackButtonHidden(true)
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
                .foregroundColor(
                    Color(UIColor { traitCollection in
                    return traitCollection.userInterfaceStyle == .dark ? .white : .black
                })
                )

            Spacer()

            Button(action: {
                // Action for call button
            }, label: {
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(
                            Color(UIColor { traitCollection in
                                return traitCollection.userInterfaceStyle == .dark ? .black : .white
                            })
                        )
                    Text("Call")
                        .foregroundColor(
                            Color(UIColor { traitCollection in
                                return traitCollection.userInterfaceStyle == .dark ? .black : .white
                            })
                        )
                }
                .padding(10)
                .background(
                    Color(UIColor { traitCollection in
                        return traitCollection.userInterfaceStyle == .dark ? .white : .black
                    })
                )
                .cornerRadius(8)
            })
            .padding(.trailing, 15)
        }
        .frame(maxWidth: .infinity)
        .background(
            Color(UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? .black : .white
            })
        )
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
