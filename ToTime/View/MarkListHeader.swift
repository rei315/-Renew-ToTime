//
//  MarkListHeader.swift
//  ToTimer
//
//  Created by 김민국 on 2020/12/06.
//

import UIKit
import SnapKit

protocol MarkListHeaderDelegate: class {
    func handlePlusTapped()
    func handleQuickMapTapped()
}

class MarkListHeader: UICollectionReusableView {
    
    // MARK: - Property
    
    weak var delegate: MarkListHeaderDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.numberOfLines = 2
        label.text = "지번, 도로명, 건물명을\n입력하세요"
        return label
    }()
    
    private lazy var addressTextField: PaddingTextField = {
        let tf = PaddingTextField(padding: 10)
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.attributedPlaceholder = NSAttributedString(string: "주소를 입력하세요", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        tf.backgroundColor = .lightBlue
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.layer.borderWidth = 1.5
        tf.layer.cornerRadius = 4.0
        return tf
    }()
    private lazy var quickMapButton: UIButton = {
        let bt = UIButton()
        bt.setImage(UIImage(systemName: "map"), for: .normal)
        bt.backgroundColor = .lightBlue
        bt.layer.borderColor = UIColor.lightGray.cgColor
        bt.layer.borderWidth = 1.5
        bt.layer.cornerRadius = 4.0
        bt.addTarget(self, action: #selector(handleQuickMapTapped), for: .touchUpInside)
        return bt
    }()
    private lazy var bookMarkLabel: UILabel = {
        let label = UILabel()
        label.text = "즐겨찾기"
        label.font = UIFont.systemFont(ofSize: 25)
        return label
    }()
    private lazy var plusButton: UIButton = {
        let bt = UIButton()
        bt.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        bt.contentHorizontalAlignment = .fill
        bt.contentVerticalAlignment = .fill
        bt.addTarget(self, action: #selector(handlePlusTapped), for: .touchUpInside)
        return bt
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .white
        
        addSubview(titleLabel)
        addSubview(addressTextField)
        addSubview(quickMapButton)
        addSubview(bookMarkLabel)
        addSubview(plusButton)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
        }
        
        addressTextField.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(quickMapButton.snp.height)
        }
        
        quickMapButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(addressTextField)
            make.left.equalTo(addressTextField.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        bookMarkLabel.snp.makeConstraints { (make) in
            make.top.equalTo(addressTextField.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(15)
        }
        
        plusButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(bookMarkLabel)
            make.left.equalTo(bookMarkLabel.snp.right).offset(10)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
    }
    
    // MARK: - Selectors
    
    @objc func handlePlusTapped() {
        delegate?.handlePlusTapped()
    }
    
    @objc func handleQuickMapTapped() {
        guard addressTextField.text != nil else { return}
        delegate?.handleQuickMapTapped()
    }
}