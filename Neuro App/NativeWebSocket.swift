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
    private var heartbeatTimer: Timer?
    private let pingTimer = 5000
    private var socket: URLSessionWebSocketTask?
    private lazy var urlSession: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    private var keychainHelper: KeychainHelper

    init(url: URL ) {
        // debugPrint("url is ", url)
        keychainHelper = KeychainHelper()
        self.url = url

        super.init()

        print("token is ", KeychainHelper.getToken())
        var request = URLRequest(url: url)
        request.addValue(KeychainHelper.getToken()!, forHTTPHeaderField: "Authorization")

        let socket = urlSession.webSocketTask(with: request)

        self.socket = socket
    }

    func connect() {

        debugPrint("WE ARE CONNECTING WITH URL", url)

        self.socket?.resume()

        self.readMessage()

    }

    private func startHeartBeat() {
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
        Task {
            guard let self = self else { return }
            debugPrint("sent heartbeat")
            await self.sendHeartbeat()
            }
        }
    }

    private func sendHeartbeat() async {
        let payload: [String: Any] = ["type": "HEARTBEAT"]
        do {
            let jsonData = try JSONSerialization.data( withJSONObject: payload)
            try await self.socket?.send(.data(jsonData))

        } catch {
            debugPrint("Error sending heartbeat")
        }
    }
    func send(data: Data) {
        self.socket?.send(.data(data)) { _ in }
        debugPrint("We sent data")
    }

    private func readMessage() {
        self.socket?.receive { [weak self] message in
            guard let self = self else { return }

            switch message {
            case .success(.data(let data)):
                self.delegate?.webSocket(self, didReceiveData: data)
                // debugPrint("message from server", message)
                self.readMessage()
            case .failure:
                self.disconnect()
            case .success(let message):
                        if case let .string(messageString) = message {
                            self.delegate?.handleMessage(message: messageString)

                            // make a way to handle the messages
                            // Now you can parse the messageString as needed
                            // For example, you can parse it as JSON to extract the type, payload, etc.
                        } else {
                            print("Unexpected message type:", message)
                        }

                        // Continue reading messages
                        self.readMessage()
            }
        }
    }

    private func disconnect() {
        self.socket?.cancel()
        self.socket = nil
        self.delegate?.webSocketDidDisconnect(self)
    }
}

@available(iOS 13.0, *)
extension NativeWebSocket: URLSessionWebSocketDelegate, URLSessionDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.delegate?.webSocketDidConnect(self)
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
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
