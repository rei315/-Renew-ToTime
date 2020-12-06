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
    var identity: String?
    let name: String
    var location: CLLocation?
    let address: String
    var iconImage: UIImage?
    
    init(name: String, latitude: Double, longitude: Double, address: String, iconImage: UIImage) {
        self.identity = "\(Date().timeIntervalSinceNow)"
        self.name = name
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        self.address = address
        self.iconImage = iconImage
    }
}
