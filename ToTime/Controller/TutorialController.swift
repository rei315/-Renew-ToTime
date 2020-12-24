//
//  TutorialController.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/24.
//

import UIKit
import RxSwift

class TutorialController: UIViewController {

    // MARK: - Property
    
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
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTutorialView()
        configurePage()
        configureAction()
    }
    
    // MARK: - Configurate TutorialView
    
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
                        
        view.addSubview(tutorialDoneButton)
        tutorialDoneButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(50)
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalTo(50)
        }
    }
    
    // MARK: - Configure Page
    
    private func configurePage() {
        Observable.just(tutorialImages.count)
            .bind(to: tutorialPage.rx.numberOfPages)
            .disposed(by: disposeBag)
        
        let page = tutorialView.rx.didScroll
            .withLatestFrom(tutorialView.rx.contentOffset)
            .map { Int(round($0.x / self.view.frame.width)) }
            .share()
        
        page
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] page in
                if page == self.tutorialImages.count - 1 {
                    tutorialDoneButton.snp.updateConstraints { (make) in
                        make.bottom.equalToSuperview().offset(-100)
                    }
                    UIView.animate(withDuration: 0.8) {
                        self.view.layoutIfNeeded()
                    }
                } else {
                    tutorialDoneButton.snp.updateConstraints { (make) in
                        make.bottom.equalToSuperview().offset(50)
                    }
                    UIView.animate(withDuration: 0.4) {
                        self.view.layoutIfNeeded()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        page
            .bind(to: tutorialPage.rx.currentPage)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Action
    
    private func configureAction() {
        tutorialDoneButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [unowned self] _ in
                dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}
