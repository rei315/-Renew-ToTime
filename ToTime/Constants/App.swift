//
//  App.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/07.
//

import Foundation

enum App {}
extension App {

}

enum AppString {}
extension AppString {
    static let Destination = "Destination"
    static let NotificationID = "reach_notification_id"
    static let LocationID = "reach_location_id"
    static let NotificationTitle = "ToTimeNotificationTitle"
    static let NotificationBody = "ToTimeNotificationBody"
    static let NotificationPermissionTitle = "NotificationPermissionTitle"
    static let NotificationPermissionMessage = "NotificationPermissionBody"
    static let LocationDeniedTitle = "LocationDeniedTitle"
    static let LocationDeniedMessage = "LocationDeniedBody"
    static let NotificationErrorTitle = "NotificationErrorTitle"
    static let NotificationErrorMessage = "NotificationErrorBody"
    
    static let Fifty = "50M"
    static let Hundred = "100M"
    static let Thousand = "1000M"
    static let DistanceEdit = "QuickMapDistanceEdit"
    
    static let QuickMapStart = "QuickMapStart"
    static let QuickMapEditValuePlaceHolder = "QuickMapEditValuePlaceHolder"
    static let Enter = "Enter"
    static let QuickMapNamePlaceHolder = "QuickMapNamePlaceHolder"
    static let QuickMapAddFavorite = "QuickMapAddFavorite"
    static let QuickMapDeleteFavorite = "QuickMapDeleteFavorite"
    static let QuickMapModifyFavorite = "QuickMapModifyFavorite"
    
    static let AddressPlaceHolder = "AddressPlaceHolder"
    static let HomeTitle = "HomeTitle"
    static let FavoriteTitle = "FavoriteTitle"
    
    static let InputError = "InputError"
    static let FavoriteAddressEmptyAlertMessage = "FavoriteAddressEmptyAlertMessage"
    static let FavoriteNameEmptyAlertMessage = "FavoriteNameEmptyAlertMessage"
    static let FavoriteImageEmptyAlertMessage = "FavoriteImageEmptyAlertMessage"
    
    static let CreatedComplete = "CreatedComplete"
    static let UpdateComplete = "UpdateComplete"
    static let FavoriteCreated = "FavoriteCreated"
    static let FavoriteUpdated = "FavoriteUpdated"
    
    static let TutorialDoneTitle = "TutorialDoneTitle"
}

enum Url {}
extension Url {
    static let AutoCompleteUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    static let DetailUrl = "https://maps.googleapis.com/maps/api/place/details/json"
    static let ReverseGeocodeUrl = "https://maps.googleapis.com/maps/api/geocode/json"
}

enum NavigationTitle {}
extension NavigationTitle {
    static let DestinationAddress = "SearchAddressTitle"
}
