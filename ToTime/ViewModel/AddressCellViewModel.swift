////
////  AddressCellViewModel.swift
////  ToTime
////
////  Created by 김민국 on 2020/12/08.
////
//
//import Foundation
//import RxSwift
//import RxCocoa
//import MapKit
//
//class AddressCellViewModel {
//
//    let disposeBag = DisposeBag()
//    
//    let cellRelay = BehaviorRelay<Address?>(value: nil)
//
//    init(searchTitle: String, region: MKCoordinateRegion?) {
//        Observable.just(searchTitle)
//            .map { query -> MKLocalSearch in
//                let request = MKLocalSearch.Request()
//                request.naturalLanguageQuery = query
//                if let region = region {
//                    request.region = region
//                }
//                return MKLocalSearch(request: request)
//            }
//            .flatMap(mapItems)
//            .catchErrorJustReturn([MKMapItem()])
//            .map { $0.first }
//            .flatMap(Observable.from(optional:))
//            .map { $0.placemark }
//            .map { Address(title: $0.title ?? "", latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
//            .bind(to: cellRelay)
//            .disposed(by: disposeBag)
//    }
//
//    func mapItems(for searchRequest: MKLocalSearch) -> Observable<[MKMapItem]> {
//        return Observable.create { obserer in
//            searchRequest.start { (response, error) in
//                if let error = error {
//                    obserer.onError(error)
//                } else {
//                    obserer.onNext(response?.mapItems ?? [])
//                    obserer.onCompleted()
//                }
//            }
//
//            return Disposables.create {
//                searchRequest.cancel()
//            }
//        }
//    }
//}
