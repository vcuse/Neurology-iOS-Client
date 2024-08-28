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
        configuration.supportsVideo = true // Enable if your app supports video calls
        //configuration.maximumCallsPerCallGroup = 2
        //configuration.supportedHandleTypes = [.generic]
        
        
        // Optionally configure the appearance of the call interface
        configuration.ringtoneSound = "Ringtone.caf" // Provide your custom ringtone sound if needed
        
        // Initialize the CXProvider with the configuration
        provider = CXProvider(configuration: configuration)
        
        super.init()
        
        // Set self as the delegate to handle incoming calls and other provider events
        provider.setDelegate(self, queue: nil)
    }
    
    // Start a call
    func startCall(uuid: UUID, handle: String) {
        
    }
        
    
    // End a call
    func endCall(uuid: UUID) {
        
    }
    
    // What happens when the user accepts the call by pressing the incoming call button? You should implement the method below and call the fulfill method if the call is successful.
        
}

