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

struct StrokeScaleFormManager {
    static func saveForm(
        context: NSManagedObjectContext,
        patientName: String,
        dob: Date = Date(timeIntervalSince1970: 0),
        selectedOptions: [Int]
    ) {
        let newForm = NIHFormEntity(context: context)
        newForm.date = Date()
        newForm.patientName = patientName
        newForm.dob = dob

        do {
            let encoded = try JSONEncoder().encode(selectedOptions)
            newForm.selectedOptions = encoded

            DispatchQueue.main.async {
                do {
                    try context.save()
                    print("Saved locally.")
                } catch {
                    print("Failed to save locally: \(error)")
                }
            }
        } catch {
            print("Failed to encode options: \(error)")
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"

        let payload: [String: Any] = [
            "patientName": patientName,
            "DOB": formatter.string(from: dob),
            "formDate": formatter.string(from: Date()),
            "results": selectedOptions.map { String($0) }.joined(),
            "username": KeychainHelper.getUsername()!
        ]

        let url = AppURLs.strokeScalePostUrl

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("submitStrokeScale", forHTTPHeaderField: "Action")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            print("JSON encode error: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
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
}
