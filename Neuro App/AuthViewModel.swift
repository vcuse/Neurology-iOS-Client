//
//  AuthViewModel.swift
//  Neurology-iOS-Client-App
//
//  Created by Lauren Viado on 5/6/25.
//  ViewModel to manage authentication state and logic


import Foundation
import Security

class AuthViewModel: ObservableObject {
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
            self.isLoggedIn = true
        }
    }

    // Function to perform login via POST request
    func login(username: String, password: String) {
        // API endpoint for authentication
        guard let url = URL(string: "https://devbranch-server-dot-videochat-signaling-app.ue.r.appspot.com/key=peerjs/post") else {
            print("Invalid URL")
            return
        }

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
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let tokenString = String(data: data, encoding: .utf8) {
                if let tokenString = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        // Save token and update login status
                        self.token = tokenString
                        self.isLoggedIn = true
                        // Save username to UserDefaults
                        UserDefaults.standard.set(username, forKey: "username")
                        self.isLoggedIn = true
                        
                        if let setCookie = httpResponse.allHeaderFields["Set-Cookie"] as? String {
                            print("🍪 Received Set-Cookie: \(setCookie)")

                            let cookies = HTTPCookie.cookies(
                                withResponseHeaderFields: ["Set-Cookie": setCookie],
                                for: URL(string: "https://videochat-signaling-app.ue.r.appspot.com")!
                            )

                            for cookie in cookies {
                                HTTPCookieStorage.shared.setCookie(cookie)
                                print("Saved cookie: \(cookie.name)=\(cookie.value)")
                            }
                        } else {
                            print("No Set-Cookie header received")
                        }
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
