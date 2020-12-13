//
//  IconSelectorViewModel.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/11.
//

import Foundation
import RxSwift
import RxCocoa

class IconSelectorViewModel {
    
    // MARK: - Property
    
    let markIcons = BehaviorRelay<[String]>(value: [])
    let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    init() {
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
    
    
}
