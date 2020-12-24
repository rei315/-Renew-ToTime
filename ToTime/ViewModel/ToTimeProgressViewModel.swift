//
//  ToTimeProgressViewModel.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/12.
//

import RxSwift
import RxCoreLocation
import CoreLocation

class ToTimeProgressViewModel {
    
    // MARK: - Property
    
    let locationManager: CLLocationManager
    let locationNotificationScheduler: LocationNotificationScheduler
    
    let disposeBag = DisposeBag()
    
    let address: String
    let location: CLLocation
    let distance: Int
    
    let didArrivedLocation = BehaviorSubject<Void?>(value: nil)
    
    // MARK: - Lifecycle
    
    init(address: String, location: CLLocationCoordinate2D, distance: Int) {
        self.address = address
        self.location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        self.distance = distance
        
        locationManager = CLLocationManager()
        locationNotificationScheduler = LocationNotificationScheduler()
        configureManager()
        didUpdateLocations()
    }
    
    // MARK: - Helpers
    
    func startLocationNotification() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.showsBackgroundLocationIndicator = false
    }
    
    func stopLocationNotification(info: LocationNotificationInfo) {
        locationManager.stopUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.showsBackgroundLocationIndicator = false
        locationNotificationScheduler.request(with: info)
    }
    
    private func configureManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    private func didUpdateLocations() {
        locationManager.rx.didUpdateLocations
            .map { $0.locations.last }
            .flatMap(Observable.from(optional: ))
            .subscribe(onNext: { [weak self] loc in
                if let setLocation = self?.location, let setDistance = self?.distance  {
                    let dis = loc.distance(from: setLocation)
                    if (dis < Double(setDistance)) {
                        self?.didArrivedLocation.onNext(())
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}
