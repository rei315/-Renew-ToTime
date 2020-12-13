//
//  MarkRealm.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/11.
//

import Foundation
import RealmSwift

class MarkRealm: Object {
    @objc dynamic var identity: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var address: String = ""
    @objc dynamic var iconImageUrl: String = ""
    
    convenience init(identity: String, name: String, latitude: Double, longitude: Double, address: String, iconImageUrl: String) {
        self.init()
        self.identity = identity
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.iconImageUrl = iconImageUrl        
    }
    
    override class func primaryKey() -> String? {
        return "identity"
    }
}
