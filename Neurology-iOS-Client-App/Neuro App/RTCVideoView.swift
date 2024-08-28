//
//  RTCVideoView.swift
//  Neuro App
//
//  Created by David Ferrufino on 8/27/24.
//

import SwiftUI

struct RTCVideoView: UIViewRepresentable {
    let rtcVideoWrapper: RTCVideoWrapper

    init(frame: CGRect) {
        self.rtcVideoWrapper = RTCVideoWrapper(frame: frame)
    }
    
    func makeUIView(context: Context) -> RTCVideoWrapper {
        return rtcVideoWrapper
    }
    
    func updateUIView(_ uiView: RTCVideoWrapper, context: Context) {
        // Handle any updates if needed
    }
}
