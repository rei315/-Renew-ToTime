//
//  QuickMapViewModel.swift
//  ToTimer
//
//  Created by 김민국 on 2020/12/06.
//

import RxSwift
import RxCocoa
import CoreLocation

enum QuickMapState {
    case search
    case quick
    case favorite
}

class QuickMapViewModel {
    
    typealias UpdateData = (name: String, address: String, iconImageUrl: String, latitude: Double, longitude: Double)
    
    // MARK: - Property
    
    let disposeBag = DisposeBag()
    
    let model = QuickMapModel()
    
    var didRegionChanged = PublishSubject<CLLocation>()
    var didUpdateLocation = PublishRelay<CLLocation>()
    let didRegionChangedStr = BehaviorRelay<String>(value: "")
    
    var didCreateTapped = BehaviorRelay<MarkRealm?>(value: nil)
    var didDeleteTapped = BehaviorRelay<Void?>(value: nil)
    var didUpdateTapped = BehaviorRelay<UpdateData?>(value: nil)
    
    let didCreateCompleted = PublishSubject<Bool>()
    let didDeleteCompleted = PublishSubject<Bool>()
    let didUpdateCompleted = PublishSubject<Bool>()
    
    let state: QuickMapState
    let placeId: String?
    let realmMark: Mark?
        
    let permissionError = BehaviorRelay<Void?>(value: nil)
    
    // MARK: - Lifecycle
    
    init(state: QuickMapState, placeId: String? = nil, mark: Mark? = nil) {
        self.state = state
        self.placeId = placeId
        self.realmMark = mark
        
        configureManager()
        configureButtonState(state: state)
    }
    
    func configureButtonState(state: QuickMapState) {
        if state == .favorite {
            didUpdateTapped
                .flatMap(Observable.from(optional: ))
                .flatMap{ [unowned self] mark in
                    model.updateFavorite(mark: self.realmMark, name: mark.name, address: mark.address, iconImageUrl: mark.iconImageUrl, latitude: mark.latitude, longitude: mark.longitude)
                }
                .bind(to: didUpdateCompleted)
                .disposed(by: disposeBag)
            didDeleteTapped
                .flatMap(Observable.from(optional: ))
                .flatMap{ [unowned self] in
                    model.removeFavorite(mark: self.realmMark)
                }
                .bind(to: didDeleteCompleted)
                .disposed(by: disposeBag)
        } else {
            didCreateTapped
                .flatMap(Observable.from(optional: ))
                .flatMap(model.addFavorite)
                .bind(to: didCreateCompleted)
                .disposed(by: disposeBag)
        }
    }
    
    func configureState() {
        switch state {
        case .quick:
            configureQuick()
        case .search:
            configureSearch(placeId: placeId ?? "")
        case .favorite:
            configureFavorite(locatoin: realmMark?.location ?? CLLocation())
        }
    }

    // MARK: - Helpers
    
    private func configureFavorite(locatoin: CLLocation) {
        model.startUpdatingLocation()
        
        Observable.just(locatoin)
            .subscribe(onNext: { [weak self] loc in
                self?.didUpdateLocation.accept(loc)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureSearch(placeId: String) {
        model.startUpdatingLocation()
        
        let detail = model.fetchAddressDetail(placeId: placeId)
        
        detail
            .map { ($0.location ?? CLLocation(latitude: 0.0, longitude: 0.0)) }
            .subscribe(onNext: { [weak self] location in
                self?.didUpdateLocation.accept(location)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureQuick() {
        model.startUpdatingLocation()

        let updateLocation = model.manager?.rx.didUpdateLocations

        updateLocation?
            .map { ($0.locations.last ?? CLLocation(latitude: 0.0, longitude: 0.0)) }
            .subscribe(onNext: { [weak self] location in
                self?.didUpdateLocation.accept(location)
            })
            .disposed(by: disposeBag)
    }
    
    func stopUpdatingLocation() {
        model.manager?.stopUpdatingLocation()
    }
    
    private func configureManager() {
        didRegionChanged
            .distinctUntilChanged()
            .flatMap { self.model.fetchReverseGeocode(location: $0) }
            .map { $0.title }
            .bind(to: didRegionChangedStr)
            .disposed(by: disposeBag)
        
        model.manager?.rx
            .didChangeAuthorization
            .subscribe(onNext: { [weak self] auth in
                switch auth.status {
                case .authorizedAlways:
                    break
                case .authorizedWhenInUse:
                    break
                case .denied:
                    fallthrough
                case .restricted:
                    self?.permissionError.accept(())
                case .notDetermined:
                    self?.model.manager?.requestAlwaysAuthorization()
                @unknown default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
}
