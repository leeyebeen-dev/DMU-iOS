//
//  SettingViewModel.swift
//  DMU-iOS
//
//  Created by 이예빈 on 1/5/24.
//

import Foundation

class SettingViewModel: ObservableObject {
    
    @Published var settingDepartment: String? = nil
    @Published var userSettings: UserSettings
    
    init(userSettings: UserSettings) {
        self.userSettings = userSettings
        self.settingDepartment = userSettings.selectedDepartment
    }
    
    //MARK: 학과 선택
    func selectDepartment(_ department: String) {
        if settingDepartment == department {
            settingDepartment = nil
        } else {
            settingDepartment = department
        }
    }
    
    //MARK: 선택 학과 저장
    func saveDepartment() {
        guard let department = settingDepartment else {
            return
        }
        userSettings.selectedDepartment = department
    }
    
    //MARK: 키워드 업데이트 (알림 ON, 키워드 설정)
    private var notificationService = NotificationService()
    
    func postUpdateKeyword() {
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
        }
    }
    
    //MARK: 키워드 삭제 (알림 OFF)
    func postDeleteKeyword() {
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
        }
    }
    
    //MARK: 학과 업데이트 (알림 ON, 학과 설정)
    func postUpdateDepartment(){
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
        }
    }
    
    //MARK: 학과 삭제 (알림 OFF)
    func postDeleteDepartment(){
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
        }
    }
}
