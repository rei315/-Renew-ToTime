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

class QuickMapViewModel {
    
    // MARK: - Property
    
    let disposeBag = DisposeBag()
    let manager = CLLocationManager()
    var didRegionChanged = PublishSubject<CLLocation>()
    var didUpdateLocation = PublishSubject<CLLocation>()
    var didRegionChangedStr = BehaviorRelay<String>(value: "")
    
    // MARK: - Lifecycle
    
    init() {
        configureManager()
    }
    
    // MARK: - Helpers
    
    private func configureManager() {
        manager.requestAlwaysAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//        manager.allowsBackgroundLocationUpdates = true
//        manager.showsBackgroundLocationIndicator = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.startUpdatingLocation()
        
        let updateLocation = manager.rx.didUpdateLocations
        
        updateLocation
            .subscribe(onNext: { [weak self] _ in
                self?.manager.stopUpdatingLocation()
            })
            .disposed(by: disposeBag)
        
        updateLocation
            .map { ($0.locations.last ?? CLLocation(latitude: 0.0, longitude: 0.0)) }
            .bind(to: didUpdateLocation)
            .disposed(by: disposeBag)
        
        didRegionChanged
            .flatMap { self.geocoderLoc(location: $0) }
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
}
