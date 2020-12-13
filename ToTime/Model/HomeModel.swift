//
//  HomeModel.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/12.
//

import Foundation
import RxSwift
import RealmSwift

struct HomeModel {
    // MARK: - Helpers
    
    func fetchMark() -> Observable<[MarkRealm]> {
        Observable.create { observer in
            let realm = try! Realm()
            let markItems = realm.objects(MarkRealm.self)
            observer.onNext(markItems.map { $0 })
            observer.onCompleted()
            
            return Disposables.create {}
        }
    }
}
