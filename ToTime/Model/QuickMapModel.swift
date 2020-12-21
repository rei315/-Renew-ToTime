//
//  QuickMapModel.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/12.
//

import Foundation
import RxSwift
import RxCocoa
import RxCoreLocation
import CoreLocation
import Alamofire
import RealmSwift

struct QuickMapModel {
    
    // MARK: - Property
    
    let manager: CLLocationManager?
            
    
    // MARK: - Lifecycle
    
    init() {
        manager = CLLocationManager()
        configureManager()
    }
    
    // MARK: - Configure LocationManager
    
    func configureManager() {
        manager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager?.pausesLocationUpdatesAutomatically = false
        manager?.requestAlwaysAuthorization()
    }
        
    // MARK: - Helpers
    
    func startUpdatingLocation() {
        manager?.startUpdatingLocation()
    }
    
    func geocoderLoc(location: CLLocation) -> Observable<String> {
        return Observable.create { observer in
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, _ in
                if let place = placemarks?.first {
                    if (place.administrativeArea != nil) && (place.locality != nil) && (place.thoroughfare != nil) {
                        let area1 = place.administrativeArea!
                        let area2 = place.locality!
                        let area3 = place.thoroughfare!
                        let area = area1 + " " + area2 + " " + area3
                        observer.onNext(area)
                    }
                }
            }
            
            return Disposables.create {
                observer.onCompleted()
            }
        }
    }
    
    func fetchReverseGeocode(location: CLLocation) -> Observable<Address> {
        let params: Parameters =
        [
            "latlng":"\(location.coordinate.latitude),\(location.coordinate.longitude)",
            "key":GoogleKey,
            "location_type": "ROOFTOP"
        ]
        
        return Observable.create { observer in
            AF.request(Url.ReverseGeocodeUrl, parameters: params)
                .responseJSON { (response) in
                    switch response.result {
                    case .success:
                        if let json = response.value as? [String: Any] {
                            if let results = json["results"] as? [[String: Any]] {
                                if let address = results.first {
                                    let address = Address(json: address)
                                    observer.onNext(address)
                                }
                            }
                        }
                    case .failure(let error):
                        observer.onError(error)
                    }
                    observer.onCompleted()
                }
            return Disposables.create {}
        }
    }
    
    func fetchAddressDetail(placeId: String) -> Observable<Address>{
        let params: Parameters =
        [
            "place_id":placeId,
            "key":GoogleKey
        ]
        
        return Observable.create { observer in
            AF.request(Url.DetailUrl, parameters: params)
                .responseJSON { (response) in
                    switch response.result {
                    case .success:
                        if let json = response.value as? [String:Any] {
                            if let result = json["result"] as? [String:Any] {
                                let address = Address(json: result)
                                observer.onNext(address)
                            }
                        }
                    case .failure(let error):
                        observer.onError(error)
                    }
                    observer.onCompleted()
                }
            return Disposables.create {}
        }
    }
    
    func addFavorite(obj: MarkRealm) -> Observable<Bool> {
        Observable.create { observer in
            do {
                let realm = try Realm()
                
                try realm.write {
                    realm.add(obj)
                    observer.onNext(true)
                    observer.onCompleted()
                }
            } catch {
                observer.onError(error)
            }
            return Disposables.create {}
        }
    }
    
    func removeFavorite(mark: Mark?) -> Observable<Bool> {
        Observable.create { observer in
            if let id = mark?.identity {
                let realm = try! Realm()
                if let data = realm.object(ofType: MarkRealm.self, forPrimaryKey: id) {
                    do {
                        try realm.write{
                            realm.delete(data)
                            observer.onNext(true)
                        }
                    } catch {
                        observer.onError(error)
                    }
                } else {
                    observer.onNext(false)
                }
            } else {
                observer.onNext(false)
            }
            observer.onCompleted()
            return Disposables.create {}
        }
    }
    
    func updateFavorite(mark: Mark?, name: String, address: String, iconImageUrl: String, latitude: Double, longitude: Double) -> Observable<Bool> {
        Observable.create { observer in
            if let id = mark?.identity {
                let realm = try! Realm()
                if let data = realm.object(ofType: MarkRealm.self, forPrimaryKey: id) {
                    do {
                        try realm.write {
                            let newData = MarkRealm(identity: data.identity, name: name, latitude: latitude, longitude: longitude, address: address, iconImageUrl: iconImageUrl)
                            realm.add(newData, update: .modified)
                            observer.onNext(true)
                        }
                    } catch {
                        observer.onError(error)
                    }
                } else {
                    observer.onNext(false)
                }
            } else {
                observer.onNext(false)
            }
            observer.onCompleted()
            return Disposables.create {}
        }
    }
}
