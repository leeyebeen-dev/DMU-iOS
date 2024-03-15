//
//  UserSettings.swift
//  DMU-iOS
//
//  Created by 이예빈 on 1/5/24.
//

import Combine
import Foundation

class UserSettings: ObservableObject {
    
    @Published var selectedDepartment: String {
        didSet {
            UserDefaults.standard.set(selectedDepartment, forKey: "SelectedDepartment")
        }
    }
    
    @Published var selectedKeywords: [String] {
        didSet {
            UserDefaults.standard.set(selectedKeywords, forKey: "SelectedKeywords")
        }
    }
    
    init() {
        self.selectedDepartment = UserDefaults.standard.object(forKey: "SelectedDepartment") as? String ?? "학과를 선택하세요"
        self.selectedKeywords = UserDefaults.standard.object(forKey: "SelectedKeywords") as? [String] ?? []
    }
}
