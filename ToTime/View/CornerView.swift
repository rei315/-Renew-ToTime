//
//  CornerView.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/08.
//

import UIKit

class CornerView: UIView {
    
    private var cornerRadius: CGFloat = 0
    
    init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.roundCorner(corners: [.topLeft, .topRight], radius: cornerRadius)
    }

}
