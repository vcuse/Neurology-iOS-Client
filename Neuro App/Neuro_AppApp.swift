//
//  Neuro_AppApp.swift
//  Neuro App
//
//  Created by David Ferrufino on 8/1/24.
//
import SwiftUI

@main
struct Neuro_App: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var authViewModel: AuthViewModel
    @StateObject var signalingClient: SignalingClient
    
    init() {
        // Initialize the signaling client first, as it's a core dependency.
        let client = SignalingClient(url: AppURLs.webSocketURL)
        _signalingClient = StateObject(wrappedValue: client)
        
        // Pass the client to the AuthViewModel's initializer.
        let viewModel = AuthViewModel(signalingClient: client)
        _authViewModel = StateObject(wrappedValue: viewModel)
        
        // Pass the client to the AppDelegate for handling background events.
        self.appDelegate.signalingClient = client
    }
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isLoggedIn {
                HomeView()
                    .environment(\.managedObjectContext, appDelegate.persistentContainer.viewContext)
                    .environmentObject(signalingClient)
                    .environmentObject(authViewModel)
                    .navigationBarBackButtonHidden(true)
            } else {
                SignInView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
