//
//  UIColor+Extension.swift
//  ToTimer
//
//  Created by 김민국 on 2020/12/06.
//

import UIKit

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static let lightBlue = UIColor.rgb(red: 239, green: 243, blue: 244)
    static let ultraLightGray = UIColor.rgb(red: 230, green: 230, blue: 230)
    static let middleBlue = UIColor.rgb(red: 29, green: 161, blue: 242)
}
