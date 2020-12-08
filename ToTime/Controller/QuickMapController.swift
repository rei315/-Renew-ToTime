//
//  QuickMapController.swift
//  ToTimer
//
//  Created by 김민국 on 2020/12/06.
//

import UIKit
import RxCoreLocation
import RxSwift
import RxCocoa
import CoreLocation
import MapKit
import RxMKMapView
import SnapKit
import RxGesture

private let BottomViewHeight: CGFloat = 220

class QuickMapController: UIViewController {

    // MARK: - Property
    
    enum EditViewState { case on, off }
    enum EditState { case none, distance, favorite }
    enum DistanceState { case Fifty, Hundred, Thousand, EditValue }
    
    let disposeBag = DisposeBag()
    var viewModel: QuickMapViewModel!
    
    let mapView: MKMapView = MKMapView()
    
    var editViewState: EditViewState = .off
    var editState: EditState = .none
    var distanceState: DistanceState = .Fifty
    
    private lazy var centerDot: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(systemName: "circle")
        return iv
    }()
    
    private lazy var regionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var bottomView: UIView = {
        let bView = CornerView(cornerRadius: 15)
        bView.backgroundColor = .white
        return bView
    }()
    
    private lazy var distanceFiftyButton: UIButton = {
        let bt = UIButton()
        bt.layer.cornerRadius = 5
        bt.backgroundColor = .lightGray
        bt.setTitle("50M", for: .normal)
        return bt
    }()
    
    private lazy var distanceHundredButton: UIButton = {
        let bt = UIButton()
        bt.layer.cornerRadius = 5
        bt.backgroundColor = .lightGray
        bt.setTitle("100M", for: .normal)
        return bt
    }()
    
    private lazy var distanceThousandButton: UIButton = {
        let bt = UIButton()
        bt.layer.cornerRadius = 5
        bt.backgroundColor = .lightGray
        bt.setTitle("1000M", for: .normal)
        return bt
    }()
    
    private lazy var distanceEditButton: UIButton = {
        let bt = UIButton()
        bt.layer.cornerRadius = 5
        bt.backgroundColor = .lightGray
        bt.setTitle("직접입력", for: .normal)
//        bt.addTarget(self, action: #selector(handleDistanceTapped), for: .touchUpInside)
        return bt
    }()
    
    private lazy var favoriteButton: UIButton = {
        let bt = UIButton()
        bt.layer.cornerRadius = 8
        bt.backgroundColor = .middleBlue
        bt.setImage(UIImage(systemName: "star"), for: .normal)
        bt.tintColor = .white
//        bt.addTarget(self, action: #selector(handleEditFavorite), for: .touchUpInside)
        return bt
    }()
    
    private lazy var startButton: UIButton = {
        let bt = UIButton()
        bt.layer.cornerRadius = 8
        bt.backgroundColor = .middleBlue
        bt.setTitle("시작", for: .normal)
        return bt
    }()
    
    private lazy var valueEditDimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        return view
    }()
    
    private lazy var valueEditView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        return view
    }()
    
    private lazy var valueTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 20)
        tf.textColor = .black
        tf.attributedPlaceholder = NSAttributedString(string: "입력하세요", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
        tf.textAlignment = .center
        tf.borderStyle = .none
        return tf
    }()
    
    private lazy var valueEditButton: UIButton = {
        let bt = UIButton()
        bt.layer.cornerRadius = 8
        bt.backgroundColor = .middleBlue
        bt.setTitle("확인", for: .normal)
//        bt.addTarget(self, action: #selector(handleValueChanged), for: .touchUpInside)
        return bt
    }()
    
    private lazy var valueEditExitButton: UIButton = {
        let bt = UIButton()
        bt.setImage(UIImage(systemName: "multiply.circle"), for: .normal)
        bt.contentHorizontalAlignment = .fill
        bt.contentVerticalAlignment = .fill
        return bt
    }()
    
    private var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.isPagingEnabled = true
        return sv
    }()
    
    // MARK: - Lifecycle
    
    init(viewModel: QuickMapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureMapView()
        bindViewModel()
        configureBottomView()
        configureButtonAction()
        
        viewModel.markIcons
            .subscribe(onNext: { marks in
                marks.enumerated().forEach { [weak self] (index, image) in
                    let iv = UIImageView()
                    let offset = CGFloat(index) * 100
                    self?.scrollView.addSubview(iv)
                    iv.image = image
                    iv.snp.makeConstraints { (make) in
                        make.top.equalToSuperview()
                        make.left.equalToSuperview().offset(offset)
                        make.height.equalToSuperview()
                        make.width.equalTo(100)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func configureBottomView() {
        let topStack = UIStackView(arrangedSubviews: [distanceFiftyButton,
                                                   distanceHundredButton,
                                                   distanceThousandButton,
                                                   distanceEditButton])
        topStack.axis = .horizontal
        topStack.spacing = 10
        topStack.distribution = .fillEqually
                
        
        bottomView.addSubview(topStack)
        
        bottomView.addSubview(regionLabel)
        bottomView.addSubview(favoriteButton)
        bottomView.addSubview(startButton)
//        bottomView.addSubview(scrollView)
        
        view.addSubview(bottomView)
                        
        bottomView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(view.frame.height-BottomViewHeight)
        }
        
        topStack.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(20)
        }
        
        regionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topStack.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        startButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(regionLabel.snp.bottom).offset(20)
            make.height.equalTo(BottomViewHeight/4)
            make.width.equalTo(view.frame.width-110)
        }
        
        favoriteButton.snp.makeConstraints { (make) in
            make.left.equalTo(startButton.snp.right).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalTo(startButton.snp.centerY)
            make.height.equalTo(startButton.snp.height)
        }
        
//        scrollView.snp.makeConstraints({ (make) in
//            make.left.equalToSuperview()
//            make.right.equalToSuperview()
//            make.centerY.equalToSuperview()
//        })
    }
    
    private func editOnFavorite() {
        bottomView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(view.frame.height-(BottomViewHeight*3))
            make.bottom.equalToSuperview()
        }
        startButton.snp.updateConstraints { (make) in
            make.left.equalToSuperview().offset(0)
            make.width.equalTo(0)
        }

        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
        favoriteButton.setTitle(" 즐겨찾기 취소", for: .normal)
    }
    
    private func editOffFavorite() {
        bottomView.snp.updateConstraints { (make) in
            make.bottom.equalToSuperview().offset(view.frame.height-BottomViewHeight)
            make.top.equalToSuperview().offset(view.frame.height-BottomViewHeight)
        }
        
        startButton.snp.updateConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(view.frame.width-110)
        }
                        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
        favoriteButton.setTitle("", for: .normal)
    }
    
    private func configureMapView() {
//        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.rx
            .regionDidChangeAnimated
            .map { _ in CLLocation(latitude: self.mapView.centerCoordinate.latitude, longitude: self.mapView.centerCoordinate.longitude) }
            .bind(to: viewModel.didRegionChanged)
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        viewModel.didUpdateLocation
            .subscribe(onNext: { [weak self] loc in
                let span = MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009)
                let region = MKCoordinateRegion(center: loc.coordinate, span: span)
                self?.mapView.setRegion(region, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.didRegionChangedStr
            .map { AppString.destination + ": " + $0 }
            .bind(to: regionLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        view.addSubview(mapView)
        mapView.addSubview(centerDot)
        
        mapView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        centerDot.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        valueEditDimView.addSubview(valueEditView)
        valueEditDimView.addSubview(valueEditExitButton)
        valueEditView.addSubview(valueTextField)
        valueEditView.addSubview(valueEditButton)
        
        valueEditExitButton.snp.makeConstraints { (make) in
            make.width.equalTo(valueEditView.snp.width).dividedBy(3)
            make.height.equalTo(valueEditView.snp.width).dividedBy(3)
            make.bottom.equalTo(valueEditView.snp.top).offset(-20)
            make.centerX.equalToSuperview()
        }
        
        valueEditView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(view.frame.width/2)
            make.height.equalTo(view.frame.height/6)
        }
        
        valueTextField.snp.makeConstraints { (make) in
            make.bottom.equalTo(valueEditButton.snp.top).offset(-20)
            make.centerX.equalToSuperview()
        }
        valueEditButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalTo(view.frame.width/3)
        }
    }
    
    private func resetDistanceButtonConfigure() {
        switch self.distanceState {
        case .Fifty:
            distanceFiftyButton.backgroundColor = .lightGray
        case .Hundred:
            distanceHundredButton.backgroundColor = .lightGray
        case .Thousand:
            distanceThousandButton.backgroundColor = .lightGray
        case .EditValue:
            distanceEditButton.setTitle("직접입력", for: .normal)
            distanceEditButton.backgroundColor = .lightGray
        }
    }
    
    // MARK: - Selectors
    
    private func configureButtonAction() {
        valueEditDimView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                if let state = self?.editState {
                    switch (state) {
                    case .distance:
                        self?.valueTextField.resignFirstResponder()
                    case .favorite:
                        break
                    case .none:
                        break
                    }
                }
            })
            .disposed(by: disposeBag)
        
        distanceFiftyButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.resetDistanceButtonConfigure()
                self?.distanceState = .Fifty
                self?.distanceFiftyButton.backgroundColor = .red
            })
            .disposed(by: disposeBag)
        distanceHundredButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.resetDistanceButtonConfigure()
                self?.distanceState = .Hundred
                self?.distanceHundredButton.backgroundColor = .red
            })
            .disposed(by: disposeBag)
        distanceThousandButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.resetDistanceButtonConfigure()
                self?.distanceState = .Thousand
                self?.distanceThousandButton.backgroundColor = .red
            })
            .disposed(by: disposeBag)
        distanceEditButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.resetDistanceButtonConfigure()
                self?.distanceState = .EditValue
                self?.distanceEditButton.backgroundColor = .red
                self?.handleDistanceTapped()
            })
            .disposed(by: disposeBag)
        
        favoriteButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.handleEditFavorite()
            })
            .disposed(by: disposeBag)
        
        valueEditButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.handleValueChanged()
            })
            .disposed(by: disposeBag)
        
        valueEditExitButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.disableValueEditor()
            })
            .disposed(by: disposeBag)
    }
    
    private func ableValueEditor() {
        view.addSubview(valueEditDimView)
        
        valueEditDimView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalToSuperview()
        }
    }
    
    private func disableValueEditor() {
        switch editState {
        case .distance:
            if valueTextField.text == "" {
                distanceEditButton.setTitle("0M", for: .normal)
            }
        case .favorite:
            break
        case .none:
            break
        }
        valueEditDimView.removeFromSuperview()
    }
    
    func handleDistanceTapped() {
        editState = .distance
        valueTextField.keyboardType = .numberPad
        ableValueEditor()
    }
    func handleFavoriteLabelTapped() {
        editState = .favorite
        valueTextField.keyboardType = .default
        ableValueEditor()
    }
    
    func handleValueChanged() {
        switch (editState) {
        case .distance:
            let value = valueTextField.text ?? "0"
            distanceEditButton.setTitle(value + "M", for: .normal)
            break
        case .favorite:
            break
        case .none:
            break
        }
        disableValueEditor()
    }
    
    private func handleEditFavorite() {
        switch (editViewState) {
        case .on:
            self.editOffFavorite()
            editViewState = .off
        case .off:
            self.editOnFavorite()
            editViewState = .on
        }
    }
}
