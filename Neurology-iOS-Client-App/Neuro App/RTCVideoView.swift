//
//  RTCVideoView.swift
//  Neuro App
//
//  Created by David Ferrufino on 8/27/24.
//

import SwiftUI

struct RTCVideoView: UIViewRepresentable {
    let renderer: RTCVideoWrapper

    func makeUIView(context: Context) -> RTCVideoWrapper {
        return renderer
    }
    
    func updateUIView(_ uiView: RTCVideoWrapper, context: Context) {
        // Handle any updates if needed
    }
}
