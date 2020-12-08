//
//  HomeViewModel.swift
//  ToTimer
//
//  Created by 김민국 on 2020/12/06.
//

import RxSwift
import RxCocoa
import RxCoreLocation
import CoreLocation
import MapKit
import Alamofire

class HomeViewModel {
    
    // MARK: - Property
    
    let disposeBag = DisposeBag()
    
    let items = BehaviorRelay<[MarkSectionModel]>(value: [])
    
    let locatoinManager = CLLocationManager()
    var region: MKCoordinateRegion!
    
    private let searchItems = BehaviorRelay<[String]>(value: [])
    
    let searchText = BehaviorRelay<String?>(value: nil)
    let searchedPlace = BehaviorRelay<[Place]>(value: [])
    
//    let request = MKLocalSearch.Request()
//    var localSearch: MKLocalSearch?
//    let searchCompleter = MKLocalSearchCompleter()
    
    // MARK: - Lifecycle
    
    init() {
        var sections: [MarkSectionModel] = []
                
//        let test1 = MarkSectionItem.mark(mark: Mark(name: "hi", latitude: 0.0, longitude: 0.0, address: "", iconImage: #imageLiteral(resourceName: "mark00086")))
//        let test2 = MarkSectionItem.mark(mark: Mark(name: "hi", latitude: 0.0, longitude: 0.0, address: "", iconImage: #imageLiteral(resourceName: "mark00015")))
//        let test3 = MarkSectionItem.mark(mark: Mark(name: "hi", latitude: 0.0, longitude: 0.0, address: "", iconImage: #imageLiteral(resourceName: "mark00015")))
//        let test4 = MarkSectionItem.mark(mark: Mark(name: "hi", latitude: 0.0, longitude: 0.0, address: "", iconImage: #imageLiteral(resourceName: "mark00015")))
//        let test5 = MarkSectionItem.mark(mark: Mark(name: "hi", latitude: 0.0, longitude: 0.0, address: "", iconImage: #imageLiteral(resourceName: "mark00015")))
//        let test6 = MarkSectionItem.mark(mark: Mark(name: "hi", latitude: 0.0, longitude: 0.0, address: "", iconImage: #imageLiteral(resourceName: "mark00015")))
//        let test7 = MarkSectionItem.mark(mark: Mark(name: "hi", latitude: 0.0, longitude: 0.0, address: "", iconImage: #imageLiteral(resourceName: "mark00015")))
//        let test8 = MarkSectionItem.mark(mark: Mark(name: "hi", latitude: 0.0, longitude: 0.0, address: "", iconImage: #imageLiteral(resourceName: "mark00015")))
//        let section = MarkSectionModel(model: .mark, items: [test1,test2,test3,test4,test5,test6,test7,test8])
        let blank = MarkSectionItem.blank
        let section = MarkSectionModel(model: .mark, items: [blank])
        sections.append(section)
        items.accept(sections)
        
        configureLocation()
        configureSearch()
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
            .flatMap(fetchAddressAutoComplete)
            .subscribe(onNext: { [weak self] places in
                self?.searchedPlace.accept(places)
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchAddressAutoComplete(address: String) -> Observable<[Place]> {
        let params: Parameters =
            [   "input":address,
                "types":"geocode|establishment",
                "key":App.GoogleKey
            ]
        
        return Observable.create { observer in
            AF.request(Url.AutoCompleteUrl, parameters: params)
                .responseJSON { (response) in
                    switch response.result {
                    case .success:
                        if let json = response.value as? [String: Any] {
                            if let predictions = json["predictions"] as? [[String:Any]] {
                                let places = predictions
                                    .map { Place(json: $0) }
                                observer.onNext(places)
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
