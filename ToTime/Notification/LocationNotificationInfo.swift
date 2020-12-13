//
//  LocationNotificationInfo.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/12.
//

import CoreLocation

struct LocationNotificationInfo {
    
    let notificationId: String
    let locationId: String
    
    let title: String
    let body: String
    let data: [String: Any]?
}
