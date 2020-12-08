//
//  Place.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/08.
//

import Foundation

struct Place {
    let placeID: String
    let placeName: String
    
    init(json: [String:Any]) {
        self.placeID = json["place_id"] as? String ?? ""
        self.placeName = json["description"] as? String ?? ""
    }
}
