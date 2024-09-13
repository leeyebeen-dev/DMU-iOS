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

enum Weekday: String, CaseIterable {
    case monday = "월요일"
    case tuesday = "화요일"
    case wednesday = "수요일"
    case thursday = "목요일"
    case friday = "금요일"
}

struct OneMenu: Identifiable {
    var id = UUID()
    var details: [String]
    var availableDays: [Weekday]
}

let OneMenuList = [
    OneMenu(details: ["라면 3,500원", "치즈라면 4,000원", "해물라면 4,500원"], availableDays: [.monday, .tuesday, .wednesday, .thursday, .friday]),
    OneMenu(details: ["돈까스 5,000원", "치즈돈까스 5,500원", "고구마치즈돈까스 6,000원"], availableDays: [.monday, .tuesday, .wednesday, .thursday, .friday]),
    OneMenu(details: ["스팸김치볶음밥 4,900원"], availableDays: [.monday, .tuesday]),
    OneMenu(details: ["치킨마요덮밥 4,500원", "불닭마요덮밥 4,500원"], availableDays: [.wednesday, .thursday]),
    OneMenu(details: ["오므라이스 5,500원"], availableDays: [.friday]),
]
