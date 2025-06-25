//
//  KeyChainHelper.swift
//  Neurology-iOS-Client-App
//
//  Created by Lauren Viado on 5/6/25.
//

import Foundation
import Security

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

// Utility for securely saving/retrieving authentication token using Keychain
struct KeychainHelper {
    static let service = "com.neuroapp.auth" // customize this identifier

    static func saveTokenAndUsername(_ credentials: Credentials) throws {
        print("Attempting to save credentials...")

        let account = credentials.username
        let passwordData = credentials.password.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: account
            // You might want to add kSecAttrService here for better uniqueness,
            // especially if you have multiple apps or different services within your app
            // kSecAttrService as String: "com.yourapp.servicename"
        ]

        let attributesToUpdate: [String: Any] = [
            kSecValueData as String: passwordData
            // Add any other attributes you want to update
            // kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Try to update the existing item first
        let updateStatus = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

        if updateStatus == errSecSuccess {
            print("Credentials updated successfully!")
        } else if updateStatus == errSecItemNotFound {
            // Item not found, so add it
            var addQuery = query
            addQuery[kSecValueData as String] = passwordData // Add password data for new item
            // Consider adding kSecAttrAccessible here as well for new items
            // addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                print("Error adding new credentials: \(addStatus)")
                throw KeychainError.unhandledError(status: addStatus)
            }
            print("New credentials added successfully!")
        } else {
            // An unexpected error occurred during update
            print("Error updating credentials: \(updateStatus)")
            throw KeychainError.unhandledError(status: updateStatus)
        }
    }

    static func retreiveTokenAndUsername()throws -> Credentials {

        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }

        guard let existingItem = item as? [String: Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8),
            let account = existingItem[kSecAttrAccount as String] as? String
        else {
            throw KeychainError.unexpectedPasswordData
        }
        let credentials = Credentials(username: account, password: password)
        return credentials
    }
//    // Save token to Keychain
//    static func saveToken(_ token: String) {
//        let data = Data(token.utf8)
//
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrService as String: service,
//            kSecAttrAccount as String: "authToken",
//            kSecValueData as String: data,
//        ]
//
//        // Remove any existing token, then save
//        SecItemDelete(query as CFDictionary)
//        SecItemAdd(query as CFDictionary, nil)
//    }
//
//    // Load token from Keychain
//    static func getToken() -> String? {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrService as String: service,
//            kSecAttrAccount as String: "authToken",
//            kSecReturnData as String: true,
//            kSecMatchLimit as String: kSecMatchLimitOne
//        ]
//
//        var result: AnyObject?
//        let status = SecItemCopyMatching(query as CFDictionary, &result)
//
//        guard status == errSecSuccess,
//              let data = result as? Data,
//              let token = String(data: data, encoding: .utf8) else {
//            return nil
//        }
//
//        return token
//    }

    // Delete token from Keychain
    static func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "authToken"
        ]

        SecItemDelete(query as CFDictionary)
    }

    static func deleteTokenAndUsername() {

        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]

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
