//
//  ToTimeProgressController.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/12.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ToTimeProgressController: UIViewController {

    // MARK: - Property
    
    let disposeBag = DisposeBag()
    let viewModel: ToTimeProgressViewModel!
    
    private weak var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    
    private var isFishSetup: Bool = false
    private let fishImageView = UIImageView(image: UIImage(named: "Fish"))
    
    private let shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 3
        return shapeLayer
    }()
    
    private lazy var seperator: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .ultraLightGray
        iv.layer.cornerRadius = 1.5
        return iv
    }()
    
    // MARK: - Lifecycle
    
    init(viewModel: ToTimeProgressViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel.locationNotificationScheduler.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startUpdatingLocation()
        bindViewModel()
    }

    func scheduledTimerWithTimeInterval() {
//        let _ = Timer.scheduledTimer(timeInterval: 2.9, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        self.fishImageView.layer.removeAllAnimations()
        let randomCGFloat = CGFloat.random(in: 0...self.view.frame.maxX*0.9)
        self.fishImageView.center = CGPoint(x: randomCGFloat, y: self.view.frame.midY)
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: randomCGFloat, y: self.view.frame.midY))
        path.addQuadCurve(to: CGPoint(x: self.view.frame.maxX+randomCGFloat, y: self.view.frame.midY), controlPoint: CGPoint(x: self.view.frame.midX+randomCGFloat, y: 0))
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path.cgPath

        animation.duration = 1.5
        animation.repeatCount = 2
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = -Double.pi/4
        rotationAnimation.toValue = Double.pi/4
        rotationAnimation.duration = 1.5
        rotationAnimation.repeatCount = 2
        
        self.fishImageView.layer.add(animation, forKey: "position")
        self.fishImageView.layer.add(rotationAnimation, forKey: "rotation")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.stopUpdatingLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureUI()
        animateFish()
    }
        
    // MARK: - Helpers
    
    func startUpdatingLocation() {
        viewModel.startLocationNotification()
    }
    
    
    // MARK: - Bind ViewModel
    
    func bindViewModel() {
        viewModel.didArrivedLocation
            .flatMap(Observable.from(optional: ))
            .subscribe(onNext: { [weak self] _ in
                let info = LocationNotificationInfo(notificationId: AppString.NotificationID, locationId: AppString.LocationID, title: AppString.NotificationTitle.localized(), body: AppString.NotificationBody.localized(), data: ["Location":"Arrived"])
                self?.viewModel.stopLocationNotification(info: info)
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Configure UI
    
    func configureUI() {
        view.backgroundColor = .middleBlue
        
        view.addSubview(seperator)
        seperator.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(3)
            make.width.equalToSuperview().multipliedBy(0.25)
        }
        
        view.layer.addSublayer(shapeLayer)
        startDisplayLink()
        
    }
    
    // MARK: - Helpers
    
    private func startDisplayLink() {
        startTime = CACurrentMediaTime()
        self.displayLink?.invalidate()
        let displayLink = CADisplayLink(target: self, selector:#selector(handleDisplayLink(_:)))
        displayLink.add(to: .main, forMode: .common)
        self.displayLink = displayLink
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
    }
    
    @objc func handleDisplayLink(_ displayLink: CADisplayLink) {
        let elapsed = CACurrentMediaTime() - startTime
        shapeLayer.path = wave(at: elapsed).cgPath
    }
    
    private func wave(at elapsed: Double) -> UIBezierPath {
        let elapsed = CGFloat(elapsed)
        let centerY = view.bounds.midY
        let amplitude = 40 - abs(elapsed.remainder(dividingBy: 3)) * 40
        
        func f(_ x: CGFloat) -> CGFloat {
            return sin((x + elapsed) * 1.5 * .pi) * amplitude + centerY
        }
        
        let path = UIBezierPath()
        let steps = Int(view.bounds.width / 10)
        
        path.move(to: CGPoint(x: 0, y: f(0)))
        for step in 1 ... steps {
            let x = CGFloat(step) / CGFloat(steps)
            path.addLine(to: CGPoint(x: x * view.bounds.width, y: f(x)))
        }
        
        return path
    }
    
    func animateFish() {
        if isFishSetup { return }
        isFishSetup = !isFishSetup
        
        let duration = 1.5

        fishImageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        fishImageView.backgroundColor = .clear

        self.view.addSubview(fishImageView)

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: self.view.frame.midY))
        path.addQuadCurve(to: CGPoint(x: self.view.frame.maxX, y: self.view.frame.midY), controlPoint: CGPoint(x: self.view.frame.midX, y: 0))

        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path.cgPath

        animation.duration = duration
        animation.repeatCount = .infinity

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = -Double.pi/4
        rotationAnimation.toValue = Double.pi/4
        rotationAnimation.duration = duration
        rotationAnimation.repeatCount = .infinity

        fishImageView.layer.add(animation, forKey: "position")
        fishImageView.layer.add(rotationAnimation, forKey: nil)
        
        fishImageView.center = CGPoint(x: 0, y: self.view.frame.midY)
        
        scheduledTimerWithTimeInterval()
    }
}

// MARK: - LocationNotificationSchedulerDelegate

extension ToTimeProgressController: LocationNotificationSchedulerDelegate {
    func notificationPermissionDenied() {
        let action = UIAlertAction(title: AppString.Enter.localized(), style: .default) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        self.showAlert(title: AppString.NotificationPermissionTitle.localized(), message: AppString.NotificationPermissionMessage.localized(), style: .alert, action: action)
    }
    
    func locationPermissionDenied() {
        let action = UIAlertAction(title: AppString.Enter.localized(), style: .default) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        self.showAlert(title: AppString.LocationDeniedTitle.localized(), message: AppString.LocationDeniedMessage.localized(), style: .alert, action: action)
    }
    
    func notificationScheduled(error: Error?) {
        if let _ = error {
            let action = UIAlertAction(title: AppString.Enter.localized(), style: .default) { (_) in
                self.dismiss(animated: true, completion: nil)
            }
            self.showAlert(title: AppString.NotificationErrorTitle.localized(), message: AppString.NotificationErrorMessage.localized(), style: .alert, action: action)
        }
    }
}
