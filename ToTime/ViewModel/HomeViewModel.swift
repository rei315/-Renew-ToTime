//
//  HomeViewModel.swift
//  ToTimer
//
//  Created by 김민국 on 2020/12/06.
//

import RxSwift
import RxCocoa

class HomeViewModel {
    
    // MARK: - Property
    
    let disposeBag = DisposeBag()
    
    let items = BehaviorRelay<[MarkSectionModel]>(value: [])
    let model = HomeModel()
    
    // MARK: - Lifecycle

    func fetchBind() {
        model.fetchMark()
            .flatMap{Observable.from($0)}
            .map { Mark(identity: $0.identity, name: $0.name, latitude: $0.latitude, longitude: $0.longitude, address: $0.address, iconImage: $0.iconImageUrl) }
            .map { MarkSectionItem.mark(mark: $0) }
            .toArray()
            .asObservable()
            .map { [MarkSectionModel(model: .mark, items: $0)] }
            .subscribe(onNext: { [weak self] data in
                self?.items.accept(data)
            })
            .disposed(by: disposeBag)
    }
}
