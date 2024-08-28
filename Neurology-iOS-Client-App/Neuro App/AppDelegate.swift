//
//  AppDelegate.swift
//  Neuro App
//
//  Created by David Ferrufino on 8/5/24.
//

import UIKit
import UserNotifications
import PushKit
import CallKit
import AVFoundation

let globalUUID = "com.Neuro-APP.uuid"


class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, PKPushRegistryDelegate, CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        print("reset")
    }
    
    var voipRegistry: PKPushRegistry!

    var signalingClient = SignalingClient(url: URL (string: "wss://videochat-signaling-app.ue.r.appspot.com:443")!)
    var provider: CXProvider!
    
    func checkforUUID() -> String{
        
        // Retrieve UUID from UserDefaults
        if let uuidString = UserDefaults.standard.string(forKey: globalUUID) {
            // If UUID exists in UserDefaults, return it
            return uuidString
        } else {
            // If no UUID is found, generate a new one
            let newUUID = UUID().uuidString
            UserDefaults.standard.set(newUUID, forKey: globalUUID)
            return newUUID
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        if type == .voIP {
            let tokenString = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
            print("VoIP Device Token: \(tokenString)")
            UserDefaults.standard.setValue(tokenString, forKey: "deviceToken")
            // Save or send the VoIP token to your server if needed
        }
        
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        if type == .voIP {
            
            // Handle the incoming VoIP push here
            handleIncomingCall(payload: payload)
        }
    }
    
    
    let pushNotificationManager = PushNotificationManager()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let configuration = CXProviderConfiguration(localizedName: "Neuro App")
        configuration.supportsVideo = true // Enable if your app supports video calls

        configuration.ringtoneSound = "Ringtone.caf" // Provide your custom ringtone sound if needed
        provider = CXProvider(configuration: configuration)
        provider.setDelegate(self, queue: nil)
        
        
        // Custom initialization logic here
        print("App has launched")
        checkforUUID()
        // Configure notification settings
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Notification permission denied: \(String(describing: error))")
            }
        }
        
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                // Access granted
            } else {
                // Access denied
            }
        }

        AVCaptureDevice.requestAccess(for: .audio) { granted in
            if granted {
                // Access granted
            } else {
                // Access denied
            }
        }
                
                
        
        registerForVoIPPushes()
        
        return true
    }
    
    // Handle successful registration with APNs and get the device token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("Device Token: \(tokenString)")
        
        
        
        // Send the token to your server if needed
    }
    
    func registerForVoIPPushes() {
        self.voipRegistry = PKPushRegistry(queue: nil)
        
        self.voipRegistry.delegate = self
        self.voipRegistry.desiredPushTypes = [PKPushType.voIP]
    }
    
    private func handleIncomingCall(payload: PKPushPayload) {
        
        // Extract information from the payload
        let callId = payload.dictionaryPayload["messageFrom"] as? String ?? "unknown"
        
        print("INCOMING CALL")
        let uuid = UUID()
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: "test name")
        update.hasVideo = true
        
        provider.reportNewIncomingCall(with: uuid, update: update){ error in
            // Add your implementation to report the call.
            // ...
            if error == nil {
               // If the system allows the call to proceed, make a data record for it.
               //let newCall = Call(callId, phoneNumber: "test")
                
            }
        }
        //cxProvider.startCall(uuid: callId, handle: <#T##String#>)
    }
    
    // Handle registration failures
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    // Handle incoming notifications when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification received while app is in the foreground: \(notification.request.content.userInfo)")
        completionHandler([.alert, .badge, .sound])
    }
    
    // Handle notification taps and actions
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification tapped: \(response.notification.request.content.userInfo)")
        completionHandler()
    }
    
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        signalingClient.handleOfferMessage()
        signalingClient.handleIceCandidates()
        print("ANSWERING A CALL")
        return
    }
    
    
    

    
    
    
    
}
