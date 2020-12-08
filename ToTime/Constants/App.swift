//
//  App.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/07.
//

import Foundation

enum App {}
extension App {
    static let GoogleKey = ""
}

enum AppString {}
extension AppString {
    static let destination = "목적지"
}

enum Url {}
extension Url {
    static let AutoCompleteUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    static let DetailUrl = "https://maps.googleapis.com/maps/api/place/details/json"
    static let ReverseGeocodeUrl = "https://maps.googleapis.com/maps/api/geocode/json"
}

enum NavigationTitle {}
extension NavigationTitle {
    static let DestinationAddress = "목적지 주소"
}
