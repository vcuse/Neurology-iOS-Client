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
    @State private var path = NavigationPath()

    var body: some View {
        if signalingClient.isInCall {
            CallView(formViewModel: formViewModel)
        } else {
            NavigationStack(path: $path) {
                VStack {
                    // Logout button
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

                    // Peer ID
                    VStack(spacing: 10) {
                        Text("Your Peer ID:")
                            .font(.headline)
                            .bold()
                            .multilineTextAlignment(.center)
                            .foregroundColor(adaptiveColor())

                        Text(signalingClient.ourPeerID)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(adaptiveColor())
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(adaptiveBackground())
                    .cornerRadius(10)
                    .shadow(radius: 2)

                    // Active Consultations Header
                    Text("Active Consultations:")
                        .font(.headline)
                        .padding(.top, 20)
                        .foregroundColor(.black)

                    // Online Users List
                    ScrollView {
                        let filteredOnlineUsers = signalingClient.onlineUsers.filter { $0 != signalingClient.ourPeerID }

                        if filteredOnlineUsers.isEmpty {
                            Text("Hmm, nobody's here right now!")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(adaptiveBackground())
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                .padding(.horizontal)
                                .foregroundColor(adaptiveColor())
                        } else {
                            VStack(spacing: 10) {
                                ForEach(filteredOnlineUsers, id: \.self) { user in
                                    OnlineUserCardView(uuid: user, signalingClient: signalingClient)
                                }
                            }
                        }
                    }
                    .padding(.top, 10)

                    Spacer()

                    // NIH Forms Button
                    Button(action: {
                        path.append("savedForms")
                    }) {
                        Text("NIH Forms")
                            .font(.headline)
                            .foregroundColor(adaptiveColor())
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(adaptiveBackground())
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }

                // Navigation destination
                .navigationDestination(for: String.self) { route in
                    switch route {
                    case "savedForms":
                        SavedFormsView(navigationPath: $path)
                    default:
                        EmptyView()
                    }
                }

                // Ringing overlay
                .overlay(
                    Group {
                        if signalingClient.isRinging {
                            RingingPopopView(signalingClient: signalingClient)
                        }
                    }
                )

                // Background
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding()
                .onAppear {
                    signalingClient.fetchOnlineUsers()
                }
                .background(
                    LinearGradient(colors: [.gray, .white, .gray], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .edgesIgnoringSafeArea(.all)
                        .hueRotation(.degrees(45))
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 2)
                                .repeatForever(autoreverses: true)) {}
                        }
                )
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    private func adaptiveColor() -> Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? .white : .black })
    }

    private func adaptiveBackground() -> Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? .black : .white })
    }
}

struct OnlineUserCardView: View {
    let uuid: String
    @ObservedObject var signalingClient: SignalingClient
    var body: some View {
        HStack {
            Text(uuid)
                .font(.subheadline)
                .padding(.vertical, 10)
                .padding(.leading, 15)
                .foregroundColor(Color(UIColor { $0.userInterfaceStyle == .dark ? .white : .black }))

            Spacer()

            Button(action: {
                // Call action
                signalingClient.startCall(id: uuid)
            }, label: {
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(Color(UIColor { $0.userInterfaceStyle == .dark ? .black : .white }))
                    Text("Call")
                        .foregroundColor(Color(UIColor { $0.userInterfaceStyle == .dark ? .black : .white }))
                }
                .padding(10)
                .background(Color(UIColor { $0.userInterfaceStyle == .dark ? .white : .black }))
                .cornerRadius(8)
            })
            .padding(.trailing, 15)
        }
        .frame(maxWidth: .infinity, minHeight: 60)
        .background(Color(UIColor { $0.userInterfaceStyle == .dark ? .black : .white }))
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
