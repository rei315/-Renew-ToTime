//
//  MarkIconCell.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/11.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

protocol MarkIconCellDelegate: class {
    func markCellSelected(selectedImage image: UIImage, url: String)
}

class MarkIconCell: UICollectionViewCell {
        
    // MARK: - Property
    
    weak var delegate: MarkIconCellDelegate?
    
    private lazy var iconImageButton: UIButton = {
        let bt = UIButton()
        bt.layer.borderColor = UIColor.lightGray.cgColor
        bt.layer.borderWidth = 1.5
        bt.layer.cornerRadius = 8
        bt.contentVerticalAlignment = .fill
        bt.contentHorizontalAlignment = .fill
        bt.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return bt
    }()
    
    private var disposeBag = DisposeBag()
    
    private var iconUrl: String = ""
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureButtonAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Configure UI
    
    private func configureUI() {
        self.addSubview(iconImageButton)
        iconImageButton.snp.makeConstraints { (make) in
            make.left.right.bottom.height.equalToSuperview()
        }
    }
    
    
    // MARK: - Action
    
    func configureButtonAction() {
        iconImageButton.rx.touchDownGesture()
            .when(.began)
            .subscribe(onNext: { [weak self] _ in
                self?.iconImageButton.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            })
            .disposed(by: disposeBag)
        iconImageButton.rx
            .swipeGesture([.down, .left, .right, .up])
            .when(.ended)
            .subscribe({ [weak self] _ in
                self?.iconImageButton.backgroundColor = UIColor.white
            })
            .disposed(by: disposeBag)
        iconImageButton.rx
            .anyGesture(.tap())
            .when(.ended)
            .subscribe({ [weak self] _ in
                self?.iconImageButton.backgroundColor = UIColor.white
                self?.delegate?.markCellSelected(selectedImage: self?.iconImageButton.image(for: .normal) ?? UIImage(), url: self?.iconUrl ?? "")
            })
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - Configure Item
    
    func configureItem(iconUrl url: String) {
        self.iconUrl = url
        let image = ResourceManager.shared.getImageFromURL(str: url)
        
        iconImageButton.setImage(image, for: .normal)
    }
    
    
    // MARK: - PrepareForReuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
}
