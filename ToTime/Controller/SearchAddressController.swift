//
//  SearchAddressController.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/07.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import MapKit
import RxGesture

private let tvReuseIdentifier = "AddressCell"

class SearchAddressController: UIViewController {

    // MARK: - Property

    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(AddressCell.self, forCellReuseIdentifier: tvReuseIdentifier)
        tv.rowHeight = UITableView.automaticDimension
        return tv
    }()

    private lazy var headerView: AddressSearchHeader = {
        let hv = AddressSearchHeader(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 70))
        hv.delegate = self
        hv.configureItem(address: viewModel.searchText.value ?? "")
        return hv
    }()
    
    private let disposeBag = DisposeBag()
    private var viewModel: SearchAddressViewModel!

    // MARK: - Lifecycle

    init(viewModel: SearchAddressViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTableView()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.topItem?.title = ""
        navigationItem.title = NavigationTitle.DestinationAddress.localized()
    }

    // MARK: - Configure TableView

    func configureTableView() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        tableView.tableHeaderView = headerView
        tableView.rx.swipeGesture(.down, .up)
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Bind ViewModel
    
    func bindViewModel() {
        tableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
                
        viewModel.searchedPlace
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items) { tv, row, data in
                let index = IndexPath(row: row, section: 0)
                let cell = tv.dequeueReusableCell(withIdentifier: tvReuseIdentifier, for: index) as? AddressCell
                cell?.configurePlace(place: data)
                return cell ?? UITableViewCell()
            }
            .disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.modelSelected(Place.self), tableView.rx.itemSelected)
            .do(onNext: { [unowned self] (place, indexPath) in
                self.tableView.deselectRow(at: indexPath, animated: true)
            })
            .subscribe(onNext: { [unowned self] (place, indexPath) in
                let QMViewModel = QuickMapViewModel(state: .search, placeId: place.placeID)
                let QMController = QuickMapController(viewModel: QMViewModel)
                navigationController?.pushViewController(QMController, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - Configure UI

    private func configureUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar
            .rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - AddressSearchHeaderDelegate

extension SearchAddressController: AddressSearchHeaderDelegate {
    func handleSearchTapped(address: String) {
        Observable.just(address)
            .subscribe(onNext: { [weak self] str in
                self?.viewModel.searchText.accept(str)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate

extension SearchAddressController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
