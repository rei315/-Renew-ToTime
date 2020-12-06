//
//  Observable+Extension.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/06.
//

import Foundation
import RxSwift

extension Observable {    
    func unwrap<T>() -> Observable<T> where Element == T? {
        self
            .filter { $0 != nil }
            .map { $0! }
    }
}
