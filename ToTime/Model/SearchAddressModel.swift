//
//  SearchAddressModel.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/12.
//

import Foundation
import RxSwift
import Alamofire

struct SearchAddressModel {
    
    // MARK: - Helpers
    
    func fetchAddressAutoComplete(address: String) -> Observable<[Place]> {
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
