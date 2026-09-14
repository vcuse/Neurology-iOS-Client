//
//  Config.swift
//  Neurology-iOS-Client-App
//
//  Created by David Ferrufino on 8/1/24.
//

import Foundation

// Set this to the machine's address which runs the signaling server. Do not use 'localhost' or '127.0.0.1'

private let defaultSignalingServerUrl = AppURLs.webSocketURL

// We use Google's public stun servers. For production apps you should deploy your own stun/turn servers.
private let defaultIceServers = ["stun:stun.l.google.com:19302"]

struct Config {
        let webRTCIceServer: [String]
        let signalingServerUrl: URL

        static let `default` = Config(signalingServerUrl: defaultSignalingServerUrl, webRTCIceServer: defaultIceServers)
}
