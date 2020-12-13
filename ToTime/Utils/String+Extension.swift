//
//  String+Extension.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/13.
//

import Foundation

extension String {
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, bundle: bundle, value: "\(self)", comment: "")
    }
}
