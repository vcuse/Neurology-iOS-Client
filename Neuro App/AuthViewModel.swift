//
//  AuthViewModel.swift
//  Neurology-iOS-Client-App
//
//  Created by Lauren Viado on 5/6/25.
//  ViewModel to manage authentication state and logic

import Foundation
import Security
import SwiftUI

class AuthViewModel: ObservableObject {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
   var username: String? {
        didSet {
            if let token = token {
                KeychainHelper.saveUsername(token)
            } else {
                KeychainHelper.deleteUsername()
            }
        }
    }

    @Published var isLoggedIn = false
    @Published var token: String? {
        didSet {
            if let token = token {
                KeychainHelper.saveToken(token)
            } else {
                KeychainHelper.deleteToken()
            }
        }
    }

    // On init, try to load token from Keychain to keep user signed in
    init() {
        if let savedToken = KeychainHelper.getToken() {
            self.token = savedToken
            self.appDelegate.createSignalingClient()
            self.isLoggedIn = true

        }
    }

    // Function to perform login via POST request
    func login(username: String, password: String) {
        // API endpoint for authentication
        let url = AppURLs.loginUrl

        // Prepare the URLRequest with headers and JSON body
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Content type JSON
        request.setValue("login", forHTTPHeaderField: "Action") // Custom header indicating login

        // Body with credentials
        let credentials = ["username": username, "password": password]

        do {
            // Convert the dictionary to JSON data
            request.httpBody = try JSONSerialization.data(withJSONObject: credentials, options: [])
        } catch {
            print("Failed to encode credentials: \(error)")
            return
        }

        // Create the data task
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            // Check for errors or missing data
            guard let data = data, error == nil else {
                print("Login request failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Handle response, assuming a token string is returned in plain text
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("response", httpResponse.allHeaderFields)
                let tokenToParse = httpResponse.value(forHTTPHeaderField: "Set-Cookie")
                print("cookie value", httpResponse.value(forHTTPHeaderField: "Set-Cookie")!)

                // getting the JWT token and formatting it (it comes w extra strings from the server so we need to remove them)
                if let tokenString = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        // Save token and update login status
                        // Token begins at 14th char in the msg 
                        let lowerBound = tokenToParse!.index(tokenToParse!.startIndex, offsetBy: 14)
                        let upperLimit = tokenToParse!.firstIndex(of: ";")
                        self.username = username
                        self.token = String(tokenToParse![lowerBound..<upperLimit!])
                        self.isLoggedIn = true

                        // Optional: Save token to Keychain for persistence
                        print("login token = ", self.token!)

                    }

                }
            } else {
                print("Login failed or bad response: \(response.debugDescription)")
            }
        }.resume() // Start the request
    }

    // Log out and clear saved token
    func logout() {
        self.token = nil
        self.isLoggedIn = false
    }

}
