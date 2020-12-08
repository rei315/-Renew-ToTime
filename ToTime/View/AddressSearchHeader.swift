//
//  AddressSearchHeader.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/07.
//

import UIKit

protocol AddressSearchHeaderDelegate: class {
    func handleSearchTapped(address: String)
}

class AddressSearchHeader: UICollectionReusableView {
    
    // MARK: - Property
    
    weak var delegate: AddressSearchHeaderDelegate?
    
    private lazy var addressField: UITextField = {
        let tf = PaddingTextField(padding: 10)
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.attributedPlaceholder = NSAttributedString(string: "주소를 입력하세요", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        return tf
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "delete.left"), for: .normal)
        button.addTarget(self, action: #selector(handleDeleteTapped), for: .touchUpInside)
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.tintColor = .lightGray
        return button
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.addTarget(self, action: #selector(handleSearchTapped), for: .touchUpInside)
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
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
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
        addSubview(deleteButton)
        addSubview(searchButton)
        addSubview(seperator)
        
        addressField.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints { (make) in
            make.left.equalTo(addressField.snp.right).offset(3)
            make.centerY.equalToSuperview()
            make.width.equalTo(22)
            make.height.equalTo(22)
        }
        
        searchButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(deleteButton.snp.right).offset(18)
            make.right.equalToSuperview().offset(-20)
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
        
        seperator.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(10)
        }
    }
    
    
    // MARK: - Selectors
    
    @objc func handleSearchTapped() {
        guard let text = addressField.text else { return }
        if text.isEmpty { return }
        delegate?.handleSearchTapped(address: text)
    }
    
    @objc func handleDeleteTapped() {
        addressField.text = ""
    }
    
    
}
