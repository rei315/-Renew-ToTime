////
////  SearchAddressController.swift
////  ToTime
////
////  Created by 김민국 on 2020/12/07.
////
//
//import UIKit
//import RxSwift
//import RxCocoa
//import RxDataSources
//import SnapKit
//import MapKit
//
//private let reuseIdentifier = "AddressCell"
//private let headerIdentifier = "AddressSearchCell"
//
//class SearchAddressController: UIViewController {
//
//    // MARK: - Property
//    
//    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<AddressSectionModel>(configureCell: configureCell, configureSupplementaryView: supplementaryCell)
//
//    private lazy var configureCell: RxCollectionViewSectionedReloadDataSource<AddressSectionModel>.ConfigureCell = { [weak self] (_, cv, ip, item) in
//        guard let strongSelf = self else { return UICollectionViewCell() }
//        switch item {
//        case .address(let address):
//            return strongSelf.addressCell(indexPath: ip, address: address)
//        }
//    }
//
//    private lazy var supplementaryCell: RxCollectionViewSectionedReloadDataSource<AddressSectionModel>.ConfigureSupplementaryView = { [weak self] (dataSource, cv, kind, ip) in
//        guard let strongSelf = self else { return UICollectionReusableView() }
//        return strongSelf.searchView(indexPath: ip, kind: kind)
//    }
//
//    private lazy var collectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.backgroundColor = .white
//        return cv
//    }()
//
//    private let disposeBag = DisposeBag()
//    private var viewModel: SearchAddressViewModel!
//
//
//
//    // MARK: - Lifecycle
//
//    init(viewModel: SearchAddressViewModel) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureUI()
//        setupDataSource()
//        configureCollectionView()
//
////        viewModel.searchText
////            .flatMap(Observable.from(optional: ))
////            .subscribe(onNext: { [unowned self] str in
////                viewModel.searchCompleter.rx.queryFragment.onNext(str)
////            })
////            .disposed(by: disposeBag)
//
//
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        navigationController?.navigationBar.isHidden = false
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationController?.navigationBar.topItem?.title = ""
//        navigationItem.title = NavigationTitle.DestinationAddress
//    }
//
//    // MARK: - Helpers
//
//
//
//    private func setupDataSource() {
//        viewModel.items
//            .flatMap(Observable.from(optional: ))
//            .asDriver(onErrorDriveWith: .empty())
//            .drive(collectionView.rx.items(dataSource: dataSource))
//            .disposed(by: disposeBag)
//    }
//
//    private func configureCollectionView() {
//        self.view.addSubview(collectionView)
//
//        self.collectionView.snp.makeConstraints { (make) in
//            make.left.equalToSuperview()
//            make.right.equalToSuperview()
//            make.bottom.equalToSuperview()
//            make.top.equalToSuperview()
//        }
//
//        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
//
//        collectionView.register(AddressCell.self, forCellWithReuseIdentifier: reuseIdentifier)
//        collectionView.register(AddressSearchHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
//    }
//
//    private func configureUI() {
//        view.backgroundColor = .white
//    }
//
//    // MARK: - Cell Helper
//
//    private func searchView(indexPath: IndexPath, kind: String) -> UICollectionReusableView {
//        if let section = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as? AddressSearchHeader {
//            section.delegate = self
//            section.configureItem(address: viewModel.test ?? "")
////            section.configureItem(address: viewModel.searchText.value ?? "")
//            return section
//        }
//        return UICollectionReusableView()
//    }
//
//    private func addressCell(indexPath: IndexPath, address: Address) -> UICollectionViewCell {
//        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? AddressCell{
//            cell.configureData(address: address)
//            return cell
//        }
//        return UICollectionViewCell()
//    }
//}
//
//// MARK: - UICollectionViewDelegateFlowLayout
//
//extension SearchAddressController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: view.frame.width, height: 70)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: view.frame.width, height: 70)
//    }
//}
//
//// MARK: - AddressSearchHeaderDelegate
//
//extension SearchAddressController: AddressSearchHeaderDelegate {
//    func handleSearchTapped(address: String) {
//        Observable.just("중구")
//            .flatMap(Observable.from(optional: ))
//            .subscribe(onNext: { [weak self] str in
//                self?.viewModel.searchCompleter.rx.queryFragment.onNext(str)
//            })
//            .disposed(by: disposeBag)
//    }
//}
