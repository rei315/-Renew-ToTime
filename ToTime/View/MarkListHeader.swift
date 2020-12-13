//
//  MarkListHeader.swift
//  ToTimer
//
//  Created by 김민국 on 2020/12/06.
//

import UIKit
import SnapKit
import RxGesture
import RxSwift

protocol MarkListHeaderDelegate: class {
    func handleQuickMapTapped()
    func handleQuickSearchTapped(address: String)
}

class MarkListHeader: UICollectionReusableView {
    
    // MARK: - Property
    
    weak var delegate: MarkListHeaderDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.numberOfLines = 2
        label.text = AppString.HomeTitle.localized()
        return label
    }()
    
    private lazy var addressTextField: PaddingTextField = {
        let tf = PaddingTextField(padding: 10, type: .Delete)
        tf.font = UIFont.systemFont(ofSize: 18)
        tf.adjustsFontSizeToFitWidth = true
        tf.attributedPlaceholder = NSAttributedString(string: AppString.AddressPlaceHolder.localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        tf.backgroundColor = .lightBlue
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.layer.borderWidth = 1.5
        tf.layer.cornerRadius = 4.0
        tf.clearButtonMode = .always
        tf.returnKeyType = .search
        return tf
    }()
    private lazy var quickSearchButton: UIButton = {
        let bt = UIButton()
        bt.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        bt.backgroundColor = .lightBlue
        bt.layer.borderColor = UIColor.lightGray.cgColor
        bt.layer.borderWidth = 1.5
        bt.layer.cornerRadius = 4.0
        return bt
    }()
    private lazy var quickMapButton: UIButton = {
        let bt = UIButton()
        bt.setImage(UIImage(systemName: "map"), for: .normal)
        bt.backgroundColor = .lightBlue
        bt.layer.borderColor = UIColor.lightGray.cgColor
        bt.layer.borderWidth = 1.5
        bt.layer.cornerRadius = 4.0
        return bt
    }()
    private lazy var bookMarkLabel: UILabel = {
        let label = UILabel()
        label.text = AppString.FavoriteTitle.localized()
        label.font = UIFont.systemFont(ofSize: 25)
        return label
    }()
    
    private lazy var seperator: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .ultraLightGray
        return iv
    }()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        configureAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private func configureUI() {
        backgroundColor = .white
        
        addSubview(titleLabel)
        addSubview(addressTextField)
        addSubview(quickMapButton)
        addSubview(bookMarkLabel)
        addSubview(quickSearchButton)
        addSubview(seperator)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        addressTextField.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(quickMapButton.snp.height)
        }
        
        quickSearchButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(addressTextField)
            make.left.equalTo(addressTextField.snp.right).offset(10)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        quickMapButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(addressTextField)
            make.left.equalTo(quickSearchButton.snp.right).offset(5)
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        seperator.snp.makeConstraints { (make) in
            make.bottom.equalTo(bookMarkLabel.snp.top).offset(-10)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(10)
        }
        
        bookMarkLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-5)
            make.left.equalToSuperview().offset(15)
        }
        self.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.addressTextField.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Action
    
    private func configureAction() {
        
        quickSearchButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.handleQuickSearchTapped()
            })
            .disposed(by: disposeBag)
        
        addressTextField.rx.controlEvent([.editingDidEndOnExit])
            .subscribe(onNext: { [weak self] _ in
                self?.handleQuickSearchTapped()
            })
            .disposed(by: disposeBag)
        
        quickMapButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.handleQuickMapTapped()
            })
            .disposed(by: disposeBag)
        
        
    }
    
    // MARK: - Action Handler
    
    func handleQuickMapTapped() {
        delegate?.handleQuickMapTapped()
    }
    
    func handleQuickSearchTapped() {
        guard let text = addressTextField.text else { return }
        if text.isEmpty { return }
        addressTextField.endEditing(true)
        delegate?.handleQuickSearchTapped(address: text)
    }
}
