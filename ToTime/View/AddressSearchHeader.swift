//
//  AddressSearchHeader.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/07.
//

import UIKit
import RxSwift
import RxCocoa

protocol AddressSearchHeaderDelegate: class {
    func handleSearchTapped(address: String)
}

class AddressSearchHeader: UIView {
    
    // MARK: - Property
    
    weak var delegate: AddressSearchHeaderDelegate?
    
    private lazy var addressField: UITextField = {
        let tf = PaddingTextField(padding: 10, type: .Delete)
        tf.font = UIFont.systemFont(ofSize: 18)
        tf.attributedPlaceholder = NSAttributedString(string: AppString.AddressPlaceHolder.localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        tf.clearButtonMode = .always
        tf.returnKeyType = .search
        return tf
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.tintColor = .black
        return button
    }()
    
    private lazy var seperator: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .ultraLightGray
        return iv
    }()
    
    let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configureItem(address: String) {
        addressField.text = address
    }
    
    private func configureUI() {
        backgroundColor = .white
        
        addSubview(addressField)
        addSubview(searchButton)
        addSubview(seperator)
        
        addressField.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.height.equalToSuperview()
            make.right.equalTo(searchButton.snp.left).offset(-20)
        }
                        
        searchButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(addressField)
            make.right.equalToSuperview().offset(-20)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        seperator.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(10)
        }
    }
    
    // MARK: - Action
    
    private func configureAction() {
        addressField.rx.controlEvent([.editingDidEndOnExit])
            .subscribe(onNext: { [weak self] _ in
                self?.handleSearchTapped()
            })
            .disposed(by: disposeBag)
        
        searchButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.handleSearchTapped()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Action Handler
    
    private func handleSearchTapped() {
        guard let text = addressField.text else { return }
        if text.isEmpty { return }
        delegate?.handleSearchTapped(address: text)
    }
}
