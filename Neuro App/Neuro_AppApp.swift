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

    var body: some Scene {
        WindowGroup {

           HomeView()
             .environment(\.managedObjectContext, appDelegate.persistentContainer.viewContext) // Inject Core Data context
             .environmentObject(appDelegate.signalingClient)
        }
    }
}
