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
        self.addSubview(videoView)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        self.videoView = RTCMTLVideoView(frame: .zero)
        super.init(coder: coder)
        self.addSubview(videoView)
        setupConstraints()
    }
    
    func setSize(_ size: CGSize) {
        print("TODO")
    }
    
    func renderFrame(_ frame: RTCVideoFrame?) {
        print("TODO")
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
