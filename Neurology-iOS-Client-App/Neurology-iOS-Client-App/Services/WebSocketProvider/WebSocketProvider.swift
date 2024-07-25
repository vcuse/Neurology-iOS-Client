//
//  File.swift
//  WebRTC-Demo
//
//  Created by stasel on 15/07/2019.
//  Copyright © 2019 stasel. All rights reserved.
//

import Foundation

protocol WebSocketProvider: AnyObject {
    var delegate: WebSocketProviderDelegate? { get set }
    func connect()
    func send(data: Data)
}

protocol WebSocketProviderDelegate: AnyObject {
    func webSocketDidConnect(_ webSocket: WebSocketProvider)
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider)
    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data)
    func handleMessage(message: String)
    func createCandidateRTC(_ webSocket: WebSocketProvider, sdp: String)
    func processReceivedMessage(message: String) -> (String, [String: Any], String)?
    
}
