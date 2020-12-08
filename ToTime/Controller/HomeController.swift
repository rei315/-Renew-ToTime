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
import MapKit

private let cvReuseIdentifier = "MarkCell"
private let cvHeaderIdentifier = "MarkListHeader"
private let tvReuseIdentifier = "AddressCell"


class HomeController: UIViewController {
    
    // MARK: - Property
    
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<MarkSectionModel>(configureCell: configureCell, configureSupplementaryView: supplementaryCell)
    
    private lazy var configureCell: RxCollectionViewSectionedReloadDataSource<MarkSectionModel>.ConfigureCell = { [weak self] (_, cv, ip, item) in
        guard let strongSelf = self else { return UICollectionViewCell() }
        switch item {
        case .mark(let mark):
            return strongSelf.markCell(indexPath: ip, mark: mark)
        case .blank:
            return strongSelf.blankCell(indexPath: ip)
        }
    }
    
    private lazy var supplementaryCell: RxCollectionViewSectionedReloadDataSource<MarkSectionModel>.ConfigureSupplementaryView = { [weak self] (dataSource, cv, kind, ip) in
        guard let strongSelf = self else { return UICollectionReusableView() }
        return strongSelf.markView(indexPath: ip, kind: kind)
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white        
        return cv
    }()
    
    private let viewModel = HomeViewModel()
    private let disposeBag = DisposeBag()
    
    let searchView = UIView()
    let searchTableView = UITableView()
    
    var isMenuView = false
    private let headerHeight: CGFloat = 240
    private let cellHeight: CGFloat = 70
    
    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionView()
        setupCollectionViewDataSource()
        configureSearchView()
    }
    
    // MARK: - AddressSearch
    
    private func configureSearchView() {
        searchTableView.register(AddressCell.self, forCellReuseIdentifier: tvReuseIdentifier)
        searchTableView.rowHeight = UITableView.automaticDimension
        
        searchView.addSubview(searchTableView)
        view.addSubview(searchView)
        
        searchTableView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalToSuperview()
        }
        
        searchView.backgroundColor = .white
        searchView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(view.frame.height)
            make.bottom.equalToSuperview()
        }
        
        searchTableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.searchedPlace
            .bind(to: searchTableView.rx.items) { tv, row, data in
                let index = IndexPath(row: row, section: 0)
                let cell = tv.dequeueReusableCell(withIdentifier: tvReuseIdentifier, for: index) as? AddressCell
                cell?.configurePlace(place: data)
                return cell ?? UITableViewCell()
            }
            .disposed(by: disposeBag)
                
        Observable.zip(searchTableView.rx.modelSelected(Place.self), searchTableView.rx.itemSelected)
            .do(onNext: { [unowned self] (place, indexPath) in
                self.searchTableView.deselectRow(at: indexPath, animated: true)
            })
            .subscribe(onNext: { [unowned self] (place, indexPath) in
                let QMViewModel = QuickMapViewModel(state: .search, placeId: place.placeID)
                let QMController = QuickMapController(viewModel: QMViewModel)
                navigationController?.pushViewController(QMController, animated: true)
            })
            .disposed(by: disposeBag)
            
    }
    
    private func ableSearchView() {
        searchView.snp.updateConstraints { (make) in
            make.top.equalTo(headerHeight)
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func disalbeSearchView() {
        searchView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(view.frame.height)
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Favorites CollectionView
    
    private func setupCollectionViewDataSource() {
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
        
        collectionView.register(MarkCell.self, forCellWithReuseIdentifier: cvReuseIdentifier)
        collectionView.register(MarkListHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cvHeaderIdentifier)
        collectionView.register(BlankCollectionCell.self, forCellWithReuseIdentifier: "Blank")
    }
    
    // MARK: - UI
    
    private func configureUI() {
        view.backgroundColor = .white
        
        view.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
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
            cell.configureItem(text: mark)
            return cell
        }
        return UICollectionViewCell()
    }
    
    private func blankCell(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Blank", for: indexPath)
        return cell
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
    func handleFieldChanged(address: String) {
        if address == "" {
            if isMenuView {
                isMenuView = false
                viewModel.searchedPlace.accept([])
                disalbeSearchView()
            }
        } else {
            if !isMenuView {
                isMenuView = true
                ableSearchView()
            }
        }
    }
    
    func handleQuickSearchTapped(address: String) {
        Observable.just(address)
            .subscribe(onNext: { [weak self] str in
                self?.viewModel.searchText.accept(str)
            })
            .disposed(by: disposeBag)
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
