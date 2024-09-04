//
//  CallProvider.swift
//  Neuro App
//
//  Created by David Ferrufino on 8/13/24.
//

import Foundation
import CallKit

class CallProvider: NSObject, CXProviderDelegate{
    
    func providerDidReset(_ provider: CXProvider) {
        print("TODO")
    }
    
    
let provider: CXProvider
    
    override init() {
        // Create the provider configuration
        let configuration = CXProviderConfiguration(localizedName: "Neuro App")
        configuration.supportsVideo = true
        //configuration.maximumCallsPerCallGroup = 2
        //configuration.supportedHandleTypes = [.generic]
        
        
        // Optionally configure the appearance of the call interface
        configuration.ringtoneSound = "Ringtone.caf"
        
        // Initialize the CXProvider with the configuration
        provider = CXProvider(configuration: configuration)
        
        super.init()
        
        // Set self as the delegate to handle incoming calls and other provider events
        provider.setDelegate(self, queue: nil)
    }
    
    // Report Incoming Call
    public func reportIncomingCall(id: UUID, handle: String) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: handle)
        provider.reportNewIncomingCall(with: id, update: update) {error in
            if let error = error {
                print(String(describing: error))
            } else {
                print("Call reported")
            }
        }
    }
    
    // Answer a call
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
        return
    }
        
    
    // End a call
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fail()
        return
    }
    
    // What happens when the user accepts the call by pressing the incoming call button? You should implement the method below and call the fulfill method if the call is successful.
        
}

