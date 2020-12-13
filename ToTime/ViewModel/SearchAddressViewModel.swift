//
//  SearchAddressViewModel.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/10.
//

import RxSwift
import RxCocoa
import RxCoreLocation
import CoreLocation
import MapKit
import Alamofire

class SearchAddressViewModel {
    let disposeBag = DisposeBag()
    
    let locatoinManager = CLLocationManager()
    var region: MKCoordinateRegion!
    
    private let searchItems = BehaviorRelay<[String]>(value: [])
    
    let searchText = BehaviorRelay<String?>(value: nil)
    let searchedPlace = BehaviorRelay<[Place]>(value: [])
    
    let model = SearchAddressModel()
    
    init(address: String) {
        configureLocation()
        configureSearch()
        
        searchText.accept(address)
    }
    
    private func configureLocation() {
        locatoinManager.desiredAccuracy = kCLLocationAccuracyBest
        locatoinManager.requestAlwaysAuthorization()
        locatoinManager.startUpdatingLocation()
        
        locatoinManager.rx
            .didUpdateLocations
            .map { $0.locations.first }
            .flatMap(Observable.from(optional: ))
            .subscribe(onNext: { [unowned self] location in
                let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                self.region = MKCoordinateRegion(center: location.coordinate, span: span)
                locatoinManager.stopUpdatingLocation()
            })
            .disposed(by: disposeBag)
    }
    
    private func configureSearch() {
        searchText
            .flatMap(Observable.from(optional: ))
            .flatMap(model.fetchAddressAutoComplete)
            .subscribe(onNext: { [weak self] places in

                self?.searchedPlace.accept(places)
            })
            .disposed(by: disposeBag)
    }        
}
