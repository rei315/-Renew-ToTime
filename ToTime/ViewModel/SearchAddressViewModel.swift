//
//  SearchAddressViewModel.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/10.
//

import RxSwift
import RxCocoa
import Alamofire

class SearchAddressViewModel {
    let disposeBag = DisposeBag()
    
    private let searchItems = BehaviorRelay<[String]>(value: [])
    
    let searchText = BehaviorRelay<String?>(value: nil)
    let searchedPlace = BehaviorRelay<[Place]>(value: [])
    
    let model = SearchAddressModel()
    
    init(address: String) {
        configureSearch()
        
        searchText.accept(address)
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
