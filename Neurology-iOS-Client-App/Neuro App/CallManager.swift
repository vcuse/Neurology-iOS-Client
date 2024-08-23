//
//  CallManager.swift
//  Neuro App
//
//  Created by Lauren Viado on 8/21/24.
//

import Foundation
import CallKit


// CXProvider is responisble for reporting incoming and outgoing calls to the system.
// It provides a way to configure and customize the call UI


class CallManager: NSObject {
    static let shared = CallManager()
    
    
    private let provider: CXProvider
    private let callController = CXCallController()
    
    
    override init() {
        
        let configuration = CXProviderConfiguration(localizedName: "Neuro App")
        configuration.maximumCallGroups = 1
        configuration.supportsVideo = true
        configuration.supportedHandleTypes = [.generic]
        configuration.ringtoneSound = "ringtone.caf" // customize ringtone
        
        provider = CXProvider(configuration: configuration)
        super.init()
        
        provider.setDelegate(self, queue: nil)
        
    }
    
    
    func reportIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((Error?) -> Void)?) {
        
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: handle)
        update.hasVideo = hasVideo
        
        provider.reportNewIncomingCall(with: uuid, update: update, completion: { error in completion?(error)
        })
        
    }
    
    
    func startCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((Error?) -> Void)? = nil) {
        
        let handle = CXHandle(type: .generic, value: handle)
        let startCallAction = CXStartCallAction(call: uuid, handle: handle)
        startCallAction.isVideo = hasVideo
                
        let transaction = CXTransaction(action: startCallAction)
        callController.request(transaction) { error in
            completion?(error)
        }
        
    }
    
    
    func endCall(uuid: UUID, completion: ((Error?) -> Void)? = nil) {
        
        let endCallAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endCallAction)
        callController.request(transaction) { error in
            completion?(error)
        }
        
    }
    
}

extension CallManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        // Handle the reset state, clean up resources if needed
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        // Notify signaling client to start a new call
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        // Notify signaling client to end the call
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        // Notify signaling client to answer the call
        action.fulfill()
    }
}
