//
//  SessionsView.swift
//  Neurology-iOS-Client-App
//
//  Created by Edris Afzali on 10/14/25.
//

import SwiftUI

struct SavedSessionsView: View {

    @Binding var navigationPath: NavigationPath

    // Mirror your NIH pattern: an inner store that publishes an array
    @StateObject var sessionStore = RemoteSessionStore()

    // Routes mirror your FormRoute style
    enum SessionRoute: Hashable {
        case new
        case detail(session: RemoteSession)
    }

    // Simple store like your RemoteFormStore
    class RemoteSessionStore: ObservableObject {
        @Published var sessions: [RemoteSession] = []
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [.gray, .white, .gray],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
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
                                navigationPath.append(SessionRoute.new)
                            }) {
                                Text("New Session")
                                    .foregroundColor(.black)
                                    .font(.title3)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)

                        Text("Saved Sessions")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.black)
                            .padding(.leading)
                            .padding(.top, 5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Session List
                    VStack(spacing: 15) {
                        ForEach(sessionStore.sessions) { session in
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(session.name)
                                        .font(.headline)
                                        .foregroundColor(Color(UIColor { $0.userInterfaceStyle == .dark ? .white : .black }))

                                    Text("Date: \(session.sessionDate, style: .date)")
                                        .font(.subheadline)
                                        .foregroundColor(Color(UIColor { $0.userInterfaceStyle == .dark ? .white : .black }))
                                }

                                Spacer()

                                Button(action: {
                                    navigationPath.append(SessionRoute.detail(session: session))
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
                // Fetch sessions on appear
                SessionManager.fetchSessionsFromServer { fetched in
                    DispatchQueue.main.async {
                        sessionStore.sessions = fetched
                    }
                }
            }
        }
        .navigationDestination(for: SessionRoute.self) { route in
            switch route {
            case .new:
                NewSessionView_Skeleton(navigationPath: $navigationPath)

            case .detail(let session):
                SavedSessionDetailView_Skeleton(navigationPath: $navigationPath, session: session)
            }
        }
    }
}

// Temporary stub for compilation
struct NewSessionView_Skeleton: View {
    @Binding var navigationPath: NavigationPath
    var body: some View {
        VStack(spacing: 16) {
            Text("New Session (Skeleton)")
                .font(.title2)
            Button("Done") { navigationPath.removeLast() }
        }
        .padding()
    }
}

struct SavedSessionDetailView_Skeleton: View {
    @Binding var navigationPath: NavigationPath
    let session: RemoteSession
    var body: some View {
        VStack(spacing: 16) {
            Text("Session Detail (Skeleton)")
                .font(.title2)
            Text(session.name)
            Text(session.sessionDate.formatted(date: .abbreviated, time: .shortened))
            Button("Back") { navigationPath.removeLast() }
        }
        .padding()
    }
}
