//
//  Menu.swift
//  DMU-iOS
//
//  Created by 이예빈 on 1/4/24.
//

import Foundation

// MARK: - 한식
struct Menu: Identifiable {
    
    var id = UUID()
    var date: String
    var details: [String]
}

// MARK: - 일품
struct OneMenu: Identifiable {
    var id = UUID()
    var details: [String]
}

let OneMenuList = [
    OneMenu(details: ["김치볶음밥 4900원", "라면 4000원", "치즈라면 4500원", "해물짬뽕라면 4500원", "돈까스 5000원", "치즈돈까스 5500원", "고구마치즈돈까스 6000원"]),
]
