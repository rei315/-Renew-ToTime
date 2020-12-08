//
//  UIView+Extension.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/08.
//

import UIKit

extension UIView {
    func roundCorner(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
