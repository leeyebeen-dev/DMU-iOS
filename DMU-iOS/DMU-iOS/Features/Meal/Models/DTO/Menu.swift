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
    OneMenu(details: ["라면 3,500원", "치즈라면 4,000원", "해물라면 4,500원", "돈까스 5,000원", "치즈돈까스 5,500원", "고구마치즈돈까스 6,000원", "스팸김치볶음밥 4,900원", "치킨마요덮밥 4,500원", "불닭마요덮밥 4,500원", "오므라이스 5,500원"]),
]
