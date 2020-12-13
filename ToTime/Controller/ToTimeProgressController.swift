//
//  ToTimeProgressController.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/12.
//

import UIKit
import RxSwift
import RxCocoa

class ToTimeProgressController: UIViewController {

    // MARK: - Property
    
    let disposeBag = DisposeBag()
    let viewModel: ToTimeProgressViewModel!
    
    private weak var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    
    private let shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 3
        return shapeLayer
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
        
        viewModel.startLocationNotification()

        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureUI()
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
        view.backgroundColor = .blue
        view.layer.addSublayer(shapeLayer)
        startDisplayLink()
        animateFish()
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
        let duration = 1.7
        
        let path = UIBezierPath()
        
        let imageFishName = "Fish"
        let imageFish = UIImage(named: imageFishName)
        let imageView = UIImageView(image: imageFish)
        
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        imageView.backgroundColor = .clear
        
        self.view.addSubview(imageView)
        
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
        
        imageView.layer.add(animation, forKey: nil)
        imageView.layer.add(rotationAnimation, forKey: nil)
        
        imageView.center = CGPoint(x: 0, y: self.view.frame.midY)
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
