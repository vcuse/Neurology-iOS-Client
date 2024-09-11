//
//  RTCVideoWrapper.swift
//  Neuro App
//
//  Created by David Ferrufino on 8/27/24.
//

import Foundation
import WebRTC
import UIKit

class RTCVideoWrapper: UIView, RTCVideoRenderer {
    
    private let videoView: RTCMTLVideoView
    
    override init(frame: CGRect) {
        self.videoView = RTCMTLVideoView(frame: frame)
        super.init(frame: frame)
        
        // Apply horizontal flip for front-facing camera (mirroring)
        self.videoView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        
        self.videoView.contentMode = .scaleAspectFit // Maintain aspect ratio
        self.addSubview(videoView)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        self.videoView = RTCMTLVideoView(frame: .zero)
        super.init(coder: coder)
        
        // Apply horizontal flip for front-facing camera (mirroring)
        self.videoView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        
        self.videoView.contentMode = .scaleAspectFit // Maintain aspect ratio
        self.addSubview(videoView)
        setupConstraints()
    }
    
    func setSize(_ size: CGSize) {
        // Optionally update the size of the video view if needed
    }
    
    func renderFrame(_ frame: RTCVideoFrame?) {
        guard let frame = frame else {
            print("Received nil frame, not rendering.")
            return
        }
        videoView.renderFrame(frame)
    }
    
    private func setupConstraints() {
        videoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            videoView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            videoView.topAnchor.constraint(equalTo: self.topAnchor),
            videoView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func setRenderer(_ renderer: RTCVideoRenderer) {
        //videoView = renderer
    }
}
