//
//  Test2ViewController.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/08.
//

import UIKit
import SnapKit
import Alamofire
import RxSwift
import RxCocoa

class Test2ViewController: UIViewController {

    let testView = UIView()
    
    lazy var button: UIButton = {
       let bt = UIButton()
        bt.addTarget(self, action: #selector(help), for: .touchUpInside)
        bt.backgroundColor = .blue
        return bt
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(testView)
        view.addSubview(button)
        
        testView.backgroundColor = .red
        
        testView.snp.makeConstraints { (make) in
//            make.height.equalTo(0)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(view.frame.height)
        }
        
        button.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(100)
        }
        
                
        
        
        
    }
    
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
    
    @objc func help() {        
        UIView.animate(withDuration: 0.5) {
            self.testView.snp.updateConstraints { (make) in
                make.top.equalToSuperview().offset(300)
            }
            self.view.layoutIfNeeded()
        }
    }
}
