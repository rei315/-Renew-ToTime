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
    
    private let tutorialView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .white
        return sv
    }()
    private let tutorialPage: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = UIColor.middleBlue
        pc.currentPageIndicatorTintColor = UIColor.systemOrange
        return pc
    }()
    private let tutorialDoneButton: UIButton = {
        let bt = UIButton()
        bt.backgroundColor = UIColor.systemOrange
        bt.layer.cornerRadius = 8
        bt.tintColor = .white
        bt.setTitle(AppString.TutorialDoneTitle.localized(), for: .normal)
        return bt
    }()
    
    private var tutorialImages: [UIImage] = []
    
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
        
        let lanchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !lanchedBefore {
            UserDefaults.standard.setValue(true, forKey: "launchedBefore")
            configureTutorialView()
        }        
    }
    
    
    // MARK: - TutorialView
    
    private func configureTutorialView() {
                
        view.addSubview(tutorialView)
        view.addSubview(tutorialPage)
        
        switch Locale.current.languageCode {
        case "en":
            tutorialImages.append(UIImage(named: "tutorial_eng_1") ?? UIImage())
            tutorialImages.append(UIImage(named: "tutorial_eng_2") ?? UIImage())
            tutorialImages.append(UIImage(named: "tutorial_eng_3") ?? UIImage())
            tutorialImages.append(UIImage(named: "tutorial_eng_4") ?? UIImage())
        case "ko":
            tutorialImages.append(UIImage(named: "tutorial_ko_1") ?? UIImage())
            tutorialImages.append(UIImage(named: "tutorial_ko_2") ?? UIImage())
            tutorialImages.append(UIImage(named: "tutorial_ko_3") ?? UIImage())
            tutorialImages.append(UIImage(named: "tutorial_ko_4") ?? UIImage())
        case "ja":
            tutorialImages.append(UIImage(named: "tutorial_ja_1") ?? UIImage())
            tutorialImages.append(UIImage(named: "tutorial_ja_2") ?? UIImage())
            tutorialImages.append(UIImage(named: "tutorial_ja_3") ?? UIImage())
            tutorialImages.append(UIImage(named: "tutorial_ja_4") ?? UIImage())
        case .none:
            tutorialImages.append(UIImage(named: "tutorial_eng_1") ?? UIImage())
            tutorialImages.append(UIImage(named: "tutorial_eng_2") ?? UIImage())
            tutorialImages.append(UIImage(named: "tutorial_eng_3") ?? UIImage())
            tutorialImages.append(UIImage(named: "tutorial_eng_4") ?? UIImage())
            break
        case .some(_):
            break
        }
        
        let pageWidth = self.view.frame.width
        tutorialView.isPagingEnabled = true
        tutorialView.showsHorizontalScrollIndicator = false
        
        tutorialView.contentSize = CGSize(width: CGFloat(tutorialImages.count) * self.view.frame.maxX, height: 0)
        tutorialView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tutorialImages.enumerated().forEach { index, image in
            let backView = UIView()
            let iv = UIImageView()
            iv.image = image
            iv.contentMode = .scaleAspectFit            
            backView.addSubview(iv)
            
            tutorialView.addSubview(backView)
            
            let offset = CGFloat(index) * pageWidth
            
            backView.snp.makeConstraints { (make) in
                make.width.equalTo(view.frame.width)
                make.height.equalTo(view.frame.height)
                make.left.equalTo(tutorialView).offset(offset)
                make.centerY.equalToSuperview()
            }
            
            iv.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
                make.top.equalTo(tutorialPage.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
            }
        }
        tutorialPage.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(70)
        }
        
        
        Observable.just(tutorialImages.count)
            .bind(to: tutorialPage.rx.numberOfPages)
            .disposed(by: disposeBag)
        
        let page = tutorialView.rx.didScroll
            .withLatestFrom(tutorialView.rx.contentOffset)
            .map { Int(round($0.x / pageWidth)) }
            .share()
        
        page
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] page in
                if page == self.tutorialImages.count - 1 {
                    view.addSubview(tutorialDoneButton)
                    
                    tutorialDoneButton.snp.makeConstraints { (make) in
                        make.centerX.equalToSuperview()
                        make.bottom.equalToSuperview().offset(-100)
                        make.width.equalToSuperview().multipliedBy(0.4)
                        make.height.equalTo(50)
                    }
                } else {
                    tutorialDoneButton.removeFromSuperview()
                }
            })
            .disposed(by: disposeBag)
        
        page
            .bind(to: tutorialPage.rx.currentPage)
            .disposed(by: disposeBag)
        
        tutorialDoneButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [unowned self] _ in
                tutorialView.removeFromSuperview()
                tutorialPage.removeFromSuperview()
                tutorialDoneButton.removeFromSuperview()
            })
            .disposed(by: disposeBag)
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
