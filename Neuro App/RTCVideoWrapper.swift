//
//  RTCVideoWrapper.swift
//  Neuro App
//
//  Created by David Ferrufino on 8/27/24.
//

import Foundation
import SwiftUI
import WebRTC

struct RTCVideoView: UIViewRepresentable {
    typealias UIViewType = RTCMTLVideoView

    private var videoView = RTCMTLVideoView()

        init(frame: CGRect) {
            self.videoView = RTCMTLVideoView(frame: frame)
            self.videoView.videoContentMode = .scaleAspectFill
        }

        func makeUIView(context: Context) -> RTCMTLVideoView {
            return videoView
        }

        func updateUIView(_ uiView: RTCMTLVideoView, context: Context) {
            // Update the UIView here
        }
}
