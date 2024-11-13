//
//  SignalClient.swift
//  WebRTC
//
//  Created by Stasel on 20/05/2018.
//  Copyright © 2018 Stasel. All rights reserved.
//

import Foundation
import WebRTC
import Combine

private let config = Config.default


protocol SignalClientDelegate: AnyObject {
    func signalClientDidConnect(_ signalClient: SignalingClient)
    func signalClientDidDisconnect(_ signalClient: SignalingClient)
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription)
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate)
}

final class SignalingClient: NSObject, RTCPeerConnectionDelegate, ObservableObject {
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        debugPrint("peerConnection new signaling state: \(stateChanged)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        debugPrint("peerConnection did add stream")
        self.webRTCClient.remoteVideoTrack = stream.videoTracks.first
        
        
        //self.peerConnection.add(stream, streamIds: stream.stream)
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        debugPrint("peerConnection did remove stream")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        debugPrint("peerConnection should negotiate")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        debugPrint("peerConnection new connection state: \(newState)")
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        debugPrint("peerConnection new gathering state: \(newState)")
    }
    
    //when the peerConnection (the connection to the other client thru the server) generates us a candidate, we have to send that candidate to the other client
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        debugPrint("peerConnection found a new candidate: \(candidate)")
        let candidate: [String: Any] = ["candidate": candidate.sdp, "sdpMLineIndex" : candidate.sdpMLineIndex, "sdpMid": candidate.sdpMid as Any]
        let payload: [String: Any] = ["candidate":candidate,"connectionId":self.mediaID, "type":"media" ]
        let message: [String: Any] = ["payload":payload, "type":"CANDIDATE", "dst":self.theirPeerID]
        do{
            let jsonData = try JSONSerialization.data( withJSONObject: message)
            self.webSocket.send(data: jsonData)
        }
        catch{
            print("error with json", error)
        }
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        debugPrint("peerConnection did remove candidate(s)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        debugPrint("peerConnection did open data channel")
        self.webRTCClient.remoteDataChannel = dataChannel
    }
    
    
    
    
    
    private let config = Config.default
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var webSocket: WebSocketProvider
    private var webRTCClient: WebRTCClient
    private var sentAnswer: Bool = false
    weak var delegate: SignalClientDelegate?
    weak var webRTCDelegate: WebRTCClientDelegate?
    private var theirSDP = " "
    private var theirSrc = " "
    private var mediaID = "5435435"
    private var candidateResponses: [Data] = []
    private var candidatesToHandle = [[String: Any]]()
    private var offerMessage = [String: Any]()
    private var connectionId = "5435435"
    var peerConnection: RTCPeerConnection?
    private var theirPeerID = " "
    private var fetchTimer: Timer?
    @Published var ourPeerID = " "
    @Published var onlineUsers: [String] = []
    @Published var isRinging = false
    @Published var isInCall = false
    
    
    
    //Creating the websocket (connection to the signaling server)
    // this will almost always be a native web socket
    init(url: URL) {
        
        self.webRTCClient = WebRTCClient(iceServers: ["stun:stun.l.google.com:19302"])
        if #available(iOS 13.0, *) {
            self.webSocket = NativeWebSocket(url: url)
            
        } else {
            exit(0)
        }
        super.init()
        
        if #available(iOS 13.0, *) {
            self.getAddress(url: url)
            startFetchingOnlineUsers()
        } else {
            // Fallback on earlier versions
        }
        //the delegate is what handles messages from the peerConnection
        //we are saying that the peerConnection messages will output to this class
        self.webRTCClient.peerConnection.delegate = self
    }
    
    deinit {
        fetchTimer?.invalidate()
    }
    
    
    @available(iOS 13.0, *)
    func getAddress(url: URL) -> Void {
        
        //var uniqueID = ""
        let options = PeerJSOption(host: "videochat-signaling-app.ue.r.appspot.com",
                                   port: 443,
                                   path: "/",
                                   key: "your_key_here",
                                   secure: true)
        
        let api = API(options: options, url: url)
        print(api.self)
        Task {
            await api.getAddress(url:url) { newUrl, id, error in
                if let error = error {
                    print("Error retrieving address: \(error)")
                    // Handle the error in your API (e.g., return an error response)
                } else if let newUrl = newUrl {
                    // Use the new URL in your API logic
                    print("Received new URL from getAddress: \(newUrl)")
                    DispatchQueue.main.async { // Ensure this runs on the main thread
                        self.ourPeerID = id ?? "no PeerID"
                    }
                    
                    guard let url = URL(string: newUrl) else { return }
                    self.webSocket = NativeWebSocket(url: url)
                    self.connect()
                    let savedToken = UserDefaults.standard.string(forKey: "deviceToken")
                    
                    let message: [String: Any] = ["type":"IOSCLIENT", "src": self.ourPeerID, "dst": "314", "payload": savedToken as Any]
                    do{
                        let jsonData = try JSONSerialization.data( withJSONObject: message)
                        self.webSocket.send(data: jsonData)
                    }
                    catch{
                        print("error with json", error)
                    }
                    
                }
            }
        }
        
        //print("Unique ID OUTSIDE OF CODE IS ", uniqueID)
        
    }
    func disconnectFromServer() {
        let payload: [String: Any] = ["type": "DISCONNECT", "src" : self.ourPeerID, "payload" : "disconnect"]
        do{
            let jsonData = try  JSONSerialization.data(withJSONObject: payload)
            self.webSocket.send(data: jsonData)
            
        }
        catch {
            print("could not send dc message to the server")
        }
    }
    
    func startFetchingOnlineUsers() {
        fetchTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.fetchOnlineUsers()
        }
    }
    
    func fetchOnlineUsers() {
        guard let url = URL(string: "https://videochat-signaling-app.ue.r.appspot.com/key=peerjs/peers") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching online users: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data recieved")
                return
            }
            
            do {
                if let onlineUsers = try JSONSerialization.jsonObject(with: data, options: []) as? [String] {
                    DispatchQueue.main.async {
                        self?.onlineUsers = onlineUsers
                    }
                }
            } catch {
                print("Error parsing online users: \(error)")
            }
            
        }.resume()
        
    }
    
    func callUser(id: String) {
        print("Calling user with ID: \(id)")
        isRinging = true
        self.theirPeerID = id // Store the destination peer ID for later use

        // Generate a unique data channel ID for this call
        let dataChannelId = createDataChannel()

        // Create an SDP offer using the WebRTCClient's offer method
        webRTCClient.offer { [weak self] sdp in
            guard let self = self else { return }
            
            // Set the local SDP
            self.webRTCClient.peerConnection.setLocalDescription(sdp) { error in
                if let error = error {
                    print("Error setting local SDP: \(error)")
                    return
                }
                
                // Construct the offer message
                let message: [String: Any] = [
                    "dst": id,
                    "payload": [
                        "connectionId": self.connectionId,
                        "sdp": [
                            "type": "offer",
                            "sdp": sdp.sdp,
                        ],
                        "type": "media"
                    ],
                    "type": "OFFER",
                    "src": self.ourPeerID
                ]
                
                // Send the offer message as JSON
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: message)
                    self.webSocket.send(data: jsonData)
                    print("Offer sent to \(id)")
                    print(message)
                    let jsonString = String(data: jsonData, encoding: .utf8)
                    print("JSON data: \(jsonString)")
                } catch {
                    print("Error serializing offer message to JSON: \(error)")
                }
            }
        }
    }
    
    func cancelCall() {
        // implement logic
        print("Cancelling the call")
        isRinging = false
    }
    
    func declineCall() {
        // Notify the remote peer that the call was declined
        let message: [String: Any] = [
            "type": "CALL_DECLINED",
            "src": self.ourPeerID,
            "dst": self.theirPeerID,
            "payload": [
                "reason": "declined"
            ]
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message)
            self.webSocket.send(data: jsonData)
            print("Decline call message sent")
        } catch {
            print("Error sending decline call message: \(error)")
        }
    }
    
    func endCall() {
        // Notify remote peer that we're disconnecting
        let payload: [String: Any] = ["type": "DISCONNECT", "src": self.ourPeerID, "payload": "disconnect"]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload)
            self.webSocket.send(data: jsonData)
        } catch {
            print("Error sending disconnect message to server: \(error)")
        }
        
        // Close connection and clean up
        self.webRTCClient.closePeerConnection()
        
        // Reset the signaling client state
        isRinging = false
        isInCall = false
        
        // Inform delegate about disconnection
        self.delegate?.signalClientDidDisconnect(self)
    
        print("Call disconnected")
    }
    
    func toggleAudioMute(isMuted: Bool) {
        if isMuted {
            webRTCClient.unmuteAudio()
        } else {
            webRTCClient.muteAudio()
        }
    }
    
    func getSignalingClient() -> WebRTCClient{
        return self.webRTCClient
    }
    
    func getOurID() -> String{
        return self.ourPeerID
    }
    
    
    func connect() {
        self.webSocket.delegate = self
        self.webSocket.connect()
    }
    
    private func createDataChannel() -> String {
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        return String(uuid.prefix(14))
    }
    
}


extension SignalingClient: WebSocketProviderDelegate {
    func webSocketDidConnect(_ webSocket: WebSocketProvider) {
        self.delegate?.signalClientDidConnect(self)
    }
    
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider) {
        self.delegate?.signalClientDidDisconnect(self)
        
        // try to reconnect every two seconds
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            debugPrint("Trying to reconnect to signaling server...")
            self.webSocket.connect()
        }
    }
    
    
    
    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data) {
        
        
        
    }
    
    //handle message is where we determine what to do when the server sends us a message
    // basically this is where we answer a call
    
    func handleMessage(message: String){
        
        //we are splitting the received message into 3 variables (just to make it easier to deal with)
        if let (messageType, payload, src) = processReceivedMessage(message: message) {
            // Use messageType, payload, and src as needed
            print("Processed message type:", messageType)
            //candidates come second
            if(messageType == "CANDIDATE"){
                isInCall = true
                    //handleCandidateMessage(payload: payload, src: src)
                
                let candidatePayload = payload
                let iceCandidate = RTCIceCandidate(sdp: self.theirSDP, sdpMLineIndex: candidatePayload["sdpMLineIndex"] as! Int32, sdpMid: candidatePayload["sdpMid"] as? String)
               self.webRTCClient.set(remoteCandidate: iceCandidate){error in
                    if let error = error {
                        debugPrint("Error adding remote ICE candidate: \(error.localizedDescription)")
                    } else {
                        debugPrint("Successfully added remote ICE candidate")
                    }
                }
            }
            
            // Handle ANSWER message (grab the SDP from payload)
            if messageType == "ANSWER" {
                
                if let sdpDict = payload["sdp"] as? [String: Any],
                   let sdp = sdpDict["sdp"] as? String {
                    print("Received SDP in ANSWER:", sdp)
                    
                    // Create an RTCSessionDescription for the answer SDP
                    let sessionDescription = RTCSessionDescription(type: .answer, sdp: sdp)
                    
                    // Set the remote SDP on the peer connection
                    self.webRTCClient.peerConnection.setRemoteDescription(sessionDescription) { error in
                        if let error = error {
                            print("Error setting remote SDP: \(error)")
                            return
                        }
                        self.theirSDP = sdp
                        print("Successfully set remote SDP for ANSWER")
                    }
                } else {
                    print("Failed to extract SDP from ANSWER payload")
                }
            }
        }
    }
    
    func storeOfferMessage(payload: [String: Any], src: String){
        offerMessage = payload
        theirSrc = src
    }
    
    func handleStoredOfferMessage(){
        
    }
    
    
    //handling candidates and adding them to the peer
    func handleCandidateMessage(payload: [String: Any], src: String){
        
        let payload: [String: Any] = ["candidate":payload, "type":"media","connectionId":self.mediaID]
        
        let candidateReponse: [String: Any] = ["type": "CANDIDATE", "payload": payload, "dst":src]
        do{
            let jsonData = try JSONSerialization.data( withJSONObject: candidateReponse)
            isInCall = true
            // candidateResponses.append(jsonData)
           // candidatesToHandle.append(payload)

            //handleIceCandidates(candidate: payload)
        }
        
        catch {
            debugPrint("Error ")
        }
    }
    
    //this is the part where we "answer" their message
    func handleOfferMessage(){
        
        let msg = offerMessage["sdp"] as? [String: Any]
        let sdp = msg?["sdp"]
        
        let connectionID = offerMessage["connectionId"] as! String
        if(hasVideoMedia(sdp: sdp as! String)){
            self.theirSDP = sdp as! String
            self.connectionId = connectionID
            print("Processed sdp:", sdp as Any)
            let sessionDescription = RTCSessionDescription(type: RTCSdpType.offer, sdp: sdp as! String)
            
            if #available(iOS 13.0, *) {
                Task {
                    
                    //first we set the remote sdp (we received an offer)
                    await self.webRTCClient.setRemoteSDP(sessionDescription)
                    //then we create an answer sdp
                    await self.webRTCClient.setPeerSDP(sessionDescription, theirSrc, connectionID) { connectionMessage in
                        if let connectionMessage = connectionMessage {
                            // Use connectionMessage here
                            //print("Connection message:", connectionMessage)
                            do{
                                let jsonData = try JSONSerialization.data( withJSONObject: connectionMessage)
                                //sending our answer sdp
                                debugPrint("we sent our answer ", connectionMessage)
                                self.sentAnswer = true
                                self.webSocket.send(data: jsonData)
                                //self.sendStoredCandidates()
                                
                            }
                            catch{
                                print("error with json", error)
                            }
                        } else {
                            print("Error: Could not set peer SDP")
                        }
                        
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func handleIceCandidates(){
        
        for candidate in candidatesToHandle	{
            let candidatePayload = candidate["candidate"] as! [String: Any]
            let iceCandidate = RTCIceCandidate(sdp: self.theirSDP, sdpMLineIndex: candidatePayload["sdpMLineIndex"] as! Int32, sdpMid: candidatePayload["sdpMid"] as? String)
            self.webRTCClient.set(remoteCandidate: iceCandidate){error in
                if let error = error {
                    debugPrint("Error adding remote ICE candidate: \(error.localizedDescription)")
                } else {
                    debugPrint("Successfully added remote ICE candidate")
                }
            }
        }
        
        
    }
    func setCallConnected(){
        self.isInCall = true
    }
    func sendStoredCandidates(){
        for response in candidateResponses {
            self.webSocket.send(data: response)
        }
    }
    
    //checking if the SDP we received has video chat included (we need this to be true)
    //otherwise the chat will be audio only (we don't want that)
    func hasVideoMedia(sdp: String) -> Bool {
        let sdpLines = sdp.components(separatedBy: .newlines)
        for line in sdpLines {
            if line.hasPrefix("m=video") {
                return true
            }
        }
        return false
    }
    
    
    func createCandidateRTC(_ webSocket: WebSocketProvider, sdp: String){
        let candidate = RTCIceCandidate(sdp: sdp, sdpMLineIndex: 1,
                                        sdpMid: "1")
        
        //print("CANDIDATE SDP:", candidate)
        //setRTCIceCandidate(candidate: candidate)
        
        
        
    }
    
    func setRTCIceCandidate(candidate rtcIceCandidate: RTCIceCandidate){
        
    }
    
    
    func processReceivedMessage(message: String) -> (String, [String: Any], String)? {
        // Print the received message
        print("Received message:", message)
        
        // Initialize variables to hold extracted information
        var messageType = ""
        var payload = [String: Any]()
        var src = ""
        
        // Convert the JSON string to data
        guard let jsonData = message.data(using: .utf8) else {
            print("Error converting message to data")
            return nil
        }
        
        do {
            
            // Deserialize the JSON data into a dictionary
            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                // Access the 'type', 'payload', and 'src' fields from the dictionary
                if let extractedMessageType = json["type"] as? String,
                   let extractedPayload = json["payload"] as? [String: Any],
                   let extractedSrc = json["src"] as? String {
                    // Assign extracted values to variables
                    messageType = extractedMessageType
                    payload = extractedPayload
                    src = extractedSrc
                    
                    
                    
                    if(messageType == "CANDIDATE"){
                        payload = (extractedPayload["candidate"] as? [String: Any])!
                        //media id is the id used to determine what channel messages are sent thru
                        self.mediaID = (extractedPayload["connectionId"] as? String)!
                    }
                    
                    // Print extracted information
                    print("Message type:", messageType)
                    print("Payload:", payload)
                    print("Source:", src)
                    //storing their id for use later
                    self.theirPeerID = src
                } else {
                    print("Error: Missing 'type', 'payload', or 'src' field(s) in the message")
                    return nil
                }
            } else {
                print("Error: Failed to deserialize JSON")
                return nil
            }
        } catch {
            print("Error deserializing JSON:", error)
            return nil
        }
        
        // Return the extracted information as a tuple
        return (messageType, payload, src)
    }
}

