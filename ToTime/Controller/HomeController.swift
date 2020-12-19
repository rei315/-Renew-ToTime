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
import SnapKit
import RealmSwift

private let cvReuseIdentifier = "MarkCell"
private let cvHeaderIdentifier = "MarkListHeader"

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
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.register(MarkCell.self, forCellWithReuseIdentifier: cvReuseIdentifier)
        cv.register(MarkListHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cvHeaderIdentifier)
        return cv
    }()
    
    private let viewModel = HomeViewModel()
    private let disposeBag = DisposeBag()
    
    private let headerHeight: CGFloat = 240
    private let cellHeight: CGFloat = 70
    
    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        
        Observable.just(())
            .subscribe(onNext: { [weak self] void in
                self?.viewModel.fetchBind()
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionView()
        setupCollectionViewDataSource()
//        print(Realm.Configuration.defaultConfiguration.fileURL)
        
    }
    
    // MARK: - Favorites CollectionView
    
    private func setupCollectionViewDataSource() {
        viewModel.items
            .asDriver(onErrorJustReturn: [])
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        Observable.zip(collectionView.rx.modelSelected(MarkSectionItem.self), collectionView.rx.itemSelected)
            .subscribe(onNext: { [unowned self] (mark, indexPath) in
                switch mark {
                case .mark(let mark):
                    let QMViewModel = QuickMapViewModel(state: .favorite, mark: mark)
                    let QMController = QuickMapController(viewModel: QMViewModel)
                    self.navigationController?.pushViewController(QMController, animated: true)
                }
            })
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
    }
    
    // MARK: - UI
    
    private func configureUI() {
        view.backgroundColor = .white
    }
    
    // MARK: - Cell Helper
    
    private func markView(indexPath: IndexPath, kind: String) -> UICollectionReusableView {
        if let section = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: cvHeaderIdentifier, for: indexPath) as? MarkListHeader {
            section.delegate = self
            return section
        }
        return UICollectionReusableView()
    }
    
    private func markCell(indexPath: IndexPath, mark: Mark) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cvReuseIdentifier, for: indexPath) as? MarkCell{
            cell.configureItem(mark: mark)
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: headerHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: view.frame.width, height: cellHeight)
    }
}

// MARK: - MarkListHeaderDelegate

extension HomeController: MarkListHeaderDelegate {
    
    func handleQuickSearchTapped(address: String) {
        let SAViewModel = SearchAddressViewModel(address: address)
        let SAViewController = SearchAddressController(viewModel: SAViewModel)
        self.navigationController?.pushViewController(SAViewController, animated: true)
    }
    
    func handleQuickMapTapped() {
        let QMViewModel = QuickMapViewModel(state: .quick, placeId: nil)
        let QMController = QuickMapController(viewModel: QMViewModel)
        
        self.navigationController?.pushViewController(QMController, animated: true)
    }
}

extension HomeController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
