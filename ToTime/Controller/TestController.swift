//
//  TestController.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/08.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
import SnapKit

class TestController: UIViewController {
    lazy var textField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .lightGray
        return tf
    }()
    
    lazy var button: UIButton = {
       let bt = UIButton()
        bt.backgroundColor = .blue
        return bt
    }()
    
    let search = MKLocalSearchCompleter()
    let dispose = DisposeBag()
    let searchText = BehaviorRelay<String?>(value: nil)
    
    let request = MKLocalSearch.Request()
    var localSearch: MKLocalSearch?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(textField)
        view.addSubview(button)
        
        textField.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        button.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(textField.snp.bottom).offset(20)
            make.width.equalTo(200)
            make.height.equalTo(100)
        }
  
    }
}
