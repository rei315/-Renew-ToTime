//
//  ResourceManager.swift
//  ToTimer
//
//  Created by 김민국 on 2020/12/05.
//

import UIKit
import RxSwift

struct ResourceManager {
    static let shared = ResourceManager()
    
    func fetchMarkIcons() -> Observable<UIImage>{
        Observable.create { observer in
            let fileManager = FileManager.default
            let imagePath = Bundle.main.resourcePath! + "/MarkIcon"
            do {
                let imageNames = try fileManager.contentsOfDirectory(atPath: imagePath)
                for name in imageNames {
                    if let imagePath = Bundle.main.path(forResource: name, ofType: nil) {
                        if let image = UIImage(contentsOfFile: imagePath) {
                            print(image.description)
                            observer.onNext(image)
                        }
                    }
                }
            } catch {
                print(error)
                observer.onError(error)
            }
            
            observer.onCompleted()            
            
            return Disposables.create()
        }
    }
}
