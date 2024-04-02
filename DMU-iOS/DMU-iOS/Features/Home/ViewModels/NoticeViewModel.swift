//
//  NoticeViewModel.swift
//  DMU-iOS
//
//  Created by 이예빈 on 12/31/23.
//

import Foundation

enum NoticeTab: String {
    case university = "대학 공지"
    case department = "학과 공지"
}

class NoticeViewModel: ObservableObject {
    
    @Published var selectedTab: NoticeTab = .university
    @Published var universityNotices: [UniversityNotice] = []
    @Published var departmentNotices: [DepartmentNotice] = []
    @Published var isShowingWebView = false
    
    // MARK: - 대학공지 데이터 통신
    @Published var isUniversityNoticeLoading = false
    @Published var isUniversityNoticeLoadingFailed = false
    
    private var universityNoticeCurrentPage = 1
    private let universityNoticeItemsPerPage = 10
    private let universityNoticeService = UniversityNoticeService()
    
    func resetAndLoadFirstPageOfUniversityNotices() {
        self.universityNoticeCurrentPage = 1
        self.universityNotices = []
        loadNextPageOfUniversityNotices()
    }
    
    private func loadNextPageOfUniversityNotices() {
        self.isUniversityNoticeLoading = true
        self.isUniversityNoticeLoadingFailed = false
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.universityNoticeService.getUniversityNotices(page: self.universityNoticeCurrentPage, size: self.universityNoticeItemsPerPage) { result in
                    switch result {
                    case .success(let notices):
                        self.universityNotices.append(contentsOf: notices)
                        self.isUniversityNoticeLoadingFailed = false
                    case .failure(let error):
                        print("Failed to get university notices: \(error)")
                        self.isUniversityNoticeLoadingFailed = true
                    }
                    
                    self.isUniversityNoticeLoading = false
                }
            }
        }
    }
    
    func loadNextPageOfUniversityNoticesIfNotLoading() {
        if !isUniversityNoticeLoading {
            universityNoticeCurrentPage += 1
            loadNextPageOfUniversityNotices()
        }
    }
    
    // MARK: - 학부공지 데이터 통신
    @Published var isDepartmentNoticeLoading = false
    @Published var isDepartmentNoticeLoadingFailed = false
    
    private var departmentNoticeCurrentPage = 1
    private let departmentNoticeItemsPerPage = 10
    private let departmentNoticeService = DepartmentNoticeService()
    
    
    func resetAndLoadFirstPageOfDepartmentNotices(department: String) {
        self.departmentNoticeCurrentPage = 1
        self.departmentNotices = []
        loadNextPageOfDepartmentNotices(department: department)
    }
    
    func loadNextPageOfDepartmentNotices(department: String) {
        self.isDepartmentNoticeLoading = true
        self.isDepartmentNoticeLoadingFailed = false
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.departmentNoticeService.getDepartmentNotices(department: department, page: self.departmentNoticeCurrentPage, size: self.departmentNoticeItemsPerPage) { result in
                    switch result {
                    case .success(let notices):
                        self.departmentNotices.append(contentsOf: notices)
                        self.isDepartmentNoticeLoadingFailed = false
                    case .failure(let error):
                        print("Failed to get department notices: \(error.localizedDescription)")
                        self.isDepartmentNoticeLoadingFailed = true
                    }
                    
                    self.isDepartmentNoticeLoading = false
                }
            }
        }
    }
    
    func loadNextPageIfNotLoading(department: String) {
        if !isDepartmentNoticeLoading {
            departmentNoticeCurrentPage += 1
            loadNextPageOfDepartmentNotices(department: department)
        }
    }
}
