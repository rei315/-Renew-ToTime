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

class QuickMapController: UIViewController {

    // MARK: - Property
    
    let disposeBag = DisposeBag()
    let viewModel = QuickMapViewModel()
    
    let mapView: MKMapView = MKMapView()
    
    private lazy var centerDot: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(systemName: "circle")
        return iv
    }()
    
    private lazy var regionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .purple
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureMapView()
        bindViewModel()
    }
    
    private func configureMapView() {
//        mapView.delegate = self
//        mapView.showsUserLocation = true
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
            .bind(to: regionLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        view.addSubview(mapView)
        mapView.addSubview(centerDot)
        mapView.addSubview(regionLabel)
        
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
        
        regionLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
        }
    }
}
