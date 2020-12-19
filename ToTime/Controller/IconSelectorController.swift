//
//  IconSelectorController.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/11.
//

import UIKit
import RxSwift
import RxCocoa

private let reuseIdentifier = "IconCell"

protocol IconSelectorDelegate: class {
    func didIconSelected(iconImage image: UIImage, url: String)
}

class IconSelectorController: UIViewController {

    // MARK: - Property
    
    weak var delegate: IconSelectorDelegate?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .zero
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.register(MarkIconCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        return cv
    }()
    
    private let viewModel: IconSelectorViewModel!
    private let disposeBag = DisposeBag()
    
        
    // MARK: - Lifecycle
    
    init(viewModel: IconSelectorViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureCollectionView()
    }
    
    // MARK: - ConfigureCollectionView
            
    private func configureCollectionView() {
        viewModel.markIcons
            .asDriver()
            .drive(collectionView.rx.items(cellIdentifier: reuseIdentifier, cellType: MarkIconCell.self)) { (row, item, cell) in
                cell.configureItem(iconUrl: item)
                cell.delegate = self
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Configure UI
    
    private func configureUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.right.bottom.height.equalToSuperview()
        }
        
        collectionView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
            
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension IconSelectorController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize: CGFloat = self.view.frame.width / 5
        return CGSize(width: cellSize, height: cellSize)
    }
}

// MARK: - MarkIconCellDelegate

extension IconSelectorController: MarkIconCellDelegate {
    func markCellSelected(selectedImage image: UIImage, url: String) {
        self.delegate?.didIconSelected(iconImage: image, url: url)
        self.dismiss(animated: true, completion: nil)
    }
}
