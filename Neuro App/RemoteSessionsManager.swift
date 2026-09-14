//
//  RemoteSessions.swift
//  Neurology-iOS-Client-App
//
//  Created by Edris Afzali on 10/21/25.
//

import Foundation

struct RemoteSession: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var sessionDate: Date
    // Optional session notes
    var notes: String = ""
}

enum SessionManager {
    // Replace with network call later
    static func fetchSessionsFromServer(completion: @escaping ([RemoteSession]) -> Void) {
        // Simulated network delay + SAMPLE data for now
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            let samples: [RemoteSession] = [
                RemoteSession(name: "Sample session 1", sessionDate: Date(), notes: "Blah blah blah."),
                RemoteSession(name: "Sample session 2", sessionDate: Date().addingTimeInterval(-86400), notes: "Testing notes attribute.")
            ]
            completion(samples)
        }
    }
}
