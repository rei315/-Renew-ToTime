//
//  AddressCell.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/07.
//

import UIKit
import SnapKit
import RxSwift
import MapKit

class AddressCell: UITableViewCell {
    
    // MARK: - Property
    private let buildingLabel: UILabel = {
        let label = UILabel()
        label.text = "test"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    private lazy var seperator: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .ultraLightGray
        return iv
    }()
    
//    private var disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configurePlace(place: Place) {
        buildingLabel.text = place.placeName
    }
    
    private func configureCell() {
        addSubview(buildingLabel)
        addSubview(seperator)
        
        buildingLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.greaterThanOrEqualToSuperview()
            make.centerY.equalToSuperview()
        }
        seperator.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
        }
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//
//        disposeBag = DisposeBag()
//    }
}
