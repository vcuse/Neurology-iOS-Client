//
//  StrokeFormManager.swift
//  Neurology-iOS-Client-App
//
//  Created by Lauren Viado on 5/6/25.
//
// A utility for handling stroke scale forms locally and remotely.

import Foundation
import CoreData
import Security

extension Notification.Name {
    static let formsDidUpdate = Notification.Name("formsDidUpdate")
}

struct RemoteStrokeForm: Identifiable, Codable {
    var id: Int
    var name: String
    var dob: String
    var formDate: String
    var results: String
    var username: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, dob, results, username, formDate = "form_date"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        dob = try container.decodeIfPresent(String.self, forKey: .dob) ?? ""
        formDate = try container.decodeIfPresent(String.self, forKey: .formDate) ?? ""
        results = try container.decodeIfPresent(String.self, forKey: .results) ?? ""
        username = try container.decodeIfPresent(String.self, forKey: .username) ?? ""
    }
}

struct StrokeScaleFormManager {
    static var remoteForms: [RemoteStrokeForm] = []
    
    static func fetchFormsFromServer(completion: @escaping ([RemoteStrokeForm]) -> Void) {
        remoteForms.removeAll()
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            print("No username found")
            completion([])
            return
        }

        guard let url = URL(string: "https://videochat-signaling-app.ue.r.appspot.com/key=peerjs/post") else {
            print("Invalid URL")
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("getUsersForms", forHTTPHeaderField: "Action")

        let payload: [String: String] = ["username": username]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        if let cookies = HTTPCookieStorage.shared.cookies(for: url) {
            let cookieHeader = HTTPCookie.requestHeaderFields(with: cookies)
            request.allHTTPHeaderFields?.merge(cookieHeader, uniquingKeysWith: { _, new in new })
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching forms: \(error?.localizedDescription ?? "unknown")")
                completion([])
                return
            }

            do {
                let decoded = try JSONDecoder().decode([RemoteStrokeForm].self, from: data)
                DispatchQueue.main.async {
                        self.remoteForms = decoded
                        completion(decoded)
                    }
                } catch {
                    print("Decoding error: \(error)")
                    completion([])
                }
        }.resume()
    }
    
    static func notifyFormsDidUpdate() {
        NotificationCenter.default.post(name: .formsDidUpdate, object: nil)
    }
    
    static func convertDOB(from string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.date(from: string) ?? Date()
    }
    
    static func saveForm(
        context: NSManagedObjectContext,
        patientName: String,
        dob: Date,
        selectedOptions: [Int]
    ) {
        let username = UserDefaults.standard.string(forKey: "username") ?? ""

        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        var username = "null"
        do {
            username = try KeychainHelper.retreiveTokenAndUsername().username } catch { print("username failed") }
        let payload: [String: Any] = [
            "patientName": patientName,
            "DOB": formatter.string(from: dob),
            "formDate": formatter.string(from: Date()),
            "results": selectedOptions.map { $0 == -1 ? "9" : String($0) }.joined(),
            "username": username
        ]

        let url = AppURLs.strokeScalePostUrl

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("submitStrokeScale", forHTTPHeaderField: "Action")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        let session = URLSession(configuration: {
            let config = URLSessionConfiguration.default
            config.httpCookieStorage = HTTPCookieStorage.shared
            config.httpShouldSetCookies = true
            return config
        }())

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Server error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Server status: \(httpResponse.statusCode)")
            }

            if let data = data, let str = String(data: data, encoding: .utf8) {
                print("Response: \(str)")
            }
        }.resume()
    }

    static func updateForm(
        remoteForm: RemoteStrokeForm,
        patientName: String,
        dob: Date,
        selectedOptions: [Int]
    ) {
        let username = remoteForm.username
        let formID = remoteForm.id

        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"

        let payload: [String: Any] = [
            "patientName": patientName,
            "dob": formatter.string(from: dob),
            "formDate": formatter.string(from: Date()),
            "results": selectedOptions.map { $0 == -1 ? "9" : String($0) }.joined(),
            "username": username,
            "id": formID,
            "action": "updateForm"
        ]

        guard let url = URL(string: "https://videochat-signaling-app.ue.r.appspot.com/key=peerjs/post") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("updateForm", forHTTPHeaderField: "Action")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        let session = URLSession(configuration: {
            let config = URLSessionConfiguration.default
            config.httpCookieStorage = HTTPCookieStorage.shared
            config.httpShouldSetCookies = true
            return config
        }())

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Server error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Server status: \(httpResponse.statusCode)")
            }

            if let data = data, let str = String(data: data, encoding: .utf8) {
                print("Update response: \(str)")
            }
        }.resume()
    }
    
    static func deleteForm(remoteForm: RemoteStrokeForm) {
        let payload: [String: Any] = [
            "id": remoteForm.id,
            "username": remoteForm.username
        ]

        guard let url = URL(string: "https://videochat-signaling-app.ue.r.appspot.com/key=peerjs/post") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("deleteForm", forHTTPHeaderField: "Action")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        if let cookies = HTTPCookieStorage.shared.cookies(for: url) {
            let cookieHeader = HTTPCookie.requestHeaderFields(with: cookies)
            request.allHTTPHeaderFields?.merge(cookieHeader) { _, new in new }
            print("Cookie attached to delete request: \(cookieHeader)")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Server error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Server status: \(httpResponse.statusCode)")
            }

            if let data = data, let responseText = String(data: data, encoding: .utf8) {
                print("Delete response: \(responseText)")
            }
        }.resume()
    }
}
