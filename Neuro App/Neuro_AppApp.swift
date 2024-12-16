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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, appDelegate.persistentContainer.viewContext)
                .environmentObject(appDelegate.signalingClient)
        }
    }
}
