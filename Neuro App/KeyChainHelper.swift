//
//  KeyChainHelper.swift
//  Neurology-iOS-Client-App
//
//  Created by Lauren Viado on 5/6/25.
//

import Foundation
import Security

// Utility for securely saving/retrieving authentication token using Keychain
struct KeychainHelper {
    static let service = "com.neuroapp.auth" // customize this identifier

    // Save token to Keychain
    static func saveToken(_ token: String) {
        let data = Data(token.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "authToken",
            kSecValueData as String: data
        ]

        // Remove any existing token, then save
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    // Load token from Keychain
    static func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "authToken",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }

        return token
    }

    // Delete token from Keychain
    static func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "authToken"
        ]

        SecItemDelete(query as CFDictionary)
    }

    // Save token to Keychain
    static func saveUsername(_ token: String) {
        let data = Data(token.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassIdentity,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "username",
            kSecValueData as String: data
        ]

        // Remove any existing token, then save
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    // Load token from Keychain
    static func getUsername() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassIdentity,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "username",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }

        return token
    }

    // Delete token from Keychain
    static func deleteUsername() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassIdentity,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "username"
        ]

        SecItemDelete(query as CFDictionary)
    }

}
