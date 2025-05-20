//
//  AppURLs.swift
//  Neuro App
//
//  Created by David Ferrufino on 5/20/25.
//

import Foundation
struct AppURLs {
    static let baseURL: URL = {
        guard let scheme = getConfigurationValue(forKey: "API_BASE_URL") as? String
        else {
            fatalError("websocket url not found")
        }

        print("baseurl:", scheme)

        return URL(string: scheme)!
    }()

    static let strokeScalePostUrl: URL = {
        guard let scheme = getConfigurationValue(forKey: "API_STROKE_POST_URL") as? String
        else {
            fatalError("websocket url not found")
        }

        print("strokeurl:", scheme)

        return URL(string: scheme)!
    }()

    static let loginUrl: URL = {
        guard let scheme = getConfigurationValue(forKey: "API_LOGIN_URL") as? String
        else {
            fatalError("websocket url not found")
        }

        print("loginurl:", scheme)

        return URL(string: scheme)!
    }()

    static let fetchUsersURL: URL = {
        guard let scheme = getConfigurationValue(forKey: "API_FETCH_ONLINE_USERS") as? String
        else {
            fatalError("websocket url not found")
        }

        return URL(string: scheme)!
    }()

    static let webSocketURL: URL = {
        guard let scheme = getConfigurationValue(forKey: "API_WS_URL") as? String
        else {
            fatalError("websocket url not found")
        }

        return URL(string: scheme)!
    }()

    
    static let hostURL : String = {
        guard let scheme = getConfigurationValue(forKey: "API_HOST") as? String
        else {
            fatalError("API_HOST url not found")
        }
        
    
        
        
        return scheme
    }()
    
    static let portNumber : Int = {
        guard let scheme = getConfigurationValue(forKey: "API_PORT")
        else {
            fatalError("API_HOST url not found")
        }
     
        let number = Int(scheme)
        
        
        return number!
    }()
    
    static let secure : Bool = {
        guard let scheme = getConfigurationValue(forKey: "API_SECURE")
        else {
            fatalError("API_HOST url not found")
        }
        
        if(scheme == "true"){
            return true
        }
        return false
    }()
    

    static func getConfigurationValue(forKey key: String) -> String? {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let value = infoDictionary[key] as? String else {
            return nil
        }
        return value
    }
    
    
}
