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
    
    let items = BehaviorRelay<[MarkSectionModel]>(value: [])
    
    
    // MARK: - Lifecycle
    
    init() {
        var sections: [MarkSectionModel] = []
                
        let test1 = MarkSectionItem.mark(mark: Mark(name: "hi", latitude: 0.0, longitude: 0.0, address: "", iconImage: #imageLiteral(resourceName: "mark00086")))
        let test2 = MarkSectionItem.mark(mark: Mark(name: "hi", latitude: 0.0, longitude: 0.0, address: "", iconImage: #imageLiteral(resourceName: "mark00015")))
        let test3 = MarkSectionItem.mark(mark: Mark(name: "hi", latitude: 0.0, longitude: 0.0, address: "", iconImage: #imageLiteral(resourceName: "mark00015")))
        let test4 = MarkSectionItem.mark(mark: Mark(name: "hi", latitude: 0.0, longitude: 0.0, address: "", iconImage: #imageLiteral(resourceName: "mark00015")))
        let test5 = MarkSectionItem.mark(mark: Mark(name: "hi", latitude: 0.0, longitude: 0.0, address: "", iconImage: #imageLiteral(resourceName: "mark00015")))
        let test6 = MarkSectionItem.mark(mark: Mark(name: "hi", latitude: 0.0, longitude: 0.0, address: "", iconImage: #imageLiteral(resourceName: "mark00015")))
        let test7 = MarkSectionItem.mark(mark: Mark(name: "hi", latitude: 0.0, longitude: 0.0, address: "", iconImage: #imageLiteral(resourceName: "mark00015")))
        let test8 = MarkSectionItem.mark(mark: Mark(name: "hi", latitude: 0.0, longitude: 0.0, address: "", iconImage: #imageLiteral(resourceName: "mark00015")))
        let section = MarkSectionModel(model: .mark, items: [test1,test2,test3,test4,test5,test6,test7,test8])
        
        sections.append(section)
        items.accept(sections)
    }
}
