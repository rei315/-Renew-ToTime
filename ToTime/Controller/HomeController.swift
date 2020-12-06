//
//  HomeController.swift
//  ToTimer
//
//  Created by 김민국 on 2020/12/06.
//

import UIKit
import SnapKit
import RxSwift
import RxDataSources

private let reuseIdentifier = "MarkCell"
private let headerIdentifier = "MarkListHeader"

class HomeController: UIViewController {
    
    // MARK: - Property
    
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<MarkSectionModel>(configureCell: configureCell, configureSupplementaryView: supplementaryCell)
    
    private lazy var configureCell: RxCollectionViewSectionedReloadDataSource<MarkSectionModel>.ConfigureCell = { [weak self] (_, cv, ip, item) in
        guard let strongSelf = self else { return UICollectionViewCell() }
        switch item {
        case .mark(let mark):
            return strongSelf.markCell(indexPath: ip, mark: mark)
        }
    }
    
    private lazy var supplementaryCell: RxCollectionViewSectionedReloadDataSource<MarkSectionModel>.ConfigureSupplementaryView = { [weak self] (dataSource, cv, kind, ip) in
        guard let strongSelf = self else { return UICollectionReusableView() }
        return strongSelf.markView(indexPath: ip, kind: kind)
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white        
        return cv
    }()
    
    let viewModel = HomeViewModel()
    let disposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionView()
        setupDataSource()
    }
    
    // MARK: - Helpers
    
    private func setupDataSource() {
        viewModel.items
            .asDriver()
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    private func configureCollectionView() {
        self.view.addSubview(collectionView)
        
        self.collectionView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        collectionView.register(MarkCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(MarkListHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }
    
    private func configureUI() {
        view.backgroundColor = .red
    }
    
    // MARK: - Cell Helper
    
    private func markView(indexPath: IndexPath, kind: String) -> UICollectionReusableView {
        if let section = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as? MarkListHeader {
            section.delegate = self
            return section
        }
        return UICollectionReusableView()
    }
    
    private func markCell(indexPath: IndexPath, mark: Mark) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MarkCell{
            cell.configureItem(text: mark)
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 230)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 70)
    }
}

extension HomeController: MarkListHeaderDelegate {
    func handlePlusTapped() {
        let controller = AddMarkController()
        self.present(controller, animated: true, completion: nil)
    }
    
    func handleQuickMapTapped() {
        let QMController = QuickMapController()
        self.navigationController?.pushViewController(QMController, animated: true)
    }
}
