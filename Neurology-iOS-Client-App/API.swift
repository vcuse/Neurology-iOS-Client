import Foundation


@available(iOS 13.0.0, *)
class API {
    private let options: PeerJSOption

    init(options: PeerJSOption, url: URL) {
        self.options = options
    }

    private func buildRequest(method: String) -> URLRequest? {
        let protocolScheme = options.secure ? "https" : "http"
        let urlString = "\(protocolScheme)://\(options.host):\(options.port)\(options.path)\(options.key)/\(method)"
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        return URLRequest(url: url)
    }

    func retrieveId(completion: @escaping (Result<String, Error>) -> Void) async {
        guard let request = buildRequest(method: "id") else {
            completion(.failure(NSError(domain: "com.yourapp.APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "com.yourapp.APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }

            if httpResponse.statusCode != 200 {
                completion(.failure(NSError(domain: "com.yourapp.APIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Error. Status: \(httpResponse.statusCode)"])))
                return
            }

            if let data = data, let id = String(data: data, encoding: .utf8) {
                completion(.success(id))
                
                return
            } else {
                completion(.failure(NSError(domain: "com.yourapp.APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid data"])))
            }
        }

        task.resume()
        
    }

    @available(iOS 13.0, *)
    func getAddress(url: URL, completion: @escaping (String?, Error?) -> ()) async {

        var uniqueID = ""
        let options = PeerJSOption(host: "videochat-signaling-app.ue.r.appspot.com",
                                   port: 443,
                                   path: "/",
                                   key: "your_key_here",
                                   secure: true)

        let api = API(options: options, url: url)

        await api.retrieveId { result in
            switch result {
            case .success(let id):
                uniqueID = id
                print("Retrieved ID:", uniqueID)

                let newUrl = url.absoluteString + "/" + "peerjs?key=peerjs" + "&id=" + id + "&token=435345"
                completion(newUrl, nil) // Pass newUrl to completion
                //debugPrint("we sent a newURL from API:", newUrl)
                return
            case .failure(let error):
                print("Error retrieving ID:", error)
                completion(nil, error) // Pass error to completion
                
            }
        }
    }

    // Add your listAllPeers() method here following a similar pattern
}
