//
//  MarkCell.swift
//  ToTimer
//
//  Created by 김민국 on 2020/12/06.
//

import UIKit
import SnapKit
import RxDataSources

class MarkCell: UICollectionViewCell {
    
    // MARK: - Property
    
    private let iconImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    private let markLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 23)
        return label
    }()
    
    private let seperator: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers

    private func configureCell() {
        
        addSubview(iconImage)
        addSubview(markLabel)
        addSubview(seperator)
        
        iconImage.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(50)
            make.height.equalTo(iconImage.snp.width)
        }
        markLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconImage.snp.right).offset(20)
            make.centerY.equalToSuperview()
        }
        seperator.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
        }
    }
    
    func configureItem(mark: Mark) {
        markLabel.text = mark.name
        iconImage.image = ResourceManager.shared.loadImageWithFileName(fileName: mark.iconImage)
    }
}
