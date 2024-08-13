//
//  PushNotificationManager.swift
//  Neuro App
//
//  Created by David Ferrufino on 8/13/24.
//

import Foundation
import PushKit

class PushNotificationManager: NSObject, PKPushRegistryDelegate {
    var pushRegistry: PKPushRegistry?

    override init() {
        super.init()
        setupPushRegistry()
    }

    private func setupPushRegistry() {
        pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
        pushRegistry?.delegate = self
        pushRegistry?.desiredPushTypes = Set([.voIP]) // or other types
    }

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let deviceToken = pushCredentials.token
        print("Push credentials updated with device token: \(deviceToken)")
        // Send the device token to your server
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        print("Received incoming push with payload: \(payload.dictionaryPayload)")
        // Handle the incoming push
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("Push token invalidated for type: \(type)")
    }
}
