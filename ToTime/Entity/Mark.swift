//
//  Mark.swift
//  ToTimer
//
//  Created by 김민국 on 2020/12/05.
//

import UIKit
import MapKit
import RxDataSources

struct Mark: IdentifiableType, Equatable {
    
    typealias Identity = String
    var identity: String {
        return id
    }
    
    let id: String
    let name: String
    var location: CLLocation?
    let address: String
    var iconImage: String
    
    init(identity: String, name: String, latitude: Double, longitude: Double, address: String, iconImage: String) {
        self.id = identity
        self.name = name
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        self.address = address        
        self.iconImage = iconImage
    }
    
    
}
