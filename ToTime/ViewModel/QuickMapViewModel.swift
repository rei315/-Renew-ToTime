//
//  QuickMapViewModel.swift
//  ToTimer
//
//  Created by 김민국 on 2020/12/06.
//

import RxSwift
import RxCocoa
import RxCoreLocation
import CoreLocation
import Alamofire

enum QuickMapState {
    case search
    case quick
}

class QuickMapViewModel {
    
    // MARK: - Property
    
    let disposeBag = DisposeBag()
    let manager = CLLocationManager()
    var didRegionChanged = PublishSubject<CLLocation>()
    var didUpdateLocation = PublishRelay<CLLocation>()
    let didRegionChangedStr = BehaviorRelay<String>(value: "")
    
    let markIcons = BehaviorRelay<[UIImage]>(value: [])
    
    // MARK: - Lifecycle
    
    init(state: QuickMapState, placeId: String?) {
        configureManager()
        switch state {
        case .quick:
            configureQuick()
        case .search:
            configureSearch(placeId: placeId ?? "")
            break
        }
        fetchIcons()
    }
    
    // MARK: - Helpers
    
    private func fetchIcons() {
        ResourceManager.shared.fetchMarkIcons()
            .toArray()
            .asObservable()
            .bind(to: markIcons)
            .disposed(by: disposeBag)
    }
    
    private func configureSearch(placeId: String) {
        let detail = fetchAddressDetail(placeId: placeId)
        
        detail
            .map { $0.title }
            .subscribe(onNext: { data in print(data) })
            .disposed(by: disposeBag)
        
        detail
            .map { ($0.location ?? CLLocation(latitude: 0.0, longitude: 0.0)) }
            .subscribe(onNext: { [unowned self] location in
                didUpdateLocation.accept(location)
            })
            .disposed(by: disposeBag)
            
    }
    
    private func configureQuick() {
        manager.startUpdatingLocation()
        
        let updateLocation = manager.rx.didUpdateLocations
        updateLocation
            .subscribe(onNext: { [weak self] _ in
                self?.manager.stopUpdatingLocation()
            })
            .disposed(by: disposeBag)
        updateLocation
            .map { ($0.locations.last ?? CLLocation(latitude: 0.0, longitude: 0.0)) }
            .subscribe(onNext: { [unowned self] location in
                didUpdateLocation.accept(location)
            })
//            .bind(to: didUpdateLocation)
            .disposed(by: disposeBag)
    }
    
    private func configureManager() {
        manager.requestAlwaysAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//        manager.allowsBackgroundLocationUpdates = true
//        manager.showsBackgroundLocationIndicator = true
        manager.pausesLocationUpdatesAutomatically = false
        
        didRegionChanged
            .distinctUntilChanged()
            .flatMap { self.fetchReverseGeocode(location: $0) }
//            .flatMap { self.geocoderLoc(location: $0) }
            .map { $0.title }
            .bind(to: didRegionChangedStr)
            .disposed(by: disposeBag)
        
        manager.rx
            .didChangeAuthorization
            .subscribe(onNext: { [weak self] auth in
                switch auth.status {
                case .authorizedAlways:
                    break
                case .authorizedWhenInUse:
                    break
                case .denied:
                    fallthrough
                case .notDetermined:
                    fallthrough
                case .restricted:
                    self?.manager.requestAlwaysAuthorization()
                @unknown default:
                    fatalError()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func geocoderLoc(location: CLLocation) -> Observable<String> {
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
    
    private func fetchReverseGeocode(location: CLLocation) -> Observable<Address> {
        let params: Parameters =
        [
            "latlng":"\(location.coordinate.latitude),\(location.coordinate.longitude)",
            "key":App.GoogleKey,
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
//        ?latlng=40.714224,-73.961452&key=YOUR_API_KEY
    }
    
    private func fetchAddressDetail(placeId: String) -> Observable<Address>{
        let params: Parameters =
        [
            "place_id":placeId,
            "key":App.GoogleKey
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
}
