//
//  ContentView.swift
//  Neuro App
//
//  Created by David Ferrufino on 8/1/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var signalingClient: SignalingClient

    var body: some View {
        Group {
            if signalingClient.isAuthenticated {
                HomeView()
            } else {
                SignInView()
            }
        }
        
    }
}

