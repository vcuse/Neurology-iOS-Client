//
//  NativeSocketProvider.swift
//  WebRTC-Demo
//
//  Created by stasel on 15/07/2019.
//  Copyright © 2019 stasel. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

@available(iOS 13.0, *)
class NativeWebSocket: NSObject, WebSocketProvider {

    var delegate: WebSocketProviderDelegate?
    private let url: URL
    private var heartbeatTimer: DispatchSourceTimer?
    private let heartbeatQueue = DispatchQueue(label: "ws.heartbeat.queue", qos: .utility)
    private let heartbeatInterval: TimeInterval = 5
    private let pingTimer = 5000
    private var socket: URLSessionWebSocketTask?
    private lazy var urlSession: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    private var keychainHelper: KeychainHelper

    init(url: URL ) {
        // debugPrint("url is ", url)
        keychainHelper = KeychainHelper()
        self.url = url

        super.init()

        // print("token is ", KeychainHelper.getToken()!)
        var request = URLRequest(url: url)

        do { try
            request.addValue(KeychainHelper.retreiveTokenAndUsername().password, forHTTPHeaderField: "Authorization")
        } catch { print("no values in keychainhelper")}
        do { try
            print("PASSWORD IN KEYCHAIN IS", KeychainHelper.retreiveTokenAndUsername().password)
        } catch { print("no values in keychainhelper")}
        let socket = urlSession.webSocketTask(with: request)

        self.socket = socket
    }

    func connect() {
        debugPrint("WE ARE CONNECTING WITH URL", url)
        self.socket?.resume()
    }

    private func startHeartBeat() {
        stopHeartBeat()

        let timer = DispatchSource.makeTimerSource(queue: heartbeatQueue)
        timer.schedule(deadline: .now() + heartbeatInterval, repeating: heartbeatInterval)
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            Task { await self.sendHeartbeat() }
        }
        timer.resume()
        heartbeatTimer = timer
        debugPrint("Heartbeat started")
    }
    
    private func sendHeartbeat() async {
        guard let socket = self.socket else {
            debugPrint("Heartbeat skipped: socket is nil")
            return
        }

        let payload: [String: Any] = ["type": "HEARTBEAT"]
        do {
            let data = try JSONSerialization.data(withJSONObject: payload)
            try await socket.send(.data(data))
            debugPrint("sent heartbeat")
        } catch {
            debugPrint("Error sending heartbeat: \(error)")
        }
    }

    private func stopHeartBeat() {
        heartbeatTimer?.cancel()
        heartbeatTimer = nil
        debugPrint("Heartbeat stopped")
    }

    private func readMessage() {
        self.socket?.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(.data(let data)):
                self.delegate?.webSocket(self, didReceiveData: data)
                self.readMessage()

            case .success(let message):
                if case let .string(string) = message {
                    self.delegate?.handleMessage(message: string)
                } else {
                    debugPrint("Unexpected message type: \(message)")
                }
                self.readMessage()

            case .failure(let error):
                debugPrint("WebSocket receive error: \(error)")
                self.disconnect()
            }
        }
    }

    private func disconnect() {
        stopHeartBeat()
        self.socket?.cancel()
        self.socket = nil
        self.delegate?.webSocketDidDisconnect(self)
    }
    
    func send(data: Data) {
        socket?.send(.data(data)) { error in
            if let error = error {
                debugPrint("Send error: \(error)")
            } else {
                debugPrint("We sent data")
            }
        }
    }
}

@available(iOS 13.0, *)
extension NativeWebSocket: URLSessionWebSocketDelegate, URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol `protocol`: String?) {
        debugPrint("WebSocket did open")
        self.delegate?.webSocketDidConnect(self)

        // Start both once the connection is confirmed
        self.startHeartBeat()
        self.readMessage()
    }

    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                    reason: Data?) {
        debugPrint("WebSocket did close with code \(closeCode)")
        // Single point of cleanup
        self.disconnect()
    }
}

// Define the equivalent of ServerMessageType enum
enum ServerMessageType: String {
    case answer = "ANSWER"
    case candidate = "CANDIDATE"
    // Add other message types as needed
}

// Define the ServerMessage class
class ServerMessage {
    let type: ServerMessageType
    let payload: Any // Use appropriate type for payload
    let src: String

    init(type: ServerMessageType, payload: Any, src: String) {
        self.type = type
        self.payload = payload
        self.src = src
    }
}
