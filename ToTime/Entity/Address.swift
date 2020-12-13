//
//  Address.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/07.
//

import Foundation
import MapKit
import RxDataSources
// IdentifiableType, Equatable
struct Address {
    var identity: String?
    let title: String
    var location: CLLocation?
    
    init(title: String, latitude: Double, longitude: Double) {
        self.identity = "\(Date())"
        self.title = title
        self.location = CLLocation(latitude: latitude, longitude: longitude)  
    }
    
    init(json: [String:Any]) {
        self.title = json["formatted_address"] as? String ?? ""
        if let geometry = json["geometry"] as? [String:Any] {
            if let location = geometry["location"] as? [String:Any] {
                let lat = location["lat"] as? Double ?? 0.0
                let lon = location["lng"] as? Double ?? 0.0
                self.location = CLLocation(latitude: lat, longitude: lon)
            }
        }
    }
}
