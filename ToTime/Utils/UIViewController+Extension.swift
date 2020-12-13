//
//  UIViewController+Extension.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/13.
//

import UIKit

extension UIViewController {
    func showAlert(title: String?, message: String?, style: UIAlertController.Style, action: UIAlertAction)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)

        alertController.addAction(action)

        self.present(alertController, animated: true, completion: nil)
    }
}
