//
//  AddressSection.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/07.
//

import RxDataSources

typealias AddressSectionModel = SectionModel<AddressSection, AddressSectionItem>

enum AddressSection {
    case address
}

enum AddressSectionItem {
    case address(address: Address)
}
