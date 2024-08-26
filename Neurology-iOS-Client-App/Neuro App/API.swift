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
        
    }
    
    func generateID() -> String{
        let uuid = UserDefaults.standard.string(forKey: globalUUID)
        print("generated UUID: \(uuid) ")
        return uuid!
    }
    
    @available(iOS 13.0, *)
    func getAddress(url: URL, completion: @escaping (String?, String?, Error?) -> ()) async {
        
                                        
        
        
        
        let id = generateID()
        let newUrl = url.absoluteString + "/" + "peerjs?key=peerjs" + "&id=" + id + "&token=435345"
        completion(newUrl,id, nil) // Pass newUrl to completion
        //debugPrint("we sent a newURL from API:", newUrl)
        
    }
    
    
    // Add your listAllPeers() method here following a similar pattern
}
