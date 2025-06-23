//
//  Neuro_AppApp.swift
//  Neuro App
//
//  Created by David Ferrufino on 8/1/24.
//

import SwiftUI

@main
struct Neuro_App: App {

    // Link the AppDelegate to your SwiftUI app
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // AuthViewModel manages login state, shared via Environment
    @StateObject var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if authViewModel.isLoggedIn {

                // User is logged in → go to HomeView
                HomeView()
                    .environment(\.managedObjectContext, appDelegate.persistentContainer.viewContext)
                    .environmentObject(appDelegate.signalingClient!)
                    .environmentObject(authViewModel)
                    .navigationBarBackButtonHidden(true)
            } else {
                // Not logged in → show SignInView
                SignInView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
