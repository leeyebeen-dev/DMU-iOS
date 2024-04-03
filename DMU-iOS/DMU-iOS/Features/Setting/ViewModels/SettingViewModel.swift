//
//  SettingViewModel.swift
//  DMU-iOS
//
//  Created by 이예빈 on 1/5/24.
//

import Foundation

class SettingViewModel: ObservableObject {
    
    @Published var userSettings: UserSettings
    
    init(userSettings: UserSettings) {
        self.userSettings = userSettings
        self.settingDepartment = userSettings.selectedDepartment
        self.settingKeywordsContents = userSettings.selectedKeywordsContents
    }

    //MARK: -키워드 편집
    
    //MARK: 키워드 업데이트 (알림 ON, 키워드 설정)
    @Published var settingKeywordsContents: [String] = []
    @Published var isUpdateKeywordLoading = false
    
    private var notificationService = NotificationService()
    
    func saveKeyword(keywords: [String]) {
        userSettings.selectedKeywordsContents = keywords
        settingKeywordsContents = keywords
    }
    
    func postUpdateKeyword() {
        self.isUpdateKeywordLoading = true
        
        if userSettings.fcmToken.isEmpty {
            print("FCM 토큰 없음")
            return
        }
        
        if userSettings.selectedKeywordsContents.isEmpty {
            print("선택된 키워드 없음")
            return
        }
        
        let token = userSettings.fcmToken
        let keywords = userSettings.selectedKeywordsContents
        
        notificationService.postUpdateKeyword(token: token, topics: keywords) { result in
            switch result {
            case .success(let success):
                if success {
                    print("키워드 업데이트 성공")
                    self.userSettings.isKeywordNotificationOn = true
                } else {
                    print("카워드 업데이트 실패")
                }
            case .failure(let error):
                print("키워드 업데이트 실패: \(error.localizedDescription)")
            }
            self.isUpdateKeywordLoading = false
        }
    }
    
    //MARK: 키워드 삭제 (알림 OFF)
    func postDeleteKeyword() {
        self.isUpdateKeywordLoading = true
        
        if userSettings.fcmToken.isEmpty {
            print("FCM 토큰 없음")
            return
        }
        
        if userSettings.selectedKeywordsContents.isEmpty {
            print("선택된 키워드 없음")
            return
        }
        
        let token = userSettings.fcmToken
        
        notificationService.postDeleteKeyword(token: token) { result in
            switch result {
            case .success(let success):
                if success {
                    print("키워드 삭제 성공")
                } else {
                    print("카워드 삭제 실패")
                }
            case .failure(let error):
                print("키워드 삭제 실패: \(error.localizedDescription)")
            }
            self.isUpdateKeywordLoading = false
        }
    }
    
    //MARK: -학과 편집
    
    @Published var settingDepartment: String? = nil
    @Published var isUpdateDepartmentLoading = false
    
    //MARK: 선택 학과 저장
    func saveDepartment(department: String) {
        userSettings.selectedDepartment = department
        settingDepartment = department
    }
    
    //MARK: 학과 업데이트 (알림 ON, 학과 설정)
    func postUpdateDepartment(){
        self.isUpdateDepartmentLoading = true
        
        if userSettings.fcmToken.isEmpty {
            print("FCM 토큰 없음")
            return
        }
        
        if userSettings.selectedDepartment.isEmpty {
            print("선택된 학과 없음")
            return
        }
        
        let token = userSettings.fcmToken
        let department = userSettings.selectedDepartment
        
        notificationService.postUpdateDepartment(token: token, department: department) { result in
            switch result {
            case .success(let success):
                if success {
                    print("학과 업데이트 성공")
                    self.userSettings.isDepartmentNotificationOn = true
                } else {
                    print("학과 업데이트 실패")
                }
            case .failure(let error):
                print("학과 업데이트 실패: \(error.localizedDescription)")
            }
            self.isUpdateDepartmentLoading = false
        }
    }
    
    //MARK: 학과 삭제 (알림 OFF)
    func postDeleteDepartment(){
        self.isUpdateDepartmentLoading = true
        
        if userSettings.fcmToken.isEmpty {
            print("FCM 토큰 없음")
            return
        }
        
        if userSettings.selectedDepartment.isEmpty {
            print("선택된 학과 없음")
            return
        }
        
        let token = userSettings.fcmToken
        
        notificationService.postDeleteDepartment(token: token) { result in
            switch result {
            case .success(let success):
                if success {
                    print("학과 삭제 성공")
                } else {
                    print("학과 삭제 실패")
                }
            case .failure(let error):
                print("학과 삭제 실패: \(error.localizedDescription)")
            }
            self.isUpdateDepartmentLoading = false
        }
    }
}
