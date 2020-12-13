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
    enum DistanceState: Int{
        case Fifty = 50
        case Hundred = 100
        case Thousand = 1000
        case EditValue = 0
    }
    
    let disposeBag = DisposeBag()
    var viewModel: QuickMapViewModel!
    
    let mapView: MKMapView = MKMapView()
    
    var editViewState: EditViewState = .off
    var editState: EditState = .none
    var distanceState: DistanceState = .Fifty
    
    private lazy var regionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var bottomView: UIView = {
        let bView = CornerView(cornerRadius: 12)
        bView.backgroundColor = .lightBlue
        return bView
    }()
    
    private lazy var distanceFiftyButton: UIButton = {
        let bt = UIButton()
        bt.layer.cornerRadius = 5
        bt.backgroundColor = .lightGray
        bt.setTitle(AppString.Fifty.localized(), for: .normal)
        bt.backgroundColor = .red
        return bt
    }()
    
    private lazy var distanceHundredButton: UIButton = {
        let bt = UIButton()
        bt.layer.cornerRadius = 5
        bt.backgroundColor = .lightGray
        bt.setTitle(AppString.Hundred.localized(), for: .normal)
        return bt
    }()
    
    private lazy var distanceThousandButton: UIButton = {
        let bt = UIButton()
        bt.layer.cornerRadius = 5
        bt.backgroundColor = .lightGray
        bt.setTitle(AppString.Thousand.localized(), for: .normal)
        return bt
    }()
    
    private lazy var distanceEditButton: UIButton = {
        let bt = UIButton()
        bt.layer.cornerRadius = 5
        bt.backgroundColor = .lightGray
        bt.setTitle(AppString.DistanceEdit.localized(), for: .normal)
        return bt
    }()
    
    private lazy var favoriteButton: UIButton = {
        let bt = UIButton()
        bt.layer.cornerRadius = 8
        bt.backgroundColor = .middleBlue
        bt.setImage(UIImage(systemName: "star"), for: .normal)
        bt.tintColor = .white
        return bt
    }()
    
    private lazy var startButton: UIButton = {
        let bt = UIButton()
        bt.layer.cornerRadius = 8
        bt.backgroundColor = .middleBlue
        bt.setTitle(AppString.QuickMapStart.localized(), for: .normal)
        return bt
    }()
    
    private lazy var valueEditDimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
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
        tf.attributedPlaceholder = NSAttributedString(string: AppString.QuickMapEditValuePlaceHolder.localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
        tf.textAlignment = .center
        tf.borderStyle = .none
        tf.returnKeyType = .done
        return tf
    }()
    
    private lazy var valueEditButton: UIButton = {
        let bt = UIButton()
        bt.layer.cornerRadius = 8
        bt.backgroundColor = .middleBlue
        bt.setTitle(AppString.Enter.localized(), for: .normal)
        return bt
    }()
    
    private lazy var valueEditExitButton: UIButton = {
        let bt = UIButton()
        bt.setImage(UIImage(systemName: "multiply.circle"), for: .normal)
        bt.contentHorizontalAlignment = .fill
        bt.contentVerticalAlignment = .fill
        return bt
    }()
    
    private lazy var favoriteField: PaddingTextField = {
        let tf = PaddingTextField(padding: 10, type: .Default)
        tf.font = UIFont.systemFont(ofSize: 18)
        tf.attributedPlaceholder = NSAttributedString(string: AppString.QuickMapNamePlaceHolder.localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
//        tf.backgroundColor = .lightBlue
        tf.layer.borderColor = UIColor.middleBlue.cgColor
        tf.layer.borderWidth = 1.5
        tf.layer.cornerRadius = 4.0
        tf.allowsEditingTextAttributes = false
        tf.textAlignment = .center
        return tf
    }()
    
    private lazy var favoriteView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightBlue
        return view
    }()
    
    private lazy var favoriteIconButton: UIButton = {
        let bt = UIButton()
        bt.layer.cornerRadius = 8
        bt.backgroundColor = .lightGray
        bt.setImage(UIImage(systemName: "plus"), for: .normal)
        bt.tintColor = .white
        return bt
    }()
    
    private lazy var favoriteCreateButton: UIButton = {
        let bt = UIButton()
        bt.layer.cornerRadius = 8
        bt.backgroundColor = .middleBlue
        bt.setTitle(AppString.QuickMapAddFavorite.localized(), for: .normal)
        bt.tintColor = .white
        return bt
    }()
    
    private lazy var favoriteDeleteButton: UIButton = {
        let bt = UIButton()
        bt.layer.cornerRadius = 8
        bt.backgroundColor = .middleBlue
        bt.setImage(UIImage(systemName: "trash"), for: .normal)
        bt.tintColor = .white
        return bt
    }()

    private var imageURL: String = ""
    
    // MARK: - Lifecycle
    
    init(viewModel: QuickMapViewModel) {
        self.viewModel = viewModel
        if viewModel.state == .favorite {
            self.imageURL = viewModel.realmMark?.iconImage ?? ""
        }
        
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
        configureBottomView()
        configureButtonAction()
        bindViewModel()
    }
    
    // MARK: - Configure MapView
    
    private func configureMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.rx
            .regionDidChangeAnimated
            .map { _ in CLLocation(latitude: self.mapView.centerCoordinate.latitude, longitude: self.mapView.centerCoordinate.longitude) }
            .bind(to: viewModel.didRegionChanged)
            .disposed(by: disposeBag)
        mapView.rx
            .regionDidChangeAnimated
            .subscribe(onNext: { [weak self] _ in
                self?.showCircle(meter: self?.distanceState ?? .Fifty)
            })
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - Helpers
    
    private func showCircle(meter radius: DistanceState) {
        var distance = 0
        
        if radius == .EditValue {
            distance = getValueFromField(valueStr: valueTextField.text ?? "")
        } else {
            distance = radius.rawValue
        }

        mapView.removeOverlays(mapView.overlays)

        let cllDistance = CLLocationDistance(distance)
        let circle = MKCircle(center: self.mapView.centerCoordinate, radius: cllDistance)
        mapView.addOverlay(circle)
    }
    
    private func getValueFromField(valueStr: String) -> Int {
        let filterStr = valueStr.filter { $0.isNumber }
        if let valueInt = Int(filterStr) {
            return valueInt
        }
        return 0
    }
    
    private func setDistanceValue(value: String) {
        distanceEditButton.setTitle(value + "M", for: .normal)
    }
    
    private func getDistanceValue() -> Int {
        switch distanceState {
        case .Fifty:
            return DistanceState.Fifty.rawValue
        case .Hundred:
            return DistanceState.Hundred.rawValue
        case .Thousand:
            return DistanceState.Thousand.rawValue
        case .EditValue:
            return getValueFromField(valueStr: distanceEditButton.title(for: .normal) ?? "")
        }
    }
    
    private func parseUpdateData(name: String, address: String, iconImageUrl: String, latitude: Double, longitude: Double) -> QuickMapViewModel.UpdateData {
        return (name: name, address: address, iconImageUrl: iconImageUrl, latitude: latitude, longitude: longitude)
    }
    
    // MARK: - Bind ViewModel
    
    private func bindViewModel() {
        mapView.rx.didFinishLoadingMap
            .take(1)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.configureState()
            })
            .disposed(by: disposeBag)
        
        viewModel.didUpdateLocation
            .take(1)
            .subscribe(onNext: { [weak self] loc in
                let span = MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009)
                let region = MKCoordinateRegion(center: loc.coordinate, span: span)
                self?.mapView.setRegion(region, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.didRegionChangedStr
            .map { AppString.Destination + ": " + $0 }
            .bind(to: regionLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.didCreateCompleted
            .subscribe(onNext: { [weak self] _ in
                let action = UIAlertAction(title: AppString.Enter.localized(), style: .default) { _ in
                    self?.navigationController?.popToRootViewController(animated: true)
                }
                self?.showAlert(title: AppString.CreatedComplete.localized(), message: AppString.FavoriteCreated.localized(), style: .alert, action: action)
            })
            .disposed(by: disposeBag)
        
        viewModel.didUpdateCompleted
            .subscribe(onNext: { [weak self] _ in
                let action = UIAlertAction(title: AppString.Enter.localized(), style: .default) { _ in
                    self?.navigationController?.popToRootViewController(animated: true)
                }
                self?.showAlert(title: AppString.UpdateComplete.localized(), message: AppString.FavoriteUpdated.localized(), style: .alert, action: action)
            })
            .disposed(by: disposeBag)
        
        viewModel.didDeleteCompleted
            .subscribe(onNext: { _ in
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.permissionError
            .flatMap(Observable.from(optional: ))
            .subscribe(onNext: { [weak self] _ in
                let action = UIAlertAction(title: AppString.Enter.localized(), style: .default) { (_) in
                    self?.navigationController?.popToRootViewController(animated: true)
                }
                self?.showAlert(title: AppString.LocationDeniedTitle.localized(), message: AppString.LocationDeniedMessage.localized(), style: .alert, action: action)
                
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Configurate UI
    
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
                
    }
    
    private func editOnFavorite() {
        bottomView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(view.frame.height-(BottomViewHeight*2.5))
            make.bottom.equalToSuperview()
        }
        startButton.snp.updateConstraints { (make) in
            make.left.equalToSuperview().offset(0)
            make.width.equalTo(0)
        }

        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
        favoriteButton.setTitle(AppString.QuickMapDeleteFavorite.localized(), for: .normal)
        favoriteButton.backgroundColor = .middlePink
            
        favoriteView.addSubview(favoriteField)
        favoriteView.addSubview(favoriteCreateButton)
        favoriteView.addSubview(favoriteIconButton)
        
        bottomView.addSubview(favoriteView)
        
        favoriteView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-40)
            make.top.equalTo(startButton.snp.bottom).offset(40)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        favoriteField.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.15)
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        favoriteIconButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(favoriteIconButton.snp.width)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.top.equalToSuperview()
        }
        
        if self.viewModel.state == .favorite {
            favoriteField.text = viewModel.realmMark?.name
            let image = ResourceManager.shared.loadImageWithFileName(fileName: viewModel.realmMark?.iconImage ?? "")
            setFavoriteIcon(image: image)
            
            favoriteView.addSubview(favoriteDeleteButton)
            favoriteCreateButton.setTitle(AppString.QuickMapModifyFavorite.localized(), for: .normal)
            favoriteCreateButton.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(20)
                make.height.equalTo(startButton.snp.height)
                make.width.equalToSuperview().multipliedBy(0.7)
                make.bottom.equalToSuperview()
            }
            
            favoriteDeleteButton.snp.makeConstraints { (make) in
                make.left.equalTo(favoriteCreateButton.snp.right).offset(20)
                make.right.equalToSuperview().offset(-20)
                make.centerY.equalTo(favoriteCreateButton.snp.centerY)
                make.height.equalTo(favoriteCreateButton.snp.height)
            }
        } else {
            favoriteCreateButton.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.height.equalTo(startButton.snp.height)
                make.width.equalToSuperview().multipliedBy(0.8)
                make.bottom.equalToSuperview()
            }
        }
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
        favoriteButton.backgroundColor = .middleBlue
        
        favoriteField.removeFromSuperview()
        favoriteIconButton.removeFromSuperview()
        favoriteCreateButton.removeFromSuperview()
        
        if self.viewModel.state == .favorite {
            favoriteDeleteButton.removeFromSuperview()
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        view.addSubview(mapView)
        
        mapView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(BottomViewHeight*0.97))
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
            make.height.equalTo(view.frame.height/5.5)
        }
        
        valueTextField.snp.makeConstraints { (make) in
            make.bottom.equalTo(valueEditButton.snp.top).offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.top.lessThanOrEqualToSuperview().offset(20)
        }
        valueEditButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-10)
            make.centerX.equalToSuperview()
            make.width.equalTo(view.frame.width/3)
            make.height.equalToSuperview().multipliedBy(0.3)
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
            distanceEditButton.backgroundColor = .lightGray
        }
    }
    
    private func setFavoriteIcon(image: UIImage) {
        favoriteIconButton.backgroundColor = .clear
        favoriteIconButton.layer.borderColor = UIColor.lightGray.cgColor
        favoriteIconButton.layer.borderWidth = 1.5
        favoriteIconButton.layer.cornerRadius = 8
        favoriteIconButton.contentVerticalAlignment = .fill
        favoriteIconButton.contentHorizontalAlignment = .fill
        favoriteIconButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        favoriteIconButton.setImage(image, for: .normal)
    }
    
    // MARK: - Action
    
    private func configureButtonAction() {
        
        startButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                let coor = self?.mapView.centerCoordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
                let address = self?.regionLabel.text ?? ""
                let distance = self?.getDistanceValue() ?? 0
                let vm = ToTimeProgressViewModel(address: address, location: coor, distance: distance)
                let vc = ToTimeProgressController(viewModel: vm)
                self?.present(vc, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        valueEditDimView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                if let state = self?.editState {
                    switch (state) {
                    case .distance:
                        self?.valueTextField.resignFirstResponder()
                    case .favorite:
                        self?.favoriteField.resignFirstResponder()
                        break
                    case .none:
                        break
                    }
                }
            })
            .disposed(by: disposeBag)
        
        distanceFiftyButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.resetDistanceButtonConfigure()
                self?.distanceState = .Fifty
                self?.distanceFiftyButton.backgroundColor = .red
                self?.showCircle(meter: .Fifty)
            })
            .disposed(by: disposeBag)
        distanceHundredButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.resetDistanceButtonConfigure()
                self?.distanceState = .Hundred
                self?.distanceHundredButton.backgroundColor = .red
                self?.showCircle(meter: .Hundred)
            })
            .disposed(by: disposeBag)
        distanceThousandButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.resetDistanceButtonConfigure()
                self?.distanceState = .Thousand
                self?.distanceThousandButton.backgroundColor = .red
                self?.showCircle(meter: .Thousand)
            })
            .disposed(by: disposeBag)
        distanceEditButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.resetDistanceButtonConfigure()
                self?.distanceState = .EditValue
                self?.distanceEditButton.backgroundColor = .red
                self?.handleDistanceTapped()
            })
            .disposed(by: disposeBag)
        
        favoriteButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.handleEditFavorite()
            })
            .disposed(by: disposeBag)
        
        valueEditButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.handleValueChanged()
            })
            .disposed(by: disposeBag)
        
        valueTextField.rx.controlEvent([.editingDidEndOnExit])
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
        
        favoriteField.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.handleFavoriteLabelTapped()
            })
            .disposed(by: disposeBag)

        favoriteIconButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                let vm = IconSelectorViewModel()
                let vc = IconSelectorController(viewModel: vm)
                vc.delegate = self
                self?.present(vc, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        if self.viewModel.state == .favorite {
            favoriteCreateButton.rx.tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [weak self] _ in
                    let name = self?.favoriteField.text ?? ""
                    let coor = self?.mapView.centerCoordinate
                    let address = self?.regionLabel.text ?? ""
                    let data = self?.parseUpdateData(name: name, address: address, iconImageUrl: self?.imageURL ?? "", latitude: coor?.latitude ?? 0, longitude: coor?.longitude ?? 0)
                    
                    if self?.checkFavoriteAvailable(address: data?.address ?? "", name: data?.name ?? "") != true { return }
                    self?.viewModel.didUpdateTapped.accept(data)
                })
                .disposed(by: disposeBag)
        } else {
            favoriteCreateButton.rx.tapGesture()
                .when(.recognized)
                .map { [weak self] _ -> MarkRealm in
                    let identity = "\(Date())"
                    let name = self?.favoriteField.text ?? ""
                    let coor = self?.mapView.centerCoordinate
                    let address = self?.regionLabel.text ?? ""
                    return MarkRealm(identity: identity, name: name, latitude: coor?.latitude ?? 0, longitude: coor?.longitude ?? 0, address: address, iconImageUrl: self?.imageURL ?? "")
                }
                .subscribe(onNext: { [weak self] data in
                    if self?.checkFavoriteAvailable(address: data.address, name: data.name) != true { return }
                    self?.viewModel.didCreateTapped.accept(data)
                })
                .disposed(by: disposeBag)
        }
                
        favoriteDeleteButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.didDeleteTapped.accept(())
            })
            .disposed(by: disposeBag)
    }
    
    private func checkFavoriteAvailable(address: String, name: String) -> Bool {
        if (address == "") {
            let action = UIAlertAction(title: AppString.Enter.localized(), style: .default)
            showAlert(title: AppString.InputError.localized(), message: AppString.FavoriteAddressEmptyAlertMessage.localized(), style: .alert, action: action)
            return false
        }
        if (name == "") {
            let action = UIAlertAction(title: AppString.Enter.localized(), style: .default)
            showAlert(title: AppString.InputError.localized(), message: AppString.FavoriteNameEmptyAlertMessage.localized(), style: .alert, action: action)
            return false
        }
        if (self.imageURL == "") {
            let action = UIAlertAction(title: AppString.Enter.localized(), style: .default)
            showAlert(title: AppString.InputError.localized(), message: AppString.FavoriteImageEmptyAlertMessage.localized(), style: .alert, action: action)
            return false
        }
        return true
    }
    
    private func ableValueEditor() {
        valueTextField.becomeFirstResponder()
        view.addSubview(valueEditDimView)
        
        valueEditDimView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalToSuperview()
        }
    }
    
    private func disableValueEditor() {
        switch editState {
        case .distance:
            if valueTextField.text == "" {
                let distance = getValueFromField(valueStr: distanceEditButton.title(for: .normal) ?? "")
                if distance == 0 {
                    mapView.removeOverlays(mapView.overlays)
                }
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
        if let valueStr = distanceEditButton.title(for: .normal) {
            let value = getValueFromField(valueStr: valueStr)
            if value != 0 {
                valueTextField.text = "\(value)"
            } else {
                valueTextField.text = ""
            }
        }

        valueTextField.keyboardType = .numberPad
        ableValueEditor()
    }
    func handleFavoriteLabelTapped() {
        if favoriteField.text == "" {
            valueTextField.text = ""
        } else {
            valueTextField.text = favoriteField.text
        }
        
        editState = .favorite
        valueTextField.keyboardType = .default
        ableValueEditor()
    }
    
    func handleValueChanged() {
        switch (editState) {
        case .distance:
            if valueTextField.text == "" {
                distanceEditButton.setTitle(AppString.DistanceEdit.localized(), for: .normal)
                mapView.removeOverlays(mapView.overlays)
            } else {
                let value = valueTextField.text ?? "0"
                self.setDistanceValue(value: value)
                showCircle(meter: .EditValue)
            }
            break
        case .favorite:
            favoriteField.text = valueTextField.text
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

extension QuickMapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circle = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: circle)
            circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.2)
            return circleRenderer
        }
        return MKOverlayRenderer()
    }
}

extension QuickMapController: IconSelectorDelegate {
    func didIconSelected(iconImage image: UIImage, url: String) {
        if image != UIImage() {
            self.imageURL = ResourceManager.shared.getFileName(fullURL: url)            
            setFavoriteIcon(image: image)
        }
    }
}
