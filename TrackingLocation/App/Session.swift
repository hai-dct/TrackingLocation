//
//  Session.swift
//  TrackingLocation
//
//  Created by Hai Nguyen H.P. [3] VN.Danang on 5/23/22.
//

import Foundation

class Session {
    
    var locationsSaved: [Location] {
        get {
            if let data = UserDefaults.standard.data(forKey: "locationsSaved") {
                let decoder = JSONDecoder()
                let locations = try? decoder.decode([Location].self, from: data)
                return locations ?? []
            }
            return []
        } set {
            let encoder = JSONEncoder()
            let data = try? encoder.encode(newValue)
            UserDefaults.standard.set(data, forKey: "locationsSaved")
        }
    }
    
    static let shared = Session()
    
    private init() { }
}
