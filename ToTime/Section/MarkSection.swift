//
//  MarkSection.swift
//  ToTimer
//
//  Created by 김민국 on 2020/12/06.
//

import Foundation
import UIKit
import RxDataSources



typealias MarkSectionModel = SectionModel<MarkSection, MarkSectionItem>

enum MarkSection {
    case mark
}

enum MarkSectionItem {
    case mark(mark: Mark)
}
