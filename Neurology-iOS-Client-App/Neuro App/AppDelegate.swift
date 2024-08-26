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

let globalUUID = "com.Neuro-APP.uuid"


class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, PKPushRegistryDelegate {
    var voipRegistry: PKPushRegistry!
    var cxProvider = CallProvider()
    
    var signalingClient = SignalingClient(url: URL (string: "wss://videochat-signaling-app.ue.r.appspot.com:443")!)
    
    
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
        let callId = payload.dictionaryPayload["callId"] as? String ?? "unknown"
            
        print("INCOMING CALL")	
        
        let uuid = UUID()
        let update = CXCallUpdate()
        
        cxProvider.provider.reportNewIncomingCall(with: uuid, update: update){ error in
            // Add your implementation to report the call.
            // ...
        }
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
    
    
}
